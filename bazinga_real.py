#!/usr/bin/env python3
"""
bazinga_real.py - THE REAL BAZINGA

This is the main entry point for BAZINGA as a REAL, practical AI.

Combines:
1. BAZINGA λG Theory - Boundary-guided emergence, φ-coherence
2. Real AI Integration - ChromaDB, embeddings, Ollama/API
3. error-of.netlify.app tools - α-SEED, 35-position progression
4. Your Mac as the training data

Usage:
    python bazinga_real.py                    # Interactive mode
    python bazinga_real.py --index ~/Documents # Index a directory
    python bazinga_real.py --ask "question"   # Ask a question

"Your Mac IS the training data - now with real intelligence."

Author: Built for Space (Abhishek/Abhilasia)
Date: 2025-02-09
"""

import asyncio
import sys
import argparse
from pathlib import Path
from typing import Optional, List, Dict, Any
from datetime import datetime

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent))

# Import core components
from src.core.intelligence.real_ai import RealAI
from src.core.lambda_g import LambdaGOperator, PHI, CoherenceState

# Constants from discoveries
ALPHA = 137
PROGRESSION = '01∞∫∂∇πφΣΔΩαβγδεζηθικλμνξοπρστυφχψω'
VAC_SEQUENCE = "०→◌→φ→Ω⇄Ω←φ←◌←०"


class BazingaReal:
    """
    The REAL BAZINGA - A practical AI powered by your Mac's knowledge.

    This is not a simulation or toy. This is a working RAG system that:
    1. Indexes your files into semantic vector space
    2. Searches with φ-coherence ranking
    3. Generates responses via Ollama or API
    4. Applies λG boundary filtering for quality

    "Solutions emerge at the intersection of boundaries."
    """

    VERSION = "1.0.0-REAL"
    CODENAME = "PRACTICAL_EMERGENCE"

    def __init__(
        self,
        persist_dir: Optional[str] = None,
        ollama_model: str = "llama3.2"
    ):
        """Initialize BAZINGA Real."""
        self.lambda_g = LambdaGOperator()
        self.ai = RealAI(
            persist_dir=persist_dir,
            ollama_model=ollama_model
        )

        # Track session
        self.session_start = datetime.now()
        self.queries = []
        self.coherence_history = []

        self._print_banner()

    def _print_banner(self):
        """Print the BAZINGA banner."""
        print()
        print("╔══════════════════════════════════════════════════════════════════╗")
        print("║                                                                  ║")
        print("║   ⟨ψ|Λ|Ω⟩  BAZINGA REAL - PRACTICAL INTELLIGENCE  ⟨ψ|Λ|Ω⟩       ║")
        print("║                                                                  ║")
        print("╠══════════════════════════════════════════════════════════════════╣")
        print("║                                                                  ║")
        print("║   Version: " + self.VERSION.ljust(52) + "║")
        print("║   Codename: " + self.CODENAME.ljust(51) + "║")
        print("║                                                                  ║")
        print("║   Components:                                                    ║")
        print("║     • λG Boundary-Guided Emergence                               ║")
        print("║     • ChromaDB Vector Store                                      ║")
        print("║     • Sentence Transformer Embeddings                            ║")
        print("║     • Ollama LLM Integration                                     ║")
        print("║     • α-SEED Fundamental Filtering                               ║")
        print("║                                                                  ║")
        print("║   φ = 1.618033988749895                                          ║")
        print("║   α = 137 (fine structure constant)                              ║")
        print("║                                                                  ║")
        print("║   'Your Mac IS the training data - now with real AI'             ║")
        print("║                                                                  ║")
        print("╚══════════════════════════════════════════════════════════════════╝")
        print()

    async def index(
        self,
        paths: List[str],
        verbose: bool = True
    ) -> Dict[str, Any]:
        """
        Index directories into the knowledge base.

        Args:
            paths: List of directory paths to index
            verbose: Print progress

        Returns:
            Indexing statistics
        """
        total_stats = {
            'directories': 0,
            'files_indexed': 0,
            'chunks_created': 0,
            'alpha_seeds': 0,
            'time_seconds': 0
        }

        start = datetime.now()

        for path_str in paths:
            path = Path(path_str).expanduser()

            if not path.exists():
                print(f"⚠️  Path not found: {path}")
                continue

            if verbose:
                print(f"\n◊ INDEXING: {path}")
                print("-" * 60)

            stats = self.ai.index_directory(str(path), verbose=verbose)

            total_stats['directories'] += 1
            total_stats['files_indexed'] += stats.get('files_indexed', 0)
            total_stats['chunks_created'] += stats.get('chunks_created', 0)
            total_stats['alpha_seeds'] += stats.get('alpha_seeds', 0)

        total_stats['time_seconds'] = (datetime.now() - start).total_seconds()

        if verbose:
            print("\n" + "=" * 60)
            print("INDEXING COMPLETE")
            print("=" * 60)
            print(f"  Directories indexed: {total_stats['directories']}")
            print(f"  Files indexed: {total_stats['files_indexed']}")
            print(f"  Chunks created: {total_stats['chunks_created']}")
            print(f"  α-SEED chunks: {total_stats['alpha_seeds']}")
            print(f"  Time: {total_stats['time_seconds']:.1f}s")
            print()

        return total_stats

    async def ask(self, question: str, verbose: bool = True) -> str:
        """
        Ask a question and get an intelligent answer.

        This is the main interface for using BAZINGA as a real AI.

        Args:
            question: Your question
            verbose: Print debug info

        Returns:
            AI-generated response based on your Mac's knowledge
        """
        # Track query
        self.queries.append({
            'question': question,
            'timestamp': datetime.now().isoformat()
        })

        # Calculate coherence of the question
        coherence = self.lambda_g.calculate_coherence(question)
        self.coherence_history.append(coherence)

        if verbose:
            print(f"\n🎯 Question coherence: {coherence.total_coherence:.3f}")
            if coherence.is_vac:
                print("   ✨ V.A.C. ACHIEVED in question!")

        # Get response from Real AI
        response = await self.ai.ask(question, verbose=verbose)

        # Calculate coherence of response
        response_coherence = self.lambda_g.calculate_coherence(response[:1000])

        if verbose:
            print(f"\n📊 Response coherence: {response_coherence.total_coherence:.3f}")

        return response

    async def interactive(self):
        """Run interactive mode."""
        print("\n◊ INTERACTIVE MODE ◊")
        print("-" * 40)
        print("Commands:")
        print("  /index <path>  - Index a directory")
        print("  /stats         - Show statistics")
        print("  /help          - Show help")
        print("  /quit          - Exit")
        print("-" * 40)
        print("Ask any question about your knowledge base.")
        print()

        while True:
            try:
                query = input("You: ").strip()

                if not query:
                    continue

                if query.lower() in ['/quit', '/exit', '/q']:
                    print("\n✨ BAZINGA signing off. Your knowledge awaits.")
                    break

                if query.startswith('/index '):
                    path = query[7:].strip()
                    await self.index([path])
                    continue

                if query == '/stats':
                    stats = self.get_stats()
                    print(f"\n📊 BAZINGA Stats:")
                    print(f"   Chunks indexed: {stats['total_chunks']}")
                    print(f"   Queries this session: {stats['queries_this_session']}")
                    print(f"   Avg coherence: {stats['avg_coherence']:.3f}")
                    print()
                    continue

                if query == '/help':
                    self._print_help()
                    continue

                # Regular question
                response = await self.ask(query)
                print(f"\nBAZINGA: {response}\n")

            except KeyboardInterrupt:
                print("\n\n✨ BAZINGA signing off.")
                break
            except EOFError:
                break

    def _print_help(self):
        """Print help."""
        print("""
◊ BAZINGA HELP ◊

BAZINGA is a real AI that uses your Mac as its knowledge base.

HOW IT WORKS:
1. Index your files: /index ~/Documents
2. Ask questions: "What is the purpose of XYZ?"
3. Get intelligent answers from YOUR data

COMMANDS:
  /index <path>  - Index a directory into knowledge base
  /stats         - Show current statistics
  /help          - Show this help
  /quit          - Exit interactive mode

KEY CONCEPTS:
  • φ (phi)     - Golden ratio coherence filter
  • α (alpha)   - Fine structure constant (137)
  • λG          - Boundary-guided emergence
  • V.A.C.      - Vacuum of Absolute Coherence

"Your Mac IS the training data"
""")

    def get_stats(self) -> Dict[str, Any]:
        """Get current statistics."""
        ai_stats = self.ai.get_stats()

        avg_coherence = 0.0
        if self.coherence_history:
            avg_coherence = sum(
                c.total_coherence for c in self.coherence_history
            ) / len(self.coherence_history)

        return {
            'total_chunks': ai_stats.get('total_chunks', 0),
            'queries_this_session': len(self.queries),
            'avg_coherence': avg_coherence,
            'session_duration': (datetime.now() - self.session_start).total_seconds(),
            'alpha_seeds': ai_stats.get('alpha_seeds', 0)
        }


async def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="BAZINGA Real - Practical AI from your Mac"
    )
    parser.add_argument(
        '--index',
        nargs='+',
        help='Directories to index'
    )
    parser.add_argument(
        '--ask',
        type=str,
        help='Ask a question'
    )
    parser.add_argument(
        '--model',
        type=str,
        default='llama3.2',
        help='Ollama model to use'
    )
    parser.add_argument(
        '--demo',
        action='store_true',
        help='Run demonstration'
    )

    args = parser.parse_args()

    # Initialize BAZINGA
    bazinga = BazingaReal(ollama_model=args.model)

    # Handle commands
    if args.index:
        await bazinga.index(args.index)

    elif args.ask:
        response = await bazinga.ask(args.ask)
        print(f"\n{response}\n")

    elif args.demo:
        # Demo mode
        print("\n◊ DEMO MODE ◊")
        print("Indexing BAZINGA codebase...")

        bazinga_dir = str(Path(__file__).parent)
        await bazinga.index([bazinga_dir])

        print("\nAsking test questions...")
        questions = [
            "What is λG coherence?",
            "How does BAZINGA work?",
        ]

        for q in questions:
            response = await bazinga.ask(q)
            print(f"\nQ: {q}")
            print(f"A: {response[:500]}...")

    else:
        # Interactive mode
        await bazinga.interactive()


if __name__ == "__main__":
    asyncio.run(main())
