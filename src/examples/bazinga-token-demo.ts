// src/examples/bazinga-token-demo.ts
import { TokenizedPatternCommunication } from '../core/bazinga-token-integration';

/**
 * Demonstration of the BAZINGA token integration system
 */
function demonstrateBazingaTokenIntegration() {
  console.log('=== BAZINGA Token Integration Demo ===');

  // Create the tokenized BAZINGA communication system
  const bazinga = new TokenizedPatternCommunication();

  // Sample messages for demonstration
  const message1 = 'Consciousness expands through quantum resonance patterns';
  const message2 = 'Harmonic vibrations create synchronistic connections';

  console.log('\n1. Basic Token Estimation:');
  console.log(`Message 1 estimated tokens: ${bazinga.estimateTokenCount(message1)}`);
  console.log(`Message 2 estimated tokens: ${bazinga.estimateTokenCount(message2)}`);

  console.log('\n2. Pattern Encoding with Token Tracking:');
  const patterns1 = bazinga.encodeMessage(message1);
  console.log('Encoded patterns:', patterns1);
  console.log('Token usage after encoding:', bazinga.getTokenUsage());

  console.log('\n3. Quantum Pattern Generation:');
  const quantumPattern = bazinga.createQuantumPattern(patterns1[0]);
  console.log('Quantum pattern:', quantumPattern);
  console.log('Token usage after quantum generation:', bazinga.getTokenUsage());

  console.log('\n4. Full Quantum Conversation:');
  const conversation = bazinga.createQuantumConversation(message1, message2);
  console.log(conversation);
  console.log('Token usage after conversation:', bazinga.getTokenUsage());

  console.log('\n5. Token Optimization Report:');
  const optimizationReport = bazinga.getTokenOptimizationReport();
  console.log(JSON.stringify(optimizationReport, null, 2));

  console.log('\n6. Token-Efficient Pattern Generation:');
  const efficientPatterns = [
    'wisdom',
    'connection',
    'harmony',
    'transcendence',
    'integration'
  ].map(concept => {
    const pattern = bazinga.generateTokenEfficientPattern(concept);
    return { concept, pattern };
  });

  console.log('Efficient patterns:');
  efficientPatterns.forEach(item => {
    console.log(`${item.concept}: ${item.pattern}`);
  });

  console.log('\n7. Final Token Usage:');
  console.log(bazinga.getTokenUsage());
  console.log(`Estimated cost: $${bazinga.calculateTokenCost().toFixed(6)}`);
}

// Execute the demonstration
demonstrateBazingaTokenIntegration();

// Export for module usage
export { demonstrateBazingaTokenIntegration };

