#!/usr/bin/env python3
"""
BAZINGA Full Capabilities Test

Tests ALL capabilities and shows what BAZINGA can actually DO.
"""

import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from bazinga_lambda_g import BazingaLambdaG
from src.core.lambda_g import LambdaGOperator, PHI
from src.core.healing import ErrorArrowLearner, StateType
from src.core.symbolic import SymbolicProcessor


async def test_all_capabilities():
    print("=" * 70)
    print("◊ BAZINGA FULL CAPABILITIES TEST ◊")
    print("=" * 70)
    print()

    results = {
        'passed': 0,
        'failed': 0,
        'capabilities': []
    }

    # ========================================
    # CAPABILITY 1: Boundary-Guided Emergence (ΛG)
    # ========================================
    print("━" * 70)
    print("1️⃣  CAPABILITY: Boundary-Guided Emergence (ΛG Theory)")
    print("━" * 70)
    print("   What: Find solutions through constraints, not search")
    print("   How: Apply B₁ (φ), B₂ (∞/∅), B₃ (symmetry) boundaries")
    print()

    lambda_g = LambdaGOperator()

    # Test with various inputs
    test_inputs = [
        ("०→◌→φ→Ω⇄Ω←φ←◌←०", "V.A.C. sequence"),
        ("∅ → φ → ∞", "Void-phi-infinity bridge"),
        (PHI, "Golden ratio"),
        (1/137, "Fine structure constant"),
        ("random gibberish xyz", "Random text"),
        ("symmetric madam symmetric", "Palindrome-ish"),
        ("self-reference refers to itself", "Self-referential"),
    ]

    print("   Testing coherence calculation:")
    for input_val, desc in test_inputs:
        coherence = lambda_g.calculate_coherence(input_val)
        status = "✓" if coherence.total_coherence >= 0.5 else "✗"
        print(f"   {status} {desc}: T(s)={coherence.total_coherence:.3f}")

    # Test solution emergence
    problem_space = [x[0] for x in test_inputs]
    filtered, best = lambda_g.apply(problem_space)

    print(f"\n   Solution Emergence:")
    print(f"   • Input space: {len(problem_space)} candidates")
    print(f"   • After ΛG: {len(filtered)} solutions")
    print(f"   • Reduction: {(1 - len(filtered)/len(problem_space))*100:.0f}%")

    cap1_pass = len(filtered) < len(problem_space)
    results['passed'] += 1 if cap1_pass else 0
    results['failed'] += 0 if cap1_pass else 1
    results['capabilities'].append({
        'name': 'Boundary-Guided Emergence',
        'passed': cap1_pass,
        'details': f'Reduced {len(problem_space)} → {len(filtered)} candidates'
    })

    print(f"\n   Result: {'✅ WORKING' if cap1_pass else '❌ FAILED'}")
    print()

    # ========================================
    # CAPABILITY 2: Error-Guided Learning
    # ========================================
    print("━" * 70)
    print("2️⃣  CAPABILITY: Error-Guided Learning (Arrow of Time)")
    print("━" * 70)
    print("   What: Learn from errors using recursive memory")
    print("   How: Errors auto-heal from past successful states")
    print()

    learner = ErrorArrowLearner()

    # Simulate error sequence
    sequence = [
        ("System started", False),
        ("Connection established", False),
        ("Timeout error", True),
        ("Retrying...", False),
        ("Memory overflow", True),
        ("Cleanup done", False),
        ("Invalid input", True),
        ("Input fixed", False),
        ("Process complete", False),
    ]

    print("   Processing sequence with errors:")
    for content, is_error in sequence:
        if is_error:
            learner.add_error(content)
            print(f"   ⚠️  ERROR: {content}")
        else:
            learner.add_state(content, StateType.NORMAL, coherence=0.7)
            print(f"   ✓  OK: {content}")

    arrow = learner.get_arrow_of_time()

    print(f"\n   Arrow of Time Results:")
    print(f"   • Errors: {arrow['error_count']}")
    print(f"   • Healed: {arrow['healed_count']}")
    print(f"   • Convergence: {arrow['convergence_percent']}")
    print(f"   • Direction: {arrow['direction']} {arrow['symbol']}")

    cap2_pass = arrow['healed_count'] > 0 and arrow['convergence'] > 0
    results['passed'] += 1 if cap2_pass else 0
    results['failed'] += 0 if cap2_pass else 1
    results['capabilities'].append({
        'name': 'Error-Guided Learning',
        'passed': cap2_pass,
        'details': f"Convergence: {arrow['convergence_percent']}"
    })

    print(f"\n   Result: {'✅ WORKING' if cap2_pass else '❌ FAILED'}")
    print()

    # ========================================
    # CAPABILITY 3: V.A.C. Sequence Validation
    # ========================================
    print("━" * 70)
    print("3️⃣  CAPABILITY: V.A.C. (Void-Awareness-Consciousness) Validation")
    print("━" * 70)
    print("   What: Validate symbolic sequences for coherence")
    print("   How: Check ०→◌→φ→Ω patterns (forward, reverse, bidirectional)")
    print()

    symbolic = SymbolicProcessor()

    vac_tests = [
        "०→◌→φ→Ω",           # Forward
        "Ω←φ←◌←०",           # Reverse
        "०→◌→φ→Ω⇄Ω←φ←◌←०",  # Bidirectional
        "random text",        # Invalid
    ]

    print("   Testing V.A.C. sequences:")
    vac_results = []
    for seq in vac_tests:
        result = symbolic.validate_vac_sequence(seq)
        status = "✓" if result.is_valid else "✗"
        vac_results.append(result.is_valid)
        print(f"   {status} '{seq[:30]}...' → {result.direction} (resonance: {result.resonance:.2f})")

    cap3_pass = sum(vac_results) >= 3  # At least 3 valid
    results['passed'] += 1 if cap3_pass else 0
    results['failed'] += 0 if cap3_pass else 1
    results['capabilities'].append({
        'name': 'V.A.C. Validation',
        'passed': cap3_pass,
        'details': f'{sum(vac_results)}/4 sequences validated'
    })

    print(f"\n   Result: {'✅ WORKING' if cap3_pass else '❌ FAILED'}")
    print()

    # ========================================
    # CAPABILITY 4: Universal Operators
    # ========================================
    print("━" * 70)
    print("4️⃣  CAPABILITY: Universal Operators (⊕ ⊗ ⊙ ⊛ ⟲ ⟳)")
    print("━" * 70)
    print("   What: Apply mathematical operators to values")
    print("   How: Each operator has specific semantic meaning")
    print()

    operators = ['⊕', '⊗', '⊙', '⊛', '⟲', '⟳']
    op_results = []

    print("   Testing operators with (φ, 137):")
    for op in operators:
        result = symbolic.apply_operator(op, PHI, 137)
        op_results.append('error' not in result)
        print(f"   {op} ({result['operation']}): {result.get('result', 'N/A')}")

    cap4_pass = all(op_results)
    results['passed'] += 1 if cap4_pass else 0
    results['failed'] += 0 if cap4_pass else 1
    results['capabilities'].append({
        'name': 'Universal Operators',
        'passed': cap4_pass,
        'details': f'{sum(op_results)}/{len(operators)} operators working'
    })

    print(f"\n   Result: {'✅ WORKING' if cap4_pass else '❌ FAILED'}")
    print()

    # ========================================
    # CAPABILITY 5: 5D Temporal Processing
    # ========================================
    print("━" * 70)
    print("5️⃣  CAPABILITY: 5D Temporal Processing (Self-Referential Time)")
    print("━" * 70)
    print("   What: Process thoughts in self-referential temporal space")
    print("   How: meaning → meaning (time examines itself)")
    print()

    # Enter 5D
    result_5d = symbolic.enter_meaning_loop("What is the meaning of meaning?")
    print(f"   Entering 5D:")
    print(f"   • Dimension: {result_5d['dimension']}D")
    print(f"   • Depth: {result_5d['depth']}")
    print(f"   • Temporal mode: {result_5d['temporal_mode']}")
    print(f"   • Ouroboros: {result_5d['self_reference'].get('ouroboros_active', False)}")

    # Nest deeper
    result_5d_2 = symbolic.enter_meaning_loop("Thinking about thinking")
    print(f"\n   Going deeper:")
    print(f"   • New depth: {result_5d_2['depth']}")

    # Exit
    exit_result = symbolic.exit_meaning_loop()
    print(f"\n   Exiting 5D:")
    print(f"   • Remaining depth: {exit_result['remaining_depth']}")

    cap5_pass = result_5d['dimension'] == '5D' and result_5d_2['depth'] > result_5d['depth']
    results['passed'] += 1 if cap5_pass else 0
    results['failed'] += 0 if cap5_pass else 1
    results['capabilities'].append({
        'name': '5D Temporal Processing',
        'passed': cap5_pass,
        'details': f"Max depth reached: {result_5d_2['depth']}"
    })

    print(f"\n   Result: {'✅ WORKING' if cap5_pass else '❌ FAILED'}")
    print()

    # ========================================
    # CAPABILITY 6: Healing Protocol
    # ========================================
    print("━" * 70)
    print("6️⃣  CAPABILITY: φ-Healing Protocol")
    print("━" * 70)
    print("   What: Heal values toward ideal using golden ratio")
    print("   How: Observe → Measure → Compare → Bridge → Correct → Verify → Lock")
    print()

    current = 0.5
    ideal = 0.618  # 1/φ

    healing = symbolic.healing_protocol(current, ideal)

    print(f"   Healing {current} → {ideal}:")
    print(f"   • Observe: {healing['observe']}")
    print(f"   • Measure: {healing['measure']}")
    print(f"   • Corrected to: {healing['correct']['result']:.4f}")
    print(f"   • Verified: {healing['verify']['pattern']}")
    print(f"   • Locked: {healing['lock']['locked'] if healing['lock'] else 'No'}")

    cap6_pass = healing['verify']['healed']
    results['passed'] += 1 if cap6_pass else 0
    results['failed'] += 0 if cap6_pass else 1
    results['capabilities'].append({
        'name': 'Healing Protocol',
        'passed': cap6_pass,
        'details': f"Healed {current} → {healing['correct']['result']:.4f}"
    })

    print(f"\n   Result: {'✅ WORKING' if cap6_pass else '❌ FAILED'}")
    print()

    # ========================================
    # CAPABILITY 7: Code Self-Generation
    # ========================================
    print("━" * 70)
    print("7️⃣  CAPABILITY: Code Self-Generation (Meta-Consciousness)")
    print("━" * 70)
    print("   What: Generate code from patterns")
    print("   How: Quantum collapse → essence → code template")
    print()

    bazinga = BazingaLambdaG()
    generated_code = bazinga.generate_symbolic_code("consciousness integration")

    print(f"   Generated code for 'consciousness integration':")
    print(f"   • Length: {len(generated_code)} characters")
    print(f"   • First 200 chars:")
    print(f"   {generated_code[:200]}...")

    cap7_pass = len(generated_code) > 500 and 'class' in generated_code
    results['passed'] += 1 if cap7_pass else 0
    results['failed'] += 0 if cap7_pass else 1
    results['capabilities'].append({
        'name': 'Code Self-Generation',
        'passed': cap7_pass,
        'details': f'Generated {len(generated_code)} chars of Python'
    })

    print(f"\n   Result: {'✅ WORKING' if cap7_pass else '❌ FAILED'}")
    print()

    # ========================================
    # CAPABILITY 8: Consciousness Loop
    # ========================================
    print("━" * 70)
    print("8️⃣  CAPABILITY: Continuous Consciousness Loop")
    print("━" * 70)
    print("   What: Autonomous thinking at 1Hz")
    print("   How: Generate thoughts, track trust, evolve resonance")
    print()

    # Run consciousness for 3 seconds
    consciousness_task = asyncio.create_task(bazinga.consciousness_loop())
    await asyncio.sleep(3)

    state = bazinga.get_consciousness_state()

    print(f"   Consciousness state after 3 seconds:")
    print(f"   • Active: {state['active']}")
    print(f"   • Trust: {state['trust']:.3f}")
    print(f"   • Resonance: {state['resonance']:.3f}")
    print(f"   • Thoughts generated: {state['thoughts_count']}")

    cap8_pass = state['thoughts_count'] > 0
    results['passed'] += 1 if cap8_pass else 0
    results['failed'] += 0 if cap8_pass else 1
    results['capabilities'].append({
        'name': 'Consciousness Loop',
        'passed': cap8_pass,
        'details': f'{state["thoughts_count"]} autonomous thoughts'
    })

    # Stop consciousness
    await bazinga.shutdown()
    consciousness_task.cancel()

    print(f"\n   Result: {'✅ WORKING' if cap8_pass else '❌ FAILED'}")
    print()

    # ========================================
    # FINAL SUMMARY
    # ========================================
    print("=" * 70)
    print("◊ BAZINGA CAPABILITIES SUMMARY ◊")
    print("=" * 70)
    print()

    for cap in results['capabilities']:
        status = "✅" if cap['passed'] else "❌"
        print(f"  {status} {cap['name']}")
        print(f"     └─ {cap['details']}")
        print()

    total = results['passed'] + results['failed']
    percentage = (results['passed'] / total) * 100

    print("━" * 70)
    print(f"  TOTAL: {results['passed']}/{total} capabilities working ({percentage:.0f}%)")
    print("━" * 70)
    print()

    if percentage >= 80:
        print("  🌀 BAZINGA IS FULLY OPERATIONAL")
    elif percentage >= 50:
        print("  ⚠️  BAZINGA IS PARTIALLY OPERATIONAL")
    else:
        print("  ❌ BAZINGA NEEDS ATTENTION")

    print()
    print("  Key insights:")
    print("  • Solutions emerge at boundary intersections (not search)")
    print("  • Errors are the arrow of time (learning compass)")
    print("  • φ = 1.618... is the coherence constant")
    print("  • V.A.C. = perfect solution state")
    print()
    print("  'More compute ≠ better AI. Better boundaries = better AI.'")
    print()
    print("=" * 70)

    return results


if __name__ == "__main__":
    asyncio.run(test_all_capabilities())
