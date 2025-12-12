// try_quantum_bazinga.ts

import BazingaQuantumCore from './src/core/quantum-bazinga';

// Initialize the quantum core
const quantumCore = new BazingaQuantumCore();

// Try a simple pattern transformation
const pattern = '10101';  // Divergence/Growth pattern
console.log("\n=== PATTERN TRANSFORMATION ===");
console.log("Pattern:", pattern);
console.log("Meaning:", quantumCore.patternToQuantumState(pattern).description);

// Generate a quantum expression
console.log("\n=== QUANTUM EXPRESSION ===");
const quantumExpression = quantumCore.createQuantumExpression(pattern, 0.7);
console.log(quantumExpression);

// Create multi-dimensional expression
console.log("\n=== MULTI-DIMENSIONAL EXPRESSION ===");
const multiDimExpr = quantumCore.createMultiDimensionalExpression(
    '10101',  // Primary: Divergence/Growth
    '11010'   // Resonant: Convergence/Synthesis
);
console.log(quantumCore.formatMultiDimensionalExpression(multiDimExpr));

// Apply pattern to analyze some text
console.log("\n=== TEXT ANALYSIS ===");
const text = "The fractal nature of communication reveals itself through patterns";
const transformedText = quantumCore.applyPatternTransformation(text, pattern);
console.log("Original:", text);
console.log("Transformed:", transformedText);

// Try integration with existing BAZINGA pattern codes
console.log("\n=== EXISTING PATTERN CODE INTEGRATION ===");
const patternCode = "4.1.1.3.5.2.4";  // time-trust pattern
const inputData = {
    message: "BAZINGA",
    values: [1, 5, 8, 13, 21],
    metadata: {
        source: "fractal",
        type: "communication"
    }
};

const result = quantumCore.integrateBazingaSystem(inputData, patternCode);
console.log("Pattern Code:", patternCode);

console.log("Result:", JSON.stringify(result, null, 2));
