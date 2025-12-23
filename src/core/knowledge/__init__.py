"""
Knowledge Module - Mac-Based Knowledge Indexer

"Your Mac IS the training data"

Instead of training on external data, BAZINGA learns from YOUR files:
- Documents, code, conversations
- Uses ΛG coherence to index relevance
- B₂ bridges connect related knowledge
- Answers EMERGE from your own knowledge base
"""

from .mac_indexer import (
    MacKnowledgeIndexer,
    KnowledgeNode,
    KnowledgeGraph
)

__all__ = [
    'MacKnowledgeIndexer',
    'KnowledgeNode',
    'KnowledgeGraph'
]
