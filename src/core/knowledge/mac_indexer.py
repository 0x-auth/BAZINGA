#!/usr/bin/env python3
"""
mac_indexer.py - Index Mac Files for BAZINGA Knowledge Base

"Your Mac IS the training data"

This module scans your Mac and builds a knowledge graph using ΛG coherence.
No GPU training needed - just boundary-guided emergence from YOUR data.

Key insight: Instead of learning from the internet like traditional LLMs,
BAZINGA learns from YOUR files, YOUR conversations, YOUR code.
"""

import os
import json
import hashlib
from pathlib import Path
from typing import Dict, Any, List, Optional, Set
from dataclasses import dataclass, field
from datetime import datetime
import re
import sys

sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent))

from src.core.lambda_g import LambdaGOperator, PHI


@dataclass
class KnowledgeNode:
    """
    A single piece of knowledge from your Mac.

    Each node has:
    - Content (text from file)
    - Coherence score (from ΛG)
    - Connections to related nodes (B₂ bridges)
    """
    id: str
    file_path: str
    content: str
    content_preview: str  # First 500 chars
    file_type: str
    coherence: float
    keywords: List[str]
    bridges: List[str] = field(default_factory=list)  # Connected node IDs
    indexed_at: str = field(default_factory=lambda: datetime.now().isoformat())

    def to_dict(self) -> Dict:
        return {
            'id': self.id,
            'file_path': self.file_path,
            'content_preview': self.content_preview,
            'file_type': self.file_type,
            'coherence': self.coherence,
            'keywords': self.keywords,
            'bridges': self.bridges,
            'indexed_at': self.indexed_at
        }


class KnowledgeGraph:
    """
    Graph of knowledge nodes connected by B₂ bridges.

    Structure:
    - Nodes: Individual pieces of knowledge
    - Edges: Semantic connections (darmiyan bridges)
    - Weights: φ-coherence scores
    """

    def __init__(self):
        self.nodes: Dict[str, KnowledgeNode] = {}
        self.keyword_index: Dict[str, Set[str]] = {}  # keyword -> node IDs
        self.coherence_index: List[str] = []  # Sorted by coherence

    def add_node(self, node: KnowledgeNode):
        """Add a knowledge node to the graph"""
        self.nodes[node.id] = node

        # Index by keywords
        for keyword in node.keywords:
            if keyword not in self.keyword_index:
                self.keyword_index[keyword] = set()
            self.keyword_index[keyword].add(node.id)

        # Update coherence index
        self.coherence_index.append(node.id)
        self.coherence_index.sort(
            key=lambda x: self.nodes[x].coherence,
            reverse=True
        )

    def find_bridges(self, node_id: str, min_shared_keywords: int = 2) -> List[str]:
        """Find nodes connected by shared keywords (B₂ bridges)"""
        if node_id not in self.nodes:
            return []

        node = self.nodes[node_id]
        related_counts: Dict[str, int] = {}

        for keyword in node.keywords:
            if keyword in self.keyword_index:
                for related_id in self.keyword_index[keyword]:
                    if related_id != node_id:
                        related_counts[related_id] = related_counts.get(related_id, 0) + 1

        # Return nodes with enough shared keywords
        bridges = [
            nid for nid, count in related_counts.items()
            if count >= min_shared_keywords
        ]

        # Sort by coherence
        bridges.sort(key=lambda x: self.nodes[x].coherence, reverse=True)

        return bridges[:10]  # Top 10 bridges

    def search(self, query: str, limit: int = 10) -> List[KnowledgeNode]:
        """Search knowledge graph using keywords"""
        query_keywords = self._extract_keywords(query)

        # Find all matching nodes
        matching_ids: Dict[str, float] = {}

        for keyword in query_keywords:
            if keyword in self.keyword_index:
                for node_id in self.keyword_index[keyword]:
                    node = self.nodes[node_id]
                    # Score = keyword matches * coherence
                    matching_ids[node_id] = matching_ids.get(node_id, 0) + node.coherence

        # Sort by score
        sorted_ids = sorted(matching_ids.keys(), key=lambda x: matching_ids[x], reverse=True)

        return [self.nodes[nid] for nid in sorted_ids[:limit]]

    def _extract_keywords(self, text: str) -> List[str]:
        """Extract keywords from text"""
        # Simple keyword extraction
        words = re.findall(r'\b[a-zA-Z]{3,}\b', text.lower())
        # Remove common words
        stopwords = {'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had', 'her', 'was', 'one', 'our', 'out'}
        return [w for w in words if w not in stopwords]

    def get_stats(self) -> Dict[str, Any]:
        """Get graph statistics"""
        if not self.nodes:
            return {'total_nodes': 0}

        coherences = [n.coherence for n in self.nodes.values()]

        return {
            'total_nodes': len(self.nodes),
            'total_keywords': len(self.keyword_index),
            'avg_coherence': sum(coherences) / len(coherences),
            'max_coherence': max(coherences),
            'min_coherence': min(coherences),
            'high_coherence_nodes': sum(1 for c in coherences if c >= 0.6)
        }

    def save(self, path: str):
        """Save graph to JSON"""
        data = {
            'nodes': {nid: node.to_dict() for nid, node in self.nodes.items()},
            'stats': self.get_stats(),
            'saved_at': datetime.now().isoformat()
        }
        with open(path, 'w') as f:
            json.dump(data, f, indent=2)

    def load(self, path: str):
        """Load graph from JSON"""
        with open(path, 'r') as f:
            data = json.load(f)

        for nid, node_data in data['nodes'].items():
            node = KnowledgeNode(
                id=node_data['id'],
                file_path=node_data['file_path'],
                content='',  # Don't store full content in JSON
                content_preview=node_data['content_preview'],
                file_type=node_data['file_type'],
                coherence=node_data['coherence'],
                keywords=node_data['keywords'],
                bridges=node_data.get('bridges', []),
                indexed_at=node_data['indexed_at']
            )
            self.add_node(node)


class MacKnowledgeIndexer:
    """
    Index your Mac for BAZINGA knowledge base.

    This is NOT traditional ML training. Instead:
    1. Scan files on your Mac
    2. Calculate ΛG coherence for each
    3. Build knowledge graph with B₂ bridges
    4. Answers emerge from YOUR knowledge

    "Your Mac IS the training data"
    """

    # File types to index
    INDEXABLE_EXTENSIONS = {
        '.py': 'python',
        '.js': 'javascript',
        '.ts': 'typescript',
        '.json': 'json',
        '.md': 'markdown',
        '.txt': 'text',
        '.html': 'html',
        '.css': 'css',
        '.sh': 'shell',
        '.yml': 'yaml',
        '.yaml': 'yaml',
    }

    # Directories to skip
    SKIP_DIRS = {
        'node_modules', '.git', '__pycache__', 'venv', '.venv',
        'build', 'dist', '.next', '.cache', 'Library', '.Trash'
    }

    # Max file size to index (1MB)
    MAX_FILE_SIZE = 1024 * 1024

    def __init__(self, base_paths: Optional[List[str]] = None):
        self.lambda_g = LambdaGOperator()
        self.graph = KnowledgeGraph()

        # Default paths to index
        home = str(Path.home())
        self.base_paths = base_paths or [
            f"{home}/Documents",
            f"{home}/AmsyPycharm",
            f"{home}/consciousness-portal",
            f"{home}/∞",
            f"{home}/Archive",
        ]

        self.stats = {
            'files_scanned': 0,
            'files_indexed': 0,
            'files_skipped': 0,
            'errors': 0
        }

    def index_all(self, verbose: bool = True) -> KnowledgeGraph:
        """
        Index all files in base paths.

        Returns a knowledge graph with all indexed content.
        """
        if verbose:
            print("◊ BAZINGA KNOWLEDGE INDEXER ◊")
            print("=" * 50)
            print(f"Indexing {len(self.base_paths)} base paths...")
            print()

        for base_path in self.base_paths:
            if os.path.exists(base_path):
                if verbose:
                    print(f"Scanning: {base_path}")
                self._index_directory(base_path, verbose)

        # Build bridges between related nodes
        if verbose:
            print()
            print("Building B₂ bridges (darmiyan connections)...")

        self._build_all_bridges()

        if verbose:
            print()
            print("◊ INDEXING COMPLETE ◊")
            print("-" * 50)
            print(f"Files scanned: {self.stats['files_scanned']}")
            print(f"Files indexed: {self.stats['files_indexed']}")
            print(f"Files skipped: {self.stats['files_skipped']}")
            print(f"Errors: {self.stats['errors']}")
            print()
            stats = self.graph.get_stats()
            print(f"Knowledge nodes: {stats['total_nodes']}")
            print(f"Keywords indexed: {stats['total_keywords']}")
            print(f"Avg coherence: {stats.get('avg_coherence', 0):.3f}")
            print(f"High coherence (≥0.6): {stats.get('high_coherence_nodes', 0)}")

        return self.graph

    def index_file(self, file_path: str) -> Optional[KnowledgeNode]:
        """Index a single file"""
        path = Path(file_path)

        # Check extension
        ext = path.suffix.lower()
        if ext not in self.INDEXABLE_EXTENSIONS:
            return None

        # Check size
        try:
            if path.stat().st_size > self.MAX_FILE_SIZE:
                return None
        except:
            return None

        # Read content
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            self.stats['errors'] += 1
            return None

        if not content.strip():
            return None

        # Calculate coherence using ΛG
        coherence_state = self.lambda_g.calculate_coherence(content[:2000])

        # Extract keywords
        keywords = self._extract_keywords(content)

        # Create node
        node_id = hashlib.md5(file_path.encode()).hexdigest()[:12]

        node = KnowledgeNode(
            id=node_id,
            file_path=file_path,
            content=content,
            content_preview=content[:500],
            file_type=self.INDEXABLE_EXTENSIONS[ext],
            coherence=coherence_state.total_coherence,
            keywords=keywords[:50]  # Top 50 keywords
        )

        self.graph.add_node(node)
        self.stats['files_indexed'] += 1

        return node

    def _index_directory(self, directory: str, verbose: bool = False):
        """Recursively index a directory"""
        try:
            for entry in os.scandir(directory):
                # Skip hidden and excluded directories
                if entry.name.startswith('.') or entry.name in self.SKIP_DIRS:
                    continue

                if entry.is_dir():
                    self._index_directory(entry.path, verbose)
                elif entry.is_file():
                    self.stats['files_scanned'] += 1
                    node = self.index_file(entry.path)

                    if node is None:
                        self.stats['files_skipped'] += 1
                    elif verbose and self.stats['files_indexed'] % 100 == 0:
                        print(f"  Indexed: {self.stats['files_indexed']} files...")
        except PermissionError:
            pass
        except Exception as e:
            self.stats['errors'] += 1

    def _extract_keywords(self, content: str) -> List[str]:
        """Extract meaningful keywords from content"""
        # Find all words
        words = re.findall(r'\b[a-zA-Z_][a-zA-Z0-9_]{2,}\b', content.lower())

        # Count frequencies
        freq: Dict[str, int] = {}
        for word in words:
            freq[word] = freq.get(word, 0) + 1

        # Filter stopwords and common programming terms
        stopwords = {
            'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can',
            'had', 'her', 'was', 'one', 'our', 'out', 'def', 'class', 'import',
            'from', 'return', 'self', 'none', 'true', 'false', 'else', 'elif',
            'try', 'except', 'with', 'this', 'that', 'have', 'has', 'been',
            'function', 'const', 'var', 'let', 'async', 'await', 'export'
        }

        # Sort by frequency, filter stopwords
        sorted_words = sorted(
            [(w, c) for w, c in freq.items() if w not in stopwords and len(w) > 2],
            key=lambda x: x[1],
            reverse=True
        )

        return [w for w, c in sorted_words]

    def _build_all_bridges(self):
        """Build B₂ bridges between all nodes"""
        for node_id in self.graph.nodes:
            bridges = self.graph.find_bridges(node_id)
            self.graph.nodes[node_id].bridges = bridges

    def search(self, query: str, limit: int = 10) -> List[Dict]:
        """
        Search the knowledge graph.

        Uses ΛG to find most coherent matches from YOUR knowledge.
        """
        nodes = self.graph.search(query, limit)

        return [{
            'file': node.file_path,
            'preview': node.content_preview[:200],
            'coherence': node.coherence,
            'keywords': node.keywords[:5],
            'bridges': len(node.bridges)
        } for node in nodes]

    def answer(self, question: str) -> Dict[str, Any]:
        """
        Answer a question using the knowledge graph.

        Instead of statistical generation, we:
        1. Search for relevant knowledge
        2. Apply ΛG to find most coherent answer
        3. Bridge concepts together

        "Answers emerge from YOUR knowledge"
        """
        # Search for relevant nodes
        relevant = self.graph.search(question, limit=20)

        if not relevant:
            return {
                'answer': 'No relevant knowledge found in your Mac.',
                'sources': [],
                'coherence': 0
            }

        # Combine top results
        combined_content = "\n\n".join([
            f"[From {node.file_path}]\n{node.content_preview}"
            for node in relevant[:5]
        ])

        # Calculate coherence of combined answer
        coherence = self.lambda_g.calculate_coherence(combined_content)

        return {
            'answer': combined_content,
            'sources': [node.file_path for node in relevant[:5]],
            'coherence': coherence.total_coherence,
            'is_vac': coherence.is_vac,
            'total_relevant': len(relevant)
        }


# Standalone test
if __name__ == "__main__":
    print("=" * 60)
    print("MAC KNOWLEDGE INDEXER TEST")
    print("'Your Mac IS the training data'")
    print("=" * 60)
    print()

    # Quick test with just BAZINGA directory
    indexer = MacKnowledgeIndexer(base_paths=[
        str(Path(__file__).parent.parent.parent.parent)  # BAZINGA dir
    ])

    graph = indexer.index_all(verbose=True)

    print()
    print("Testing search...")
    results = indexer.search("lambda coherence boundary")

    print(f"\nSearch results for 'lambda coherence boundary':")
    for r in results[:3]:
        print(f"  - {r['file']} (coherence: {r['coherence']:.3f})")
        print(f"    Keywords: {r['keywords']}")

    print()
    print("=" * 60)
