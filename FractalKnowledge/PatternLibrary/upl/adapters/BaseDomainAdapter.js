/tmp/upl-setup-1744566716/upl-integration-script.txt:class BaseDomainAdapter {
/tmp/upl-setup-1744566716/upl-integration-script.txt-  constructor(domain) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    this.domain = domain;
/tmp/upl-setup-1744566716/upl-integration-script.txt-    this.dimensionExtractors = {
/tmp/upl-setup-1744566716/upl-integration-script.txt-      structure: this.extractStructure.bind(this),
/tmp/upl-setup-1744566716/upl-integration-script.txt-      temporality: this.extractTemporality.bind(this),
/tmp/upl-setup-1744566716/upl-integration-script.txt-      contextuality: this.extractContextuality.bind(this),
/tmp/upl-setup-1744566716/upl-integration-script.txt-      emergence: this.extractEmergence.bind(this),
/tmp/upl-setup-1744566716/upl-integration-script.txt-      metaProperties: this.extractMetaProperties.bind(this)
/tmp/upl-setup-1744566716/upl-integration-script.txt-    };
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  async extractCoordinates(data) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    const coordinates = {};
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    // Extract each dimension's coordinate
/tmp/upl-setup-1744566716/upl-integration-script.txt-    for (const [dimension, extractor] of Object.entries(this.dimensionExtractors)) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-      coordinates[dimension] = await extractor(data);
/tmp/upl-setup-1744566716/upl-integration-script.txt-    }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    return coordinates;
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  // Default extractors to be overridden by domain-specific adapters
/tmp/upl-setup-1744566716/upl-integration-script.txt-  async extractStructure(data) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    throw new Error('extractStructure must be implemented by domain adapter');
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  async extractTemporality(data) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    throw new Error('extractTemporality must be implemented by domain adapter');
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  async extractContextuality(data) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    throw new Error('extractContextuality must be implemented by domain adapter');
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  async extractEmergence(data) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    throw new Error('extractEmergence must be implemented by domain adapter');
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  async extractMetaProperties(data) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    throw new Error('extractMetaProperties must be implemented by domain adapter');
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  // Utility function to normalize values to 0-1 range
/tmp/upl-setup-1744566716/upl-integration-script.txt-  normalize(value, min, max) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    if (min === max) return 0.5; // Default to middle if range is zero
/tmp/upl-setup-1744566716/upl-integration-script.txt-    return Math.min(1, Math.max(0, (value - min) / (max - min)));
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  // Utility for processing text patterns
/tmp/upl-setup-1744566716/upl-integration-script.txt-  analyzeTextPatterns(text, patternKeywords) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    const lowerText = text.toLowerCase();
/tmp/upl-setup-1744566716/upl-integration-script.txt-    let score = 0;
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    patternKeywords.forEach(keyword => {
/tmp/upl-setup-1744566716/upl-integration-script.txt-      if (lowerText.includes(keyword.toLowerCase())) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-        score += 1;
/tmp/upl-setup-1744566716/upl-integration-script.txt-      }
/tmp/upl-setup-1744566716/upl-integration-script.txt-    });
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    // Normalize to 0-1 range
/tmp/upl-setup-1744566716/upl-integration-script.txt-    return this.normalize(score, 0, patternKeywords.length);
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-}
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-module.exports = BaseDomainAdapter;
