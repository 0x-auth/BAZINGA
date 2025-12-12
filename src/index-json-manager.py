#!/usr/bin/env python3
"""
Index.json Manager and Analysis Tool
A comprehensive tool for managing, analyzing, and organizing index.json files
"""

import os
import sys
import json
import argparse
import logging
import time
import shutil
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional

# Configure logging
logging.basicConfig(
    level = logging.INFO,
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers = [
        logging.FileHandler(f"index_manager_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("index_manager")

class IndexJsonManager:
    def __init__(self, output_dir = "~/Organized/Indices"):
        self.output_dir = os.path.expanduser(output_dir)
        self.catalog_file = os.path.join(self.output_dir, "index_catalog.json")
        self.report_file = os.path.join(self.output_dir, "index_analysis.md")
        self.large_dir = os.path.join(self.output_dir, "large")
        self.small_dir = os.path.join(self.output_dir, "small")
        self.duplicates_dir = os.path.join(self.output_dir, "duplicates")

        # Ensure directories exist
        for directory in [self.output_dir, self.large_dir, self.small_dir, self.duplicates_dir]:
            os.makedirs(directory, exist_ok = True)

        # Initialize index catalog
        self.catalog = self._load_catalog()

    def _load_catalog(self) -> Dict[str, Any]:
        """Load existing catalog or create new one"""
        if os.path.exists(self.catalog_file):
            try:
                with open(self.catalog_file, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                logger.warning(f"Could not decode {self.catalog_file}, creating new catalog")

        return {
            "files": [],
            "last_updated": datetime.now().isoformat(),
            "total_files": 0,
            "total_size_bytes": 0,
            "duplicate_sets": []
        }

    def _save_catalog(self) -> None:
        """Save catalog to file"""
        self.catalog["last_updated"] = datetime.now().isoformat()
        self.catalog["total_files"] = len(self.catalog["files"])

        with open(self.catalog_file, 'w') as f:
            json.dump(self.catalog, f, indent = 2)

    def find_all_index_files(self, start_dir = "~") -> List[str]:
        """Find all index.json files from the given directory"""
        start_dir = os.path.expanduser(start_dir)
        logger.info(f"Searching for index.json files in {start_dir}...")

        # Use find command to locate all index.json files (more efficient than os.walk)
        import subprocess
        cmd = ["find", start_dir, "-name", "index.json", "-type", "f", "2>/dev/null"]
        try:
            result = subprocess.run(cmd, capture_output = True, text = True)
            files = result.stdout.strip().split("\n")
            files = [f for f in files if f]  # Remove empty strings

            logger.info(f"Found {len(files)} index.json files")
            return files
        except Exception as e:
            logger.error(f"Error executing find command: {str(e)}")
            return []

    def analyze_index_file(self, file_path: str) -> Dict[str, Any]:
        """Analyze an index.json file and return metadata"""
        try:
            # Get basic file stats
            file_stats = os.stat(file_path)
            file_size = file_stats.st_size
            modified_time = datetime.fromtimestamp(file_stats.st_mtime).isoformat()

            # Calculate file hash for duplicate detection
            import hashlib
            hash_md5 = hashlib.md5()
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)
            file_hash = hash_md5.hexdigest()

            # Try to parse JSON for content analysis
            content_summary = {}
            try:
                with open(file_path, 'r') as f:
                    data = json.load(f)

                # Get top-level keys
                content_summary["top_level_keys"] = list(data.keys())

                # Count entries if it's an array
                if isinstance(data, list):
                    content_summary["array_length"] = len(data)

                # Check for common patterns
                for key in ["items", "entries", "data", "records"]:
                    if key in data and isinstance(data[key], list):
                        content_summary[f"{key}_count"] = len(data[key])
            except:
                content_summary["parseable"] = False

            return {
                "path": file_path,
                "size_bytes": file_size,
                "modified": modified_time,
                "hash": file_hash,
                "content_summary": content_summary,
                "is_large": file_size > 1024 * 1024  # 1MB threshold
            }
        except Exception as e:
            logger.error(f"Error analyzing {file_path}: {str(e)}")
            return {
                "path": file_path,
                "error": str(e)
            }

    def catalog_all_files(self, start_dir = "~") -> None:
        """Find and catalog all index.json files"""
        files = self.find_all_index_files(start_dir)
        total_size = 0

        # Clear existing catalog
        self.catalog["files"] = []

        # Process each file
        for file_path in files:
            logger.info(f"Analyzing {file_path}...")
            metadata = self.analyze_index_file(file_path)
            self.catalog["files"].append(metadata)
            if "size_bytes" in metadata:
                total_size += metadata["size_bytes"]

        # Update total size
        self.catalog["total_size_bytes"] = total_size

        # Find duplicate sets based on hash
        hash_map = {}
        for file_info in self.catalog["files"]:
            if "hash" in file_info:
                hash_map.setdefault(file_info["hash"], []).append(file_info["path"])

        # Filter to only duplicate sets
        duplicate_sets = {h: paths for h, paths in hash_map.items() if len(paths) > 1}
        self.catalog["duplicate_sets"] = [{"hash": h, "paths": p} for h, p in duplicate_sets.items()]

        # Save the catalog
        self._save_catalog()
        logger.info(f"Catalog updated with {len(self.catalog['files'])} files")

    def organize_files(self) -> None:
        """Organize index.json files based on size and duplicate status"""
        if not self.catalog["files"]:
            logger.warning("No files in catalog. Run catalog_all_files first.")
            return

        # Clear existing organized directories
        for dir_path in [self.large_dir, self.small_dir, self.duplicates_dir]:
            for item in os.listdir(dir_path):
                item_path = os.path.join(dir_path, item)
                if os.path.islink(item_path):
                    os.unlink(item_path)

        # Organize by size
        for file_info in self.catalog["files"]:
            if "path" not in file_info or "size_bytes" not in file_info:
                continue

            source_path = file_info["path"]
            file_name = os.path.basename(os.path.dirname(source_path)) + "_" + os.path.basename(source_path)

            # Create symbolic links in appropriate directories
            if file_info.get("is_large", False):
                target_path = os.path.join(self.large_dir, file_name)
            else:
                target_path = os.path.join(self.small_dir, file_name)

            try:
                os.symlink(source_path, target_path)
                logger.info(f"Created symlink: {target_path} -> {source_path}")
            except FileExistsError:
                logger.debug(f"Symlink already exists: {target_path}")
            except Exception as e:
                logger.error(f"Error creating symlink {target_path}: {str(e)}")

        # Organize duplicates
        for dup_set in self.catalog["duplicate_sets"]:
            for path in dup_set["paths"]:
                file_name = os.path.basename(os.path.dirname(path)) + "_" + os.path.basename(path)
                target_path = os.path.join(self.duplicates_dir, file_name)

                try:
                    os.symlink(path, target_path)
                    logger.info(f"Created duplicate symlink: {target_path} -> {path}")
                except FileExistsError:
                    logger.debug(f"Duplicate symlink already exists: {target_path}")
                except Exception as e:
                    logger.error(f"Error creating duplicate symlink {target_path}: {str(e)}")

    def generate_report(self) -> None:
        """Generate a markdown report of all index.json files"""
        if not self.catalog["files"]:
            logger.warning("No files in catalog. Run catalog_all_files first.")
            return

        with open(self.report_file, 'w') as f:
            f.write("# Index.json File Analysis Report\n\n")
            f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

            f.write("## Summary\n\n")
            f.write(f"- Total files: {self.catalog['total_files']}\n")
            f.write(f"- Total size: {self._format_size(self.catalog['total_size_bytes'])}\n")
            f.write(f"- Duplicate sets: {len(self.catalog['duplicate_sets'])}\n\n")

            # Size distribution
            f.write("## Size Distribution\n\n")
            large_files = [f for f in self.catalog["files"] if f.get("is_large", False)]
            f.write(f"- Large files (>1MB): {len(large_files)}\n")
            f.write(f"- Small files: {self.catalog['total_files'] - len(large_files)}\n\n")

            # Largest files
            f.write("## Largest Files\n\n")
            f.write("| Path | Size | Modified |\n")
            f.write("|------|------|----------|\n")

            sorted_files = sorted(
                self.catalog["files"],
                key = lambda x: x.get("size_bytes", 0),
                reverse = True
            )

            for file_info in sorted_files[:10]:
                path = file_info.get("path", "Unknown")
                size = self._format_size(file_info.get("size_bytes", 0))
                modified = file_info.get("modified", "Unknown")
                f.write(f"| {path} | {size} | {modified} |\n")

            f.write("\n")

            # Duplicate files
            f.write("## Duplicate Files\n\n")
            if self.catalog["duplicate_sets"]:
                for i, dup_set in enumerate(self.catalog["duplicate_sets"], 1):
                    f.write(f"### Duplicate Set {i}\n\n")
                    f.write(f"Hash: `{dup_set['hash']}`\n\n")
                    for path in dup_set["paths"]:
                        f.write(f"- {path}\n")
                    f.write("\n")
            else:
                f.write("No duplicates found.\n\n")

            # Location clusters
            f.write("## Common Locations\n\n")

            dirs = {}
            for file_info in self.catalog["files"]:
                path = file_info.get("path", "")
                if path:
                    parent_dir = os.path.dirname(path)
                    dirs.setdefault(parent_dir, 0)
                    dirs[parent_dir] += 1

            sorted_dirs = sorted(dirs.items(), key = lambda x: x[1], reverse = True)

            f.write("| Directory | Count |\n")
            f.write("|-----------|-------|\n")

            for dir_path, count in sorted_dirs[:10]:
                f.write(f"| {dir_path} | {count} |\n")

        logger.info(f"Report generated at {self.report_file}")

    def _format_size(self, size_bytes: int) -> str:
        """Format size in bytes to human readable format"""
        if size_bytes < 1024:
            return f"{size_bytes} B"
        elif size_bytes < 1024 * 1024:
            return f"{size_bytes / 1024:.2f} KB"
        elif size_bytes < 1024 * 1024 * 1024:
            return f"{size_bytes / (1024 * 1024):.2f} MB"
        else:
            return f"{size_bytes / (1024 * 1024 * 1024):.2f} GB"

def main():
    parser = argparse.ArgumentParser(description = "Index.json Manager and Analysis Tool")
    parser.add_argument("--dir", default = "~", help = "Directory to search for index.json files")
    parser.add_argument("--output", default = "~/Organized/Indices", help = "Output directory for organized files")
    parser.add_argument("--catalog", action = "store_true", help = "Catalog all index.json files")
    parser.add_argument("--organize", action = "store_true", help = "Organize files into categories")
    parser.add_argument("--report", action = "store_true", help = "Generate analysis report")
    parser.add_argument("--all", action = "store_true", help = "Perform all actions")
    args = parser.parse_args()

    manager = IndexJsonManager(output_dir = os.path.expanduser(args.output))

    if args.all or args.catalog:
        manager.catalog_all_files(args.dir)

    if args.all or args.organize:
        manager.organize_files()

    if args.all or args.report:
        manager.generate_report()

    if not (args.catalog or args.organize or args.report or args.all):
        parser.print_help()

if __name__ == "__main__":
    main()
