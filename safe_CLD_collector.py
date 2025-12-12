#!/usr/bin/env python3
"""
Safe Claude Artifact Collector
This module collects Claude artifacts without interfering with the clipboard.
It uses direct file operations instead of clipboard hooks.
"""

import os
import json
import time
import argparse
import logging
import requests
from datetime import datetime
from urllib.parse import urlparse

# Configure logging
logging.basicConfig(
    level = logging.INFO,
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers = [
        logging.FileHandler(f"claude_collect_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("claude_collector")

class SafeClaudeCollector:
    def __init__(self, output_dir = "artifacts"):
        self.output_dir = output_dir
        self.artifact_dir = os.path.join(output_dir, "claude_artifacts")
        self.metadata_file = os.path.join(output_dir, "artifacts_metadata.json")
        self.artifact_count = 0

        # Ensure directories exist
        os.makedirs(self.artifact_dir, exist_ok = True)

        # Load existing metadata if available
        self.metadata = self._load_metadata()

    def _load_metadata(self):
        """Load existing metadata or create new structure"""
        if os.path.exists(self.metadata_file):
            try:
                with open(self.metadata_file, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                logger.warning(f"Could not decode {self.metadata_file}, creating new metadata")

        return {
            "artifacts": [],
            "last_updated": datetime.now().isoformat(),
            "total_collected": 0
        }

    def _save_metadata(self):
        """Save metadata to file"""
        self.metadata["last_updated"] = datetime.now().isoformat()
        self.metadata["total_collected"] = len(self.metadata["artifacts"])

        with open(self.metadata_file, 'w') as f:
            json.dump(self.metadata, f, indent = 2)

    def process_artifact_url(self, url):
        """Process a Claude artifact URL without using clipboard"""
        if not url or "claude.site/artifacts" not in url:
            logger.warning(f"Not a valid Claude artifact URL: {url}")
            return False

        # Parse URL to get artifact ID
        parsed_url = urlparse(url)
        path_parts = parsed_url.path.split('/')
        if len(path_parts) < 3:
            logger.warning(f"Could not extract artifact ID from URL: {url}")
            return False

        artifact_id = path_parts[-1]

        # Check if already processed
        if any(a["id"] == artifact_id for a in self.metadata["artifacts"]):
            logger.info(f"Artifact {artifact_id} already processed, skipping")
            return False

        # Create artifact entry
        artifact_entry = {
            "id": artifact_id,
            "url": url,
            "collected_at": datetime.now().isoformat(),
            "file_path": os.path.join(self.artifact_dir, f"{artifact_id}.json")
        }

        # Attempt to download content if it's a direct resource
        try:
            # For demonstration - in real use you'd implement proper content download
            # This is just a placeholder for the concept
            with open(artifact_entry["file_path"], 'w') as f:
                f.write(json.dumps({
                    "id": artifact_id,
                    "url": url,
                    "collected_at": artifact_entry["collected_at"],
                    "content": "Placeholder for artifact content"
                }, indent = 2))

            self.metadata["artifacts"].append(artifact_entry)
            self._save_metadata()
            self.artifact_count += 1
            logger.info(f"Successfully processed artifact {artifact_id}")
            return True

        except Exception as e:
            logger.error(f"Error processing artifact {artifact_id}: {str(e)}")
            return False

    def process_artifact_content(self, content, artifact_type = "text"):
        """Process artifact content directly without URL"""
        if not content:
            return False

        # Generate an ID for this content
        artifact_id = f"local_{int(time.time())}_{hash(content) % 10000}"

        # Create artifact entry
        artifact_entry = {
            "id": artifact_id,
            "type": artifact_type,
            "collected_at": datetime.now().isoformat(),
            "file_path": os.path.join(self.artifact_dir, f"{artifact_id}.json")
        }

        # Save content
        try:
            with open(artifact_entry["file_path"], 'w') as f:
                f.write(json.dumps({
                    "id": artifact_id,
                    "type": artifact_type,
                    "collected_at": artifact_entry["collected_at"],
                    "content": content
                }, indent = 2))

            self.metadata["artifacts"].append(artifact_entry)
            self._save_metadata()
            self.artifact_count += 1
            logger.info(f"Successfully saved local artifact {artifact_id}")
            return True

        except Exception as e:
            logger.error(f"Error saving artifact {artifact_id}: {str(e)}")
            return False

    def get_stats(self):
        """Return collector statistics"""
        return {
            "total_artifacts": len(self.metadata["artifacts"]),
            "new_artifacts": self.artifact_count,
            "last_updated": self.metadata["last_updated"]
        }

def main():
    parser = argparse.ArgumentParser(description = "Safe Claude Artifact Collector")
    parser.add_argument("--dir", default = "artifacts", help = "Directory to store artifacts")
    parser.add_argument("--url", help = "Claude artifact URL to process")
    parser.add_argument("--file", help = "File containing Claude artifact URLs")
    parser.add_argument("--content", help = "Direct content to save as artifact")
    args = parser.parse_args()

    collector = SafeClaudeCollector(output_dir = args.dir)

    if args.url:
        collector.process_artifact_url(args.url)

    if args.file:
        try:
            with open(args.file, 'r') as f:
                for line in f:
                    url = line.strip()
                    if url:
                        collector.process_artifact_url(url)
        except Exception as e:
            logger.error(f"Error processing URL file: {str(e)}")

    if args.content:
        collector.process_artifact_content(args.content)

    stats = collector.get_stats()
    logger.info(f"Collection complete. Total artifacts: {stats['total_artifacts']}, New: {stats['new_artifacts']}")

if __name__ == "__main__":
    main()
