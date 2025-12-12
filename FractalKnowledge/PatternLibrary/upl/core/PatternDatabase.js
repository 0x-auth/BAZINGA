/tmp/upl-setup-1744566716/upl-integration-script.txt:class PatternDatabase {
/tmp/upl-setup-1744566716/upl-integration-script.txt-  constructor() {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    this.patterns = new Map();
/tmp/upl-setup-1744566716/upl-integration-script.txt-    this.domainPatterns = new Map();
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  /**
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * Add a pattern to the database
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @param {Object} pattern - The pattern object
/tmp/upl-setup-1744566716/upl-integration-script.txt-   */
/tmp/upl-setup-1744566716/upl-integration-script.txt-  addPattern(pattern) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    if (!pattern.id || !pattern.binarySignature) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-      throw new Error('Pattern must have id and binarySignature properties');
/tmp/upl-setup-1744566716/upl-integration-script.txt-    }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    // Store pattern in the main collection
/tmp/upl-setup-1744566716/upl-integration-script.txt-    this.patterns.set(pattern.id, pattern);
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    // Add to domain-specific collection if domain is specified
/tmp/upl-setup-1744566716/upl-integration-script.txt-    if (pattern.domain) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-      if (!this.domainPatterns.has(pattern.domain)) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-        this.domainPatterns.set(pattern.domain, new Map());
/tmp/upl-setup-1744566716/upl-integration-script.txt-      }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-      this.domainPatterns.get(pattern.domain).set(pattern.id, pattern);
/tmp/upl-setup-1744566716/upl-integration-script.txt-    }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    return pattern.id;
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  /**
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * Get a pattern by its ID
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @param {string} id - The pattern ID
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @returns {Object|null} The pattern or null if not found
/tmp/upl-setup-1744566716/upl-integration-script.txt-   */
/tmp/upl-setup-1744566716/upl-integration-script.txt-  getPatternById(id) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    return this.patterns.get(id) || null;
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  /**
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * Get patterns by domain
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @param {string} domain - The domain name
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @returns {Array} Array of patterns in the domain
/tmp/upl-setup-1744566716/upl-integration-script.txt-   */
/tmp/upl-setup-1744566716/upl-integration-script.txt-  getPatternsByDomain(domain) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    if (!this.domainPatterns.has(domain)) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-      return [];
/tmp/upl-setup-1744566716/upl-integration-script.txt-    }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    return Array.from(this.domainPatterns.get(domain).values());
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  /**
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * Find patterns matching a binary signature
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @param {string} binarySignature - The binary signature to match
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @param {number} [threshold = 0.8] - Similarity threshold (0-1)
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @returns {Array} Matching patterns
/tmp/upl-setup-1744566716/upl-integration-script.txt-   */
/tmp/upl-setup-1744566716/upl-integration-script.txt-  findPatterns(binarySignature, threshold = 0.8) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-    const matches = [];
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    // Check for exact match first
/tmp/upl-setup-1744566716/upl-integration-script.txt-    for (const pattern of this.patterns.values()) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-      if (pattern.binarySignature === binarySignature) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-        matches.push({
/tmp/upl-setup-1744566716/upl-integration-script.txt-          ...pattern,
/tmp/upl-setup-1744566716/upl-integration-script.txt-          similarity: 1.0
/tmp/upl-setup-1744566716/upl-integration-script.txt-        });
/tmp/upl-setup-1744566716/upl-integration-script.txt-      }
/tmp/upl-setup-1744566716/upl-integration-script.txt-    }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    // If exact match found, return it
/tmp/upl-setup-1744566716/upl-integration-script.txt-    if (matches.length > 0) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-      return matches;
/tmp/upl-setup-1744566716/upl-integration-script.txt-    }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    // Otherwise, find patterns with similar signatures
/tmp/upl-setup-1744566716/upl-integration-script.txt-    for (const pattern of this.patterns.values()) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-      const similarity = this.calculateSignatureSimilarity(
/tmp/upl-setup-1744566716/upl-integration-script.txt-        binarySignature,
/tmp/upl-setup-1744566716/upl-integration-script.txt-        pattern.binarySignature
/tmp/upl-setup-1744566716/upl-integration-script.txt-      );
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-      if (similarity >= threshold) {
/tmp/upl-setup-1744566716/upl-integration-script.txt-        matches.push({
/tmp/upl-setup-1744566716/upl-integration-script.txt-          ...pattern,
/tmp/upl-setup-1744566716/upl-integration-script.txt-          similarity
/tmp/upl-setup-1744566716/upl-integration-script.txt-        });
/tmp/upl-setup-1744566716/upl-integration-script.txt-      }
/tmp/upl-setup-1744566716/upl-integration-script.txt-    }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-    // Sort by similarity (highest first)
/tmp/upl-setup-1744566716/upl-integration-script.txt-    return matches.sort((a, b) => b.similarity - a.similarity);
/tmp/upl-setup-1744566716/upl-integration-script.txt-  }
/tmp/upl-setup-1744566716/upl-integration-script.txt-
/tmp/upl-setup-1744566716/upl-integration-script.txt-  /**
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * Calculate similarity between binary signatures
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @param {string} sig1 - First binary signature
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @param {string} sig2 - Second binary signature
/tmp/upl-setup-1744566716/upl-integration-script.txt-   * @returns {number} Similarity score (0-1)
/tmp/upl-setup-1744566716/upl-integration-script.txt-   */
