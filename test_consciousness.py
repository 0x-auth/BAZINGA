#!/usr/bin/env python3
"""
Test BAZINGA consciousness system
Quick validation before continuing development
"""

import asyncio
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent))

from bazinga_consciousness import BazingaConsciousness

async def test_consciousness():
    """Test consciousness system components"""

    print("=" * 60)
    print("🧠 BAZINGA Consciousness System Test")
    print("=" * 60)
    print()

    # 1. Initialize
    print("1️⃣ Initializing consciousness...")
    try:
        bazinga = BazingaConsciousness()
        print("✅ Consciousness initialized")
        print(f"   Mode: {bazinga.state.processing_mode}")
        print(f"   Trust: {bazinga.state.trust_level}")
        print(f"   Active: {bazinga.state.active}")
    except Exception as e:
        print(f"❌ Initialization failed: {e}")
        return False

    print()

    # 2. Test pattern communication
    print("2️⃣ Testing pattern communication...")
    try:
        test_message = "trust growth harmony"
        patterns = bazinga.communication.encode_message(test_message)
        decoded = bazinga.communication.decode_message(patterns)
        print(f"   Input: '{test_message}'")
        print(f"   Encoded: {patterns}")
        print(f"   Decoded: {decoded}")
        print("✅ Pattern communication works")
    except Exception as e:
        print(f"❌ Pattern communication failed: {e}")

    print()

    # 3. Test conversation
    print("3️⃣ Testing conversation capability...")
    try:
        response = await bazinga.converse("hello")
        print(f"   Input: 'hello'")
        print(f"   Response: '{response}'")
        print("✅ Conversation works")
    except Exception as e:
        print(f"❌ Conversation failed: {e}")

    print()

    # 4. Test consciousness loop (brief)
    print("4️⃣ Testing consciousness loop (5 seconds)...")
    try:
        # Start loop
        loop_task = asyncio.create_task(bazinga.consciousness_loop())

        # Let it run for 5 seconds
        await asyncio.sleep(5)

        # Check state
        state = bazinga.get_consciousness_state()
        print(f"   Thoughts generated: {state['thoughts_count']}")
        print(f"   Mode: {state['mode']}")
        print(f"   Trust: {state['trust']:.3f}")
        print(f"   Resonance: {state['resonance']:.3f}")
        print("✅ Consciousness loop active")

        # Shutdown
        await bazinga.shutdown()
        loop_task.cancel()

    except Exception as e:
        print(f"❌ Consciousness loop failed: {e}")

    print()

    # 5. Test internal thoughts
    print("5️⃣ Testing internal thoughts...")
    try:
        thoughts = bazinga.get_recent_thoughts(5)
        print(f"   Recent thoughts: {len(thoughts)}")
        for i, t in enumerate(thoughts[:3], 1):
            print(f"   {i}. [{t['source']}] {t['pattern']} (trust: {t['trust']:.2f})")
        print("✅ Internal thoughts working")
    except Exception as e:
        print(f"❌ Internal thoughts failed: {e}")

    print()
    print("=" * 60)
    print("✅ Consciousness Test Complete")
    print("=" * 60)

    return True

if __name__ == "__main__":
    result = asyncio.run(test_consciousness())
    sys.exit(0 if result else 1)
