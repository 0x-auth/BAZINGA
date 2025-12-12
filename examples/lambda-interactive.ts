// examples/lambda-interactive.ts
//
// Interactive example demonstrating the BAZINGA Lambda-Driven Self-Modifying Execution
// System with Trust Dimension (V-axis) integration.

import { Lambda, TrustDimension, TrustLevel, SelfModifyingExecutor } from '../src';
import * as readline from 'readline';

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Create an executor with verified trust level by default
const executor = new SelfModifyingExecutor(undefined, TrustLevel.Verified);

// Display welcome banner
console.log(`
╭───────────────────────────────────────────────────────────────────────╮
│                                                                       │
│     BAZINGA Lambda Interactive - 5D Pattern Expansion System          │
│                                                                       │
│     Enter commands to interact with the lambda system:                │
│                                                                       │
│     1. execute <pattern> <number> - Execute a lambda pattern          │
│     2. trust <level>              - Set trust level                   │
│     3. dimensions                 - List dimensions and patterns      │
│     4. compose <pattern1> <pattern2> - Compose lambdas                │
│     5. state                      - Show executor state               │
│     6. help                       - Show this help                    │
│     7. exit                       - Exit the program                  │
│                                                                       │
╰───────────────────────────────────────────────────────────────────────╯
`);

// Display the current trust level
console.log(`Current trust level: ${TrustLevel[executor.getTrustLevel()]}\n`);

// Pattern descriptions
const patternDescriptions = {
  // X-Dimension (Structure)
  '10101': 'X-Dimension: Divergence/Growth (λx. x + 1)',
  '11010': 'X-Dimension: Convergence/Synthesis (λx. x * 2)',
  '01011': 'X-Dimension: Balance/Refinement (λx. x - 3)',

  // Y-Dimension (Temporality)
  '10111': 'Y-Dimension: Recency/Distribution (λx. x / 5)',
  '01100': 'Y-Dimension: BigPicture/Cycling (λx. x % 7)',

  // Z-Dimension (Contextuality)
  '11100': 'Z-Dimension: Context/Framing (λx. x^2)',
  '00111': 'Z-Dimension: Relation/Binding (λx. sqrt(|x|))',

  // W-Dimension (Emergence)
  '10110': 'W-Dimension: Transform/Emergence (λx. sin(πx/4))',
  '01101': 'W-Dimension: Pattern/Recognition (λx. log(|x|+1))',

  // V-Dimension (Trust)
  '11111': 'V-Dimension: AbsoluteTrust (λx. x)',
  '10001': 'V-Dimension: ConditionedTrust (λx. x ≥ 0 ? x : -x)',
  '01110': 'V-Dimension: TimeBoundTrust (λx. min(x, 1000))',
  '11011': 'V-Dimension: VerifiableTrust (λx. round(x*100)/100)',
  '00101': 'V-Dimension: TrustlessPattern (λx. isFinite(x) ? x : 0)'
};

// Trust level descriptions
const trustLevelDescriptions = {
  '0': 'None - No trust (returns constant)',
  '1': 'Minimal - Extreme bounds checking (-100 to 100)',
  '2': 'Bounded - Soft bounds with sigmoid-like function',
  '3': 'Verified - Precision control with rounding',
  '4': 'Conditional - Accepts within certain parameters',
  '5': 'Absolute - Complete trust (identity function)'
};

/**
 * Process user commands
 */
function processCommand(input: string): boolean {
  const parts = input.trim().split(/\s+/);
  const command = parts[0].toLowerCase();

  try {
    switch (command) {
      case 'execute':
        if (parts.length < 3) {
          console.log('Usage: execute <pattern> <number>');
          return true;
        }
        const pattern = parts[1];
        const number = parseFloat(parts[2]);

        if (isNaN(number)) {
          console.log('Invalid number');
          return true;
        }

        if (!/^[01]{5}$/.test(pattern)) {
          console.log('Pattern must be 5 bits (0s and 1s)');
          return true;
        }

        console.log(`Executing pattern '${pattern}' on input ${number}...`);
        if (patternDescriptions[pattern]) {
          console.log(`Pattern description: ${patternDescriptions[pattern]}`);
        }

        const result = executor.execute(pattern, number);
        console.log(`Result: ${result}`);
        return true;

      case 'trust':
        if (parts.length < 2) {
          console.log('Usage: trust <level>');
          console.log('Trust levels:');
          Object.entries(trustLevelDescriptions).forEach(([level, desc]) => {
            console.log(`  ${level}: ${desc}`);
          });
          return true;
        }

        const level = parseInt(parts[1]);
        if (isNaN(level) || level < 0 || level > 5) {
          console.log('Trust level must be between 0 and 5');
          return true;
        }

        executor.setTrustLevel(level);
        console.log(`Trust level set to ${TrustLevel[level]} (${level})`);
        console.log(`Description: ${trustLevelDescriptions[level.toString()]}`);
        return true;

      case 'dimensions':
        console.log('DODO Framework Five Dimensions:');
        console.log('\nX-Dimension: Structure (physical arrangement)');
        console.log('  10101: Divergence/Growth (λx. x + 1)');
        console.log('  11010: Convergence/Synthesis (λx. x * 2)');
        console.log('  01011: Balance/Refinement (λx. x - 3)');

        console.log('\nY-Dimension: Temporality (temporal relationship)');
        console.log('  10111: Recency/Distribution (λx. x / 5)');
        console.log('  01100: BigPicture/Cycling (λx. x % 7)');

        console.log('\nZ-Dimension: Contextuality (contextual relationship)');
        console.log('  11100: Context/Framing (λx. x^2)');
        console.log('  00111: Relation/Binding (λx. sqrt(|x|))');

        console.log('\nW-Dimension: Emergence (emergent properties)');
        console.log('  10110: Transform/Emergence (λx. sin(πx/4))');
        console.log('  01101: Pattern/Recognition (λx. log(|x|+1))');

        console.log('\nV-Dimension: Trust (trust relationship)');
        console.log('  11111: AbsoluteTrust (λx. x)');
        console.log('  10001: ConditionedTrust (λx. x ≥ 0 ? x : -x)');
        console.log('  01110: TimeBoundTrust (λx. min(x, 1000))');
        console.log('  11011: VerifiableTrust (λx. round(x*100)/100)');
        console.log('  00101: TrustlessPattern (λx. isFinite(x) ? x : 0)');

        console.log('\nAny other 5-bit pattern will generate a dynamic lambda expression');
        return true;

      case 'compose':
        if (parts.length < 3) {
          console.log('Usage: compose <pattern1> <pattern2>');
          return true;
        }

        const pattern1 = parts[1];
        const pattern2 = parts[2];

        if (!/^[01]{5}$/.test(pattern1) || !/^[01]{5}$/.test(pattern2)) {
          console.log('Patterns must be 5 bits (0s and 1s)');
          return true;
        }

        console.log(`Composing patterns '${pattern1}' and '${pattern2}'...`);
        if (patternDescriptions[pattern1]) {
          console.log(`Pattern 1: ${patternDescriptions[pattern1]}`);
        }
        if (patternDescriptions[pattern2]) {
          console.log(`Pattern 2: ${patternDescriptions[pattern2]}`);
        }

        const lambda1 = Lambda.fromPattern(pattern1);
        const lambda2 = Lambda.fromPattern(pattern2);
        const composed = lambda1.compose(lambda2);

        // Test the composed lambda with a value
        const testValue = 5;
        const result = composed.apply(testValue);

        console.log(`Composed lambda applied to ${testValue}: ${result}`);
        return true;

      case 'state':
        console.log(executor.getState());
        return true;

      case 'help':
        console.log(`
Commands:
  execute <pattern> <number> - Execute a lambda pattern
  trust <level>              - Set trust level
  dimensions                 - List dimensions and patterns
  compose <pattern1> <pattern2> - Compose lambdas
  state                      - Show executor state
  help                       - Show this help
  exit                       - Exit the program
        `);
        return true;

      case 'exit':
      case 'quit':
        console.log('Exiting Lambda Interactive');
        rl.close();
        return false;

      default:
        console.log(`Unknown command: ${command}`);
        console.log('Type "help" for available commands');
        return true;
    }
  } catch (error) {
    console.error(`Error: ${error.message}`);
    return true;
  }
}

/**
 * Main input loop
 */
function promptUser() {
  rl.question('λ> ', (input) => {
    if (processCommand(input)) {
      promptUser();
    }
  });
}

// Start the interactive session
promptUser();

// Handle cleanup
rl.on('close', () => {
  console.log('\nThank you for exploring the Lambda-Driven Self-Modifying Execution System!');
  process.exit(0);
});
