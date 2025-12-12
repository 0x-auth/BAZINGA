#!/usr/bin/env python3
"""
Bazinga Claude Artifact Analyzer
Analyzes collected Claude artifacts to extract insights and patterns
"""

import os
import json
import argparse
import logging
import re
from datetime import datetime
from collections import Counter, defaultdict
import matplotlib.pyplot as plt
import numpy as np

# Configure logging
logging.basicConfig(
    level = logging.INFO,
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers = [
        logging.FileHandler(f"bazinga_analyze_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("bazinga_analyzer")

class BazingaAnalyzer:
    def __init__(self, artifacts_dir = "artifacts/claude_artifacts", output_dir = "analysis"):
        self.artifacts_dir = artifacts_dir
        self.output_dir = output_dir
        self.metadata_file = os.path.join(os.path.dirname(artifacts_dir), "artifacts_metadata.json")

        # Ensure directories exist
        os.makedirs(self.output_dir, exist_ok = True)

        # Load metadata
        self.metadata = self._load_metadata()
        self.artifacts = []

    def _load_metadata(self):
        """Load artifacts metadata"""
        if os.path.exists(self.metadata_file):
            try:
                with open(self.metadata_file, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Error loading metadata: {str(e)}")
                return {"artifacts": []}
        else:
            logger.warning(f"Metadata file not found: {self.metadata_file}")
            return {"artifacts": []}

    def load_artifacts(self):
        """Load all artifact files"""
        loaded = 0

        # Try loading from metadata first
        for artifact_entry in self.metadata.get("artifacts", []):
            file_path = artifact_entry.get("file_path")
            if file_path and os.path.exists(file_path):
                try:
                    with open(file_path, 'r') as f:
                        artifact_data = json.load(f)
                        self.artifacts.append(artifact_data)
                        loaded += 1
                except Exception as e:
                    logger.error(f"Error loading artifact {file_path}: {str(e)}")

        # If no artifacts loaded from metadata, try direct file scan
        if loaded == 0:
            logger.info("No artifacts loaded from metadata, scanning directory")
            for filename in os.listdir(self.artifacts_dir):
                if filename.endswith(".json"):
                    file_path = os.path.join(self.artifacts_dir, filename)
                    try:
                        with open(file_path, 'r') as f:
                            artifact_data = json.load(f)
                            self.artifacts.append(artifact_data)
                            loaded += 1
                    except Exception as e:
                        logger.error(f"Error loading artifact {file_path}: {str(e)}")

        logger.info(f"Loaded {loaded} artifacts")
        return loaded

    def analyze_content_patterns(self):
        """Analyze patterns in artifact content"""
        if not self.artifacts:
            logger.warning("No artifacts to analyze")
            return {}

        # Extract content from artifacts
        contents = []
        for artifact in self.artifacts:
            content = artifact.get("content", "")
            if content:
                contents.append(content)

        if not contents:
            logger.warning("No content found in artifacts")
            return {}

        # Perform analysis
        word_counter = Counter()
        topic_patterns = {
            "technical": re.compile(r'\b(code|function|algorithm|data|api|server|python|javascript)\b', re.I),
            "business": re.compile(r'\b(business|strategy|market|customer|revenue|profit|growth)\b', re.I),
            "creative": re.compile(r'\b(story|design|creative|art|music|novel|character)\b', re.I),
            "analytical": re.compile(r'\b(analysis|analyze|research|study|survey|statistics|results)\b', re.I)
        }

        topic_counts = {topic: 0 for topic in topic_patterns}

        for content in contents:
            # Count words
            words = re.findall(r'\b\w+\b', content.lower())
            word_counter.update(words)

            # Check topics
            for topic, pattern in topic_patterns.items():
                if pattern.search(content):
                    topic_counts[topic] += 1

        # Calculate results
        common_words = word_counter.most_common(20)
        topic_distribution = {topic: count / len(contents) for topic, count in topic_counts.items()}

        results = {
            "common_words": common_words,
            "topic_distribution": topic_distribution,
            "total_artifacts": len(self.artifacts),
            "total_with_content": len(contents)
        }

        # Save results
        result_file = os.path.join(self.output_dir, "content_pattern_analysis.json")
        with open(result_file, 'w') as f:
            json.dump(results, f, indent = 2)

        logger.info(f"Content pattern analysis complete, saved to {result_file}")

        # Generate visualization
        self._generate_topic_visualization(topic_distribution)

        return results

    def _generate_topic_visualization(self, topic_distribution):
        """Generate visualization of topic distribution"""
        try:
            # Create bar chart
            topics = list(topic_distribution.keys())
            values = list(topic_distribution.values())

            plt.figure(figsize=(10, 6))
            bars = plt.bar(topics, values, color = 'skyblue')

            # Add values on top of bars
            for bar in bars:
                height = bar.get_height()
                plt.text(bar.get_x() + bar.get_width()/2., height,
                        f'{height:.2f}',
                        ha = 'center', va = 'bottom')

            plt.title('Topic Distribution in Claude Artifacts')
            plt.xlabel('Topics')
            plt.ylabel('Proportion of Artifacts')
            plt.ylim(0, 1.0)

            # Save figure
            plt.savefig(os.path.join(self.output_dir, "topic_distribution.png"))
            logger.info(f"Topic distribution visualization saved")

        except Exception as e:
            logger.error(f"Error generating visualization: {str(e)}")

    def generate_report(self):
        """Generate comprehensive analysis report"""
        if not self.artifacts:
            logger.warning("No artifacts to include in report")
            return

        # Gather basic statistics
        total_artifacts = len(self.artifacts)
        artifact_dates = [a.get("collected_at", "") for a in self.artifacts]
        artifact_dates = [d for d in artifact_dates if d]  # Filter out empty dates

        if artifact_dates:
            earliest = min(artifact_dates)
            latest = max(artifact_dates)
        else:
            earliest = latest = "N/A"

        # Generate report
        report = {
            "report_generated": datetime.now().isoformat(),
            "total_artifacts": total_artifacts,
            "date_range": {
                "earliest": earliest,
                "latest": latest
            },
            "content_analysis": self.analyze_content_patterns(),
        }

        # Save report
        report_file = os.path.join(self.output_dir, "bazinga_analysis_report.json")
        with open(report_file, 'w') as f:
            json.dump(report, f, indent = 2)

        # Create human-readable summary
        summary = f"""
Bazinga Analysis Report
======================
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

Artifact Statistics
------------------
Total artifacts: {total_artifacts}
Date range: {earliest} to {latest}

Content Analysis
---------------
Top topics: {', '.join(f"{topic} ({value:.2f})" for topic, value in report['content_analysis']['topic_distribution'].items())}
Total artifacts with content: {report['content_analysis']['total_with_content']}

Most common words:
{chr(10).join([f"- {word}: {count}" for word, count in report['content_analysis']['common_words'][:10]])}
"""

        summary_file = os.path.join(self.output_dir, "bazinga_summary.txt")
        with open(summary_file, 'w') as f:
            f.write(summary)

        logger.info(f"Analysis report generated and saved to {report_file}")
        logger.info(f"Summary saved to {summary_file}")

        return report

def main():
    parser = argparse.ArgumentParser(description = "Bazinga Claude Artifact Analyzer")
    parser.add_argument("--artifacts-dir", default = "artifacts/claude_artifacts", help = "Directory containing artifacts")
    parser.add_argument("--output-dir", default = "analysis", help = "Directory for analysis output")
    args = parser.parse_args()

    analyzer = BazingaAnalyzer(artifacts_dir = args.artifacts_dir, output_dir = args.output_dir)
    loaded = analyzer.load_artifacts()

    if loaded > 0:
        analyzer.generate_report()
        logger.info("Analysis complete!")
    else:
        logger.error("No artifacts could be loaded for analysis")

if __name__ == "__main__":
    main()
