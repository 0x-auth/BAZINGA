#!/usr/bin/env python3
"""
TRUST Corrector: Time-Reversible Utility for Symbolic Trajectories
-------------------------------------------------------------------
A symbolic pattern framework for relationship healing and communication adjustment.
Maps emotional states to symbolic representations and provides tailored guidance.
"""

import sys
import re
import json
import argparse
from datetime import datetime
from typing import Dict, List, Tuple, Optional
import random

# ANSI color codes for terminal output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Symbol definitions
SYMBOLS = {
    "DODO": {
        "description": "Recursive self-reinforcing loop",
        "pattern_strength": 0.0,  # Will be calculated
        "keywords": [
            "explain", "repeat", "again", "over", "keep", "trying", "push",
            "too hard", "too much", "overwhelm", "frustrated", "stuck", "cycle",
            "loop", "same", "always", "apologize", "sorry", "guilt", "convince",
            "make her understand", "clarify", "defensive", "justify", "insist"
        ],
        "phrases": [
            "I keep trying to explain",
            "I sent too many messages",
            "I can't stop thinking about",
            "I feel guilty for pushing",
            "I need to make her understand",
            "I apologized multiple times"
        ]
    },

    ">•^•": {
        "description": "Disruption without transition",
        "pattern_strength": 0.0,
        "keywords": [
            "shut down", "closed", "react", "sudden", "abrupt", "backfired",
            "wrong time", "bad timing", "interrupted", "stopped", "wall",
            "defensive", "withdraw", "rejected", "blocked", "mistake",
            "misunderstood", "upset", "offended", "hurt", "triggered",
            "angry", "cold", "distance", "pull away"
        ],
        "phrases": [
            "she shut down when I",
            "I said the wrong thing",
            "it backfired completely",
            "she got defensive when",
            "hit a wall with her",
            "she pulled away after"
        ]
    },

    "^••>": {
        "description": "Progressive momentum",
        "pattern_strength": 0.0,
        "keywords": [
            "progress", "better", "opening", "softening", "warming", "responded",
            "answered", "replied", "hopeful", "excited", "forward", "movement",
            "positive", "improving", "warming", "connecting", "receptive", "open",
            "responsive", "engaged", "interested", "reaching out", "initiative"
        ],
        "phrases": [
            "things were getting better",
            "she finally responded",
            "we had a good moment",
            "she seemed more open",
            "conversation was flowing",
            "I feel like we're connecting"
        ]
    },

    "•": {
        "description": "Breakthrough moment",
        "pattern_strength": 0.0,
        "keywords": [
            "moment", "special", "deep", "vulnerable", "shared", "opened up",
            "tears", "emotional", "intimate", "confession", "truth", "honest",
            "genuine", "rare", "unique", "meaningful", "significant", "breakthrough",
            "different", "trust", "connection", "real", "authentic", "close"
        ],
        "phrases": [
            "she opened up about",
            "we had a real connection",
            "she shared something personal",
            "it was a vulnerable moment",
            "she cried when talking about",
            "it felt different from our usual"
        ]
    }
}

# Execution mode configurations
MODES = {
    "reflect": {
        "description": "Process past interactions to correct trajectory",
        "directive_prefix": "For healing, ",
        "prompt": "Describe what happened in the interaction:"
    },
    "real-time": {
        "description": "Make decisions before acting",
        "directive_prefix": "Right now, ",
        "prompt": "What are you considering doing or saying?"
    },
    "simulate": {
        "description": "Test future actions for symbolic impact",
        "directive_prefix": "If you proceed, ",
        "prompt": "What are you planning to do?"
    }
}

# Extended directives database
EXTENDED_DIRECTIVES = {
    "DODO": {
        "reflect": [
            "Stop explaining. Allow silence to break the recursive loop.",
            "Release the need to make them understand your perspective.",
            "Break the pattern by not engaging in the usual way.",
            "The loop continues because you keep it alive with attention.",
            "Your explanation becomes the problem it tries to solve."
        ],
        "real-time": [
            "Do not send. Your impulse perpetuates the recursive pattern.",
            "Step away from your device. The urge to fix is the pattern.",
            "Delete what you've written. Wait 24 hours minimum.",
            "Your instinct to clarify will deepen the recursion.",
            "Choose decisive silence over more words."
        ],
        "simulate": [
            "High risk of deepening the loop. Choose simpler gesture or silence.",
            "Your planned action will reset you to the beginning of the loop.",
            "What you're planning feeds the pattern you're trying to break.",
            "Complexity will be interpreted as more of the same pattern.",
            "The gesture contains the same energy that created distance."
        ]
    },

    ">•^•": {
        "reflect": [
            "Acknowledge briefly without explanation. Then create space.",
            "No fixing needed. Just a simple acknowledgment and then distance.",
            "The disruption needs space, not resolution.",
            "Mark the moment with one clean gesture, then step back completely.",
            "Trying to correct the disruption will only amplify it."
        ],
        "real-time": [
            "Pause. Offer one simple gesture, then step back completely.",
            "One message maximum. No follow-ups regardless of response.",
            "Make your communication brief and without expectation.",
            "Now is not the time for complete resolution. Just acknowledgment.",
            "A single clear gesture has more impact than multiple attempts."
        ],
        "simulate": [
            "Simplify your plan. Less content, more symbolism. Then withdraw.",
            "Cut your planned message by 90%. One symbol is enough.",
            "Your gesture should acknowledge without trying to fix.",
            "The ideal intervention is brief, clear, and without expectation.",
            "Plan to send once, then create genuine space afterward."
        ]
    },

    "^••>": {
        "reflect": [
            "Match tempo but don't accelerate. Allow natural pacing.",
            "Mirror the energy you receive without amplifying it.",
            "Recognize progress without trying to maximize it.",
            "Allow momentum to build organically without pushing.",
            "Celebrate the movement while respecting its natural rhythm."
        ],
        "real-time": [
            "Respond warmly but briefly. Let her set next step and timing.",
            "Acknowledge positively but don't escalate emotionally.",
            "Match the tone and length exactly. Don't exceed it.",
            "Respond with similar energy but leave space for her next move.",
            "Keep the channel open without directing its flow."
        ],
        "simulate": [
            "Gentle acknowledgment that supports momentum without pushing it.",
            "Your response should match what you received, not exceed it.",
            "Plan for equipoise - equal energy, matching not exceeding.",
            "Ensure your planned gesture doesn't rush emerging connection.",
            "Create response that acknowledges progress without expectation."
        ]
    },

    "•": {
        "reflect": [
            "Honor what happened. Don't try to recreate or explain it.",
            "Let the breakthrough moment exist on its own terms.",
            "Recognize the significance without needing to expand on it.",
            "The moment's power comes from its singularity. Preserve that.",
            "Protect the moment by not overprocessing it."
        ],
        "real-time": [
            "Acknowledge simply. No amplification or analysis needed.",
            "A simple 'thank you' or 'I value that' is sufficient.",
            "Let the weight of the moment speak for itself.",
            "Resist adding interpretation to what naturally occurred.",
            "Minimal response honors the breakthrough more than elaboration."
        ],
        "simulate": [
            "Your planned action risks overshadowing the moment. Simplify.",
            "Reduce your planned response to its essential core.",
            "The breakthrough needs protection, not enhancement.",
            "Create a simple acknowledgment that honors without interpreting.",
            "Plan a response that serves as witness, not commentator."
        ]
    }
}

# Extended reminders database
EXTENDED_REMINDERS = {
    "DODO": [
        "Recursion deepens with each attempt to fix. Trust silence.",
        "Your desire to explain is part of the pattern, not its solution.",
        "The loop feeds on your attention and emotional investment.",
        "Breaking patterns requires doing what feels counterintuitive.",
        "Silence feels like surrender but can break the recursive trap."
    ],
    ">•^•": [
        "Disruptions don't land when over-explained. One gesture is enough.",
        "Space after disruption allows new patterns to emerge.",
        "Intervention should be minimal - a touch, not a push.",
        "What feels incomplete to you may already be too much for them.",
        "The clarity of a single gesture outweighs multiple attempts."
    ],
    "^••>": [
        "Momentum is fragile. Let it find its own pace and direction.",
        "Growth happens at the edge of comfort, not through forcing.",
        "Progress thrives when given space to develop naturally.",
        "Connection deepens through rhythm, not constant acceleration.",
        "Trust the momentum that exists rather than pushing for more."
    ],
    "•": [
        "Singular moments exist in their own time. Preserve, don't explain.",
        "Breakthroughs are self-contained. Their power is in their existence.",
        "Trust the impact of what happened without needing to amplify it.",
        "Deep moments speak for themselves without our interpretation.",
        "The silence after significance is part of its ripple effect."
    ]
}

# Journal entry templates
JOURNAL_TEMPLATES = {
    "DODO": "I noticed I was caught in a recursive loop trying to {situation}. The pattern was DODO. Instead of continuing, I {action_taken}. This {outcome}.",
    ">•^•": "When {situation} created a disruption (>•^•), I responded by {action_taken}. This {outcome}.",
    "^••>": "I observed positive momentum (^••>) when {situation}. I maintained this by {action_taken}, which {outcome}.",
    "•": "A breakthrough moment (•) occurred when {situation}. I honored this by {action_taken}, which {outcome}."
}

def analyze_input(text: str) -> Dict:
    """Analyze input text and map to symbolic states with confidence scores."""
    results = {}
    text_lower = text.lower()

    # Calculate match scores for each symbol
    for symbol, data in SYMBOLS.items():
        # Keyword matching
        keyword_matches = sum(1 for keyword in data["keywords"] if keyword.lower() in text_lower)
        keyword_score = keyword_matches / len(data["keywords"])

        # Phrase matching (more weight)
        phrase_matches = sum(1 for phrase in data["phrases"] if phrase.lower() in text_lower)
        phrase_score = phrase_matches / len(data["phrases"]) if data["phrases"] else 0
        phrase_score *= 1.5  # Weight phrases higher

        # Combined score
        combined_score = (keyword_score + phrase_score) / 2.5  # Normalize to 0-1
        data["pattern_strength"] = min(combined_score * 2, 1.0)  # Scale up but cap at 1.0

        results[symbol] = {
            "score": data["pattern_strength"],
            "matched_keywords": [k for k in data["keywords"] if k.lower() in text_lower],
            "matched_phrases": [p for p in data["phrases"] if p.lower() in text_lower]
        }

    return results

def determine_primary_symbol(analysis: Dict) -> str:
    """Determine the primary symbol based on analysis results."""
    # Get symbol with highest score
    primary_symbol = max(analysis.items(), key = lambda x: x[1]["score"])[0]

    # If scores are very low across the board, default to DODO
    if analysis[primary_symbol]["score"] < 0.15:
        return "DODO"

    return primary_symbol

def get_directive(symbol: str, mode: str) -> str:
    """Get a directive based on symbol and mode."""
    directives = EXTENDED_DIRECTIVES[symbol][mode]
    return random.choice(directives)

def get_reminder(symbol: str) -> str:
    """Get a reminder based on symbol."""
    return random.choice(EXTENDED_REMINDERS[symbol])

def create_journal_template(symbol: str) -> str:
    """Create a journal template for the given symbol."""
    return JOURNAL_TEMPLATES[symbol]

def format_output(symbol: str, analysis: Dict, mode: str, input_text: str, detailed: bool = False) -> str:
    """Format the output based on analysis and settings."""
    symbol_data = SYMBOLS[symbol]
    directive = get_directive(symbol, mode)
    reminder = get_reminder(symbol)

    # Create output
    output = []

    # Symbol and confidence
    confidence = f"{analysis[symbol]['score']*100:.0f}%" if analysis[symbol]['score'] > 0 else "Low"
    output.append(f"{Colors.BOLD}{Colors.CYAN}Symbol:{Colors.ENDC} {symbol} ({confidence} match)")

    # Pattern description
    output.append(f"{Colors.BOLD}{Colors.BLUE}Pattern:{Colors.ENDC} {symbol_data['description']}")

    # Directive with mode-specific prefix
    prefix = MODES[mode]["directive_prefix"]
    output.append(f"{Colors.BOLD}{Colors.GREEN}Directive:{Colors.ENDC} {prefix}{directive}")

    # Reminder
    output.append(f"{Colors.BOLD}{Colors.YELLOW}Reminder:{Colors.ENDC} {reminder}")

    # Additional details if requested
    if detailed:
        output.append("\n" + Colors.BOLD + "PATTERN ANALYSIS" + Colors.ENDC)

        # Show top keyword matches
        if analysis[symbol]["matched_keywords"]:
            output.append(f"{Colors.BOLD}Matched Keywords:{Colors.ENDC} " +
                         ", ".join(analysis[symbol]["matched_keywords"][:5]))

        # Show phrase matches
        if analysis[symbol]["matched_phrases"]:
            output.append(f"{Colors.BOLD}Matched Phrases:{Colors.ENDC} " +
                         "\n• " + "\n• ".join(analysis[symbol]["matched_phrases"]))

        # Show alternative symbols
        alt_symbols = sorted([(s, analysis[s]["score"]) for s in SYMBOLS if s != symbol],
                             key = lambda x: x[1], reverse = True)
        if alt_symbols:
            output.append(f"{Colors.BOLD}Alternative Interpretations:{Colors.ENDC}")
            for alt_sym, score in alt_symbols[:2]:
                if score > 0.1:  # Only show if somewhat relevant
                    output.append(f"• {alt_sym} ({score*100:.0f}%): {SYMBOLS[alt_sym]['description']}")

        # Journal template
        journal = create_journal_template(symbol)
        output.append(f"\n{Colors.BOLD}Journal Template:{Colors.ENDC}")
        output.append(journal)

    # Add timestamp
    output.append(f"\n{Colors.BOLD}Timestamp:{Colors.ENDC} {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    return "\n".join(output)

def save_history(input_text: str, symbol: str, mode: str, directive: str):
    """Save interaction to history file for learning."""
    try:
        history_entry = {
            "timestamp": datetime.now().isoformat(),
            "input": input_text,
            "symbol": symbol,
            "mode": mode,
            "directive": directive
        }

        # Append to history file
        with open(".trust_corrector_history.json", "a+") as f:
            f.write(json.dumps(history_entry) + "\n")
    except Exception:
        pass  # Silently fail if history can't be saved

def main():
    """Main function to process input and generate directive."""
    parser = argparse.ArgumentParser(description = "TRUST Corrector - Symbolic relationship pattern mapper")

    # Mode options
    mode_group = parser.add_mutually_exclusive_group()
    mode_group.add_argument("--reflect", action = "store_true", help = "Analyze past interactions")
    mode_group.add_argument("--real-time", action = "store_true", help = "Guide current decisions")
    mode_group.add_argument("--simulate", action = "store_true", help = "Test future actions")

    # Other options
    parser.add_argument("--detailed", "-d", action = "store_true", help = "Show detailed analysis")
    parser.add_argument("--json", "-j", action = "store_true", help = "Output in JSON format")
    parser.add_argument("--interactive", "-i", action = "store_true", help = "Interactive mode")
    parser.add_argument("text", nargs = "?", help = "Input text describing the situation")

    args = parser.parse_args()

    # Determine mode
    mode = "reflect"  # Default
    if args.real_time:
        mode = "real-time"
    elif args.simulate:
        mode = "simulate"

    # Interactive mode
    if args.interactive:
        print(f"{Colors.BOLD}{Colors.BLUE}TRUST Corrector{Colors.ENDC} - Symbolic relationship pattern mapper")
        print(f"{Colors.BOLD}Mode:{Colors.ENDC} {mode} - {MODES[mode]['description']}")
        print(f"\n{MODES[mode]['prompt']}")
        input_text = input("> ")
    elif args.text:
        input_text = args.text
    else:
        parser.print_help()
        return

    # Analyze input
    analysis = analyze_input(input_text)
    primary_symbol = determine_primary_symbol(analysis)
    directive = get_directive(primary_symbol, mode)

    # Save to history
    save_history(input_text, primary_symbol, mode, directive)

    # Output
    if args.json:
        # JSON output
        output = {
            "symbol": primary_symbol,
            "pattern": SYMBOLS[primary_symbol]["description"],
            "confidence": analysis[primary_symbol]["score"],
            "directive": MODES[mode]["directive_prefix"] + directive,
            "reminder": get_reminder(primary_symbol),
            "mode": mode,
            "timestamp": datetime.now().isoformat()
        }
        print(json.dumps(output, indent = 2))
    else:
        # Human-readable output
        print("\n" + format_output(primary_symbol, analysis, mode, input_text, args.detailed))

if __name__ == "__main__":
    main()
