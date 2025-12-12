// test_deterministic_vs_quantum.ts

import PurePatternCommunication from './src/core/pure_pattern_communication';
import BazingaQuantumCore from './src/core/quantum-bazinga';

// Initialize both systems
const pureComm = new PurePatternCommunication();
const quantumCore = new BazingaQuantumCore();

// Test function to compare deterministic vs quantum interpretations
function compareInterpretations(message: string) {
  console.log(`\n=== COMPARING INTERPRETATIONS: "${message}" ===`);

  // Deterministic interpretation
  const patterns = pureComm.encodeMessage(message);
  const deterministic = pureComm.decodeMessage(patterns);

  console.log("Deterministic Patterns:", patterns.join(' '));
  console.log("Deterministic Interpretation:", deterministic);

  // Quantum interpretation (will have variation due to superposition)
  const quantum = [];
  for (let i = 0; i < 3; i++) {
    // Run multiple times to see variation
    const primaryPattern = patterns[0] || '10101';
    const quantumState = quantumCore.createSuperposition(
      quantumCore.patternToQuantumState(primaryPattern)
    );
    quantum.push(quantumState.resultState);
  }

  console.log("Quantum Interpretations:");
  quantum.forEach((result, i) => {
    console.log(`  Run ${i+1}: ${result} → ${pureComm.patternToEssence(result)}`);
  });

  // Sentiment comparison
  const sentiment = pureComm.analyzeSentiment(patterns);
  console.log("\nSentiment Analysis:");
  console.log(`  Score: ${sentiment.sentiment.toFixed(2)}`);
  console.log(`  Dominant: ${sentiment.dominant}`);

  // Generate visualization code
  console.log("\nGenerating Visualization Code:");
  const visualCode = generateVisualizationCode(message, patterns, quantum);
  console.log(visualCode.substring(0, 200) + "... [truncated]");
}

// Function to generate visualization code
function generateVisualizationCode(message: string, patterns: string[], quantum: string[]) {
  return `
// Visualization code for "${message}"
const data = {
  original: "${message}",
  patterns: ${JSON.stringify(patterns)},
  quantum: ${JSON.stringify(quantum)}
};

function createVisualization(container) {
  // Create SVG element
  const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  svg.setAttribute("width", "600");
  svg.setAttribute("height", "400");

  // Add pattern visualization
  let y = 50;
  data.patterns.forEach((pattern, i) => {
    // Create pattern rectangle
    const rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
    rect.setAttribute("x", "50");
    rect.setAttribute("y", String(y));
    rect.setAttribute("width", "500");
    rect.setAttribute("height", "30");
    rect.setAttribute("fill", "rgba(100, 149, 237, 0.2)");
    svg.appendChild(rect);

    // Add pattern text
    const text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    text.setAttribute("x", "60");
    text.setAttribute("y", String(y + 20));
    text.setAttribute("font-family", "monospace");
    text.textContent = pattern + " → " + (i < data.quantum.length ? data.quantum[i] : "");
    svg.appendChild(text);

    y += 40;
  });

  // Add quantum superposition visualization
  const qText = document.createElementNS("http://www.w3.org/2000/svg", "text");
  qText.setAttribute("x", "60");
  qText.setAttribute("y", String(y + 30));
  qText.setAttribute("font-family", "sans-serif");
  qText.setAttribute("fill", "purple");
  qText.textContent = "Quantum State: " + data.quantum.join(" | ");
  svg.appendChild(qText);

  container.appendChild(svg);
}`;
}

// Test with various messages
const testMessages = [
  "I understand you completely",
  "The connection between us transcends words",
  "Time and space cannot separate true resonance",
  "Your pattern makes sense even in silence",
  "This test compares deterministic and quantum interpretations"
];

// Run the tests
console.log("=== DETERMINISTIC VS QUANTUM INTERPRETATION TEST ===");
testMessages.forEach(compareInterpretations);

// Generate BAZINGA code using the pattern system
console.log("\n\n=== GENERATING BAZINGA CODE ===");
const bazingaCode = `
function calculateHarmonicResonance(pattern1, pattern2) {
  // Count matching bits
  let matches = 0;
  const minLength = Math.min(pattern1.length, pattern2.length);

  for (let i = 0; i < minLength; i++) {
    if (pattern1[i] === pattern2[i]) {
      matches++;
    }
  }

  return matches / minLength;
}

function createQuantumState(basePattern) {
  // Generate superposition
  const option1 = flipBit(basePattern, 1);
  const option2 = flipBit(basePattern, 3);

  // Calculate probabilities using golden ratio
  const phi = 1.618;
  const alpha = (1 / phi).toFixed(2);
  const beta = (1 - 1/phi).toFixed(2);

  return {
    base: basePattern,
    superposition: [option1, option2],
    amplitudes: [parseFloat(alpha), parseFloat(beta)],
    notation: \`\${basePattern}→(\${option1}|\${option2})→⟨\${alpha}|\${beta}⟩\`
  };
}

function flipBit(pattern, position) {
  const chars = pattern.split('');
  chars[position] = chars[position] === '0' ? '1' : '0';
  return chars.join('');
}`;

console.log(bazingaCode);
console.log("\nBAZINGA project integration complete!");















