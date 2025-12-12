/**
 * fractal-lambda-test.ts
 *
 * Tests the integration of the Lambda system with Fractal patterns
 * Demonstrates how the five dimensions of DODO can be expressed
 * through fractal-derived lambda functions.
 *
 * DODO Pattern: 5.1.1.2.3.4.5.1
 * Encoding: 8.1.1.2.3.5.8.13
 */

import { createSignatureFromPattern } from '../core/fractals/MandelbrotSignature';
import { Lambda } from '../core/lambda';
import { TrustDimension, TrustLevel } from '../core/trust-dimension';
import { SelfModifyingExecutor } from '../core/self-modifying-executor';
import { FractalLambdaIntegrator } from '../core/fractals/FractalLambdaIntegrator';
import { FractalNumericalEncoder } from '../core/fractals/FractalNumericalEncoder';
import { BazingaUniversalTool } from '../core/bazinga/bazinga_universal';

// Test function for the fractal-lambda system
function testFractalLambdaSystem() {
  console.log("======= BAZINGA Fractal-Lambda System Test =======");
  console.log("Testing integration of fractal patterns with lambda calculus...");

  // Create the necessary components
  const bazingaTool = new BazingaUniversalTool();
  const fractalEncoder = new FractalNumericalEncoder(bazingaTool);
  const fractalLambda = new FractalLambdaIntegrator(fractalEncoder);

  // Generate a fractal signature from a seed pattern
  console.log("\nGenerating fractal signature from 'BAZINGA'...");
  const signature = createSignatureFromPattern("BAZINGA", 10);
  console.log(`Signature complexity: ${signature.calculateComplexity().toFixed(4)}`);

  // Map the signature to the five DODO dimensions
  console.log("\nMapping fractal signature to DODO dimensions:");
  const dimensionMap = signature.mapToDODODimensions();

  Object.entries(dimensionMap).forEach(([dimension, score]) => {
    console.log(`${dimension}-Dimension: ${score.toFixed(4)}`);
  });

  // Derive binary patterns from the fractal signature
  console.log("\nDeriving 5-bit patterns from fractal signature:");
  const patterns = signature.derivePatterns(5);

  patterns.forEach(pattern => {
    console.log(`Pattern: ${pattern}`);
  });

  // Generate lambdas from the patterns
  console.log("\nGenerating lambdas from fractal patterns:");

  const lambdaModels = fractalLambda.generateLambdaModelFromSignature(
    signature, 'MANDELBROT'
  );

  for (const [pattern, lambda] of lambdaModels.entries()) {
    const dimension = fractalLambda.mapLambdaToDODODimension(lambda);
    console.log(`Pattern ${pattern} -> ${lambda.toString()} (${dimension}-Dimension)`);

    // Test the lambda on a sample input
    const result = lambda.apply(5);
    console.log(`  λ(5) = ${result}`);
  }

  // Test the full dimensional lambda set
  console.log("\nTesting dimensional lambda set:");
  const dimensionalSet = fractalLambda.generateDimensionalLambdaSet();

  for (const [dimension, lambdaMap] of dimensionalSet.entries()) {
    console.log(`\n${dimension}-Dimension lambdas:`);

    // Take 3 samples from each dimension
    const samplePatterns = Array.from(lambdaMap.keys()).slice(0, 3);

    for (const pattern of samplePatterns) {
      const lambda = lambdaMap.get(pattern)!;
      console.log(`  Pattern ${pattern}: ${lambda.toString()}`);
      console.log(`    λ(10) = ${lambda.apply(10)}`);
    }
  }

  // Test the fractal encoding system
  console.log("\nTesting fractal numerical encoding:");

  // Generate an encoding from relationship analysis values
  const encoding = fractalLambda.generateFractalEncoding(
    1.55,    // witness-doer ratio (> phi is witness-dominant)
    0.25,    // perception-reality gap
    "Present" // temporal orientation
  );

  console.log(`Generated encoding: ${encoding}`);

  // Parse the encoding
  const decoded = fractalLambda.parseFractalEncoding(encoding);
  console.log("Decoded information:");
  console.log(decoded);

  // Test the fractal string processing
  console.log("\nTesting fractal string processing:");
  const inputString = "The universe is a fractal dream";
  const processedString = fractalLambda.processFractalString(inputString, 'FIBONACCI');

  console.log(`Original: "${inputString}"`);
  console.log(`Processed: "${processedString}"`);

  // Test the fractal-based DODO manifold
  console.log("\nGenerating DODO manifold using Mandelbrot mathematics:");
  const manifold = fractalLambda.generateDODOManifold(50);

  console.log(`  Generated ${manifold.points.length} points`);
  console.log(`  Complexity: ${manifold.calculateComplexity().toFixed(4)}`);
  console.log(`  Boundary ratio: ${manifold.calculateBoundaryRatio().toFixed(4)}`);

  const manifoldPatterns = manifold.derivePatterns(5);
  console.log(`  Key patterns: ${manifoldPatterns.join(', ')}`);

  // Test self-modifying execution with fractal patterns
  console.log("\nTesting self-modifying execution with fractal patterns:");

  const executor = new SelfModifyingExecutor();

  for (let i = 0; i < 5; i++) {
    const pattern = patterns[i % patterns.length];
    const input = i * 2 + 1;
    const result = executor.execute(pattern, input);

    console.log(`  Execute ${pattern} on ${input} = ${result}`);
  }

  // Test fractal transformation on a data series
  console.log("\nAnalyzing fractal dimension of data series:");

  // Generate a simple data series with fractal properties (Fibonacci-based)
  const fibSeries = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144];

  const { fractalDimension, recommendedLambdas } = fractalLambda.analyzeFractalDimension(fibSeries);

  console.log(`  Fractal dimension: ${fractalDimension.toFixed(4)}`);
  console.log("  Recommended lambdas:");

  for (const [pattern, lambda] of recommendedLambdas.entries()) {
    console.log(`    ${pattern}: ${lambda.toString()}`);
  }

  console.log("\n======= Test completed =======");
}

// Run the test
testFractalLambdaSystem();
