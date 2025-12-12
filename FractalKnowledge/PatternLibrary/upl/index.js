/**
 * Universal Pattern Library
 * Main entry point
 */

const PatternEngine = require('./core/PatternEngine');
const BaseDomainAdapter = require('./adapters/BaseDomainAdapter');
const AIConversationAdapter = require('./adapters/AIConversationAdapter');
const RelationshipAdapter = require('./adapters/RelationshipAdapter');
const SoftwareDevAdapter = require('./adapters/SoftwareDevAdapter');
const CrossPlatformAdapter = require('./adapters/CrossPlatformAdapter');
const BazingaIntegration = require('./integration/BazingaIntegration');
const PSpaceVisualizer = require('./visualization/PSpaceVisualizer');
const PatternVisualizer = require('./visualization/PatternVisualizer');

module.exports = {
  PatternEngine,
  BaseDomainAdapter,
  AIConversationAdapter,
  RelationshipAdapter,
  SoftwareDevAdapter,
  CrossPlatformAdapter,
  BazingaIntegration,
  PSpaceVisualizer,
  PatternVisualizer
};
