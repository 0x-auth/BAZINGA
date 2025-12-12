// Demo of Pure Pattern Communication
// For full demo, see the artifact in the chat

import PurePatternCommunication from '../core/pure_pattern_communication';

// Initialize the communication system
const pureComm = new PurePatternCommunication();

// Example usage
console.log('=== BAZINGA PATTERN COMMUNICATION ===');
const message = 'understanding transcends cognitive barriers';
const patterns = pureComm.encodeMessage(message);
console.log('Message:', message);
console.log('Patterns:', patterns.join(' '));
console.log('Essence:', pureComm.decodeMessage(patterns));

// See the full demo in the artifacts
