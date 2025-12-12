// src/tests/lambda-test.ts

import { Lambda } from '../core/lambda';
import { ExpansionRules } from '../core/lambda-rules';
import { TrustDimension, TrustLevel } from '../core/trust-dimension';
import { SelfModifyingExecutor } from '../core/self-modifying-executor';

/**
 * Simple test function for the lambda system
 */
function testLambdaSystem() {
  console.log("======= BAZINGA Lambda System Test =======");
  console.log("Testing the core Lambda implementation...");

  // Test basic Lambda functionality
  const lambda1 = Lambda.fromPattern('10101'); // Divergence/Growth (X-dimension)
  console.log(`Lambda '10101' applied to 5: ${lambda1.apply(5)}`); // Should be 6

  const lambda2 = Lambda.fromPattern('11010'); // Convergence/Synthesis (X-dimension)
  console.log(`Lambda '11010' applied to 5: ${lambda2.apply(5)}`); // Should be 10

  // Test lambda composition
  const composed = lambda1.compose(lambda2);
  console.log(`Composed lambda applied to 5: ${composed.apply(5)}`); // (5*2)+1 = 11

  // Test Z-dimension lambdas
  const lambdaZ = Lambda.fromPattern('11100'); // Context/Framing (Z-dimension)
  console.log(`Z-dimension lambda applied to 4: ${lambdaZ.apply(4)}`); // Should be 16 (4^2)

  // Test trust dimension lambdas
  console.log("\nTesting Trust Dimension (V-axis)...");
  const absoluteTrust = Lambda.fromPattern('11111'); // AbsoluteTrust
  console.log(`Absolute trust lambda applied to 100: ${absoluteTrust.apply(100)}`); // Should be 100

  const boundedTrust = Lambda.fromPattern('01110'); // TimeBoundTrust
  console.log(`Bounded trust lambda applied to 2000: ${boundedTrust.apply(2000)}`); // Should be 1000

  // Test the TrustDimension utility
  console.log("\nTesting TrustDimension utility...");
  const trustRule = TrustDimension.createTrustRule(TrustLevel.Bounded);
  console.log(`Bounded trust rule applied to 100: ${trustRule(100)}`);

  // Create a rule with a trust boundary
  const simpleRule = (x: number) => x * 10;
  const trustedRule = TrustDimension.applyTrustBoundary(simpleRule, TrustLevel.Bounded);
  console.log(`Rule with trust boundary applied to 100: ${trustedRule(100)}`);

  // Test self-modifying executor
  console.log("\nTesting SelfModifyingExecutor...");
  const executor = new SelfModifyingExecutor();

  // Execute some patterns
  console.log(`Executing pattern '10101' on 5: ${executor.execute('10101', 5)}`);
  console.log(`Executing pattern '11010' on 5: ${executor.execute('11010', 5)}`);

  // Execute more patterns to trigger pattern detection
  console.log("\nExecuting multiple patterns to test self-modification...");
  for (let i = 1; i <= 10; i++) {
    executor.execute('10101', i); // Execute the same pattern with sequential inputs
  }

  // Check executor state
  console.log("\nExecutor state after multiple executions:");
  console.log(executor.getState());

  console.log("\n======= Test completed =======");
}

// Run the test
testLambdaSystem();
