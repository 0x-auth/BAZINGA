/tmp/upl-setup-1744566716/upl-adapter-implementations.txt:class SoftwareDevAdapter extends BaseDomainAdapter {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-  constructor() {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    super('software_development');
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Keywords for dimension analysis
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    this.structureKeywords = [
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'pattern', 'architecture', 'design', 'structure', 'module',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'class', 'interface', 'abstract', 'implementation', 'component',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'service', 'layer', 'tier', 'mvc', 'framework', 'hierarchy', 'inheritance'
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    ];
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    this.temporalityKeywords = [
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'process', 'lifecycle', 'iteration', 'sprint', 'agile',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'waterfall', 'version', 'release', 'update', 'deprecated',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'legacy', 'evolve', 'phase', 'milestone', 'schedule', 'deadline'
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    ];
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    this.contextualityKeywords = [
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'environment', 'config', 'configuration', 'settings', 'context',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'runtime', 'compile-time', 'build', 'deployment', 'production',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'development', 'staging', 'testing', 'ci/cd', 'pipeline'
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    ];
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    this.emergenceKeywords = [
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'complexity', 'scale', 'distributed', 'microservice', 'cloud',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'orchestration', 'integration', 'system', 'emerge', 'ecosystem',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'platform', 'architecture', 'infrastructure', 'scalability'
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    ];
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    this.metaPropertiesKeywords = [
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'meta', 'reflection', 'introspection', 'meta-programming', 'code generation',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'self-modifying', 'dynamic', 'runtime', 'plugin', 'extension',
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      'aspect', 'decorator', 'annotation', 'attribute', 'middleware'
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    ];
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Script type identification
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    this.scriptTypePatterns = {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      bash: /\b(bash|sh|\bgrep\b|\bawk\b|\bsed\b|\bfind\b|\bxargs\b|\bcat\b|\becho\b|\bexport\b)/i,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      javascript: /\b(function|const|let|var|=>|async|await|import|require|module|exports|Promise)\b/i,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      python: /\b(def|import|from|class|if __name__ == ['"]__main__['"]|print\()\b/i,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      java: /\b(public|private|class|interface|void|static|final|extends|implements)\b/i,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      csharp: /\b(namespace|using|class|public|private|void|static|readonly|var|string)\b/i,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    };
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-  }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-  async analyzeScripts(scripts) {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Extract and combine data from multiple scripts
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const scriptData = {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scripts,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptTypes: {},
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      dependencies: {},
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      patterns: [],
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      metrics: {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-        totalLines: 0,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-        avgLineLength: 0,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-        complexityEstimate: 0,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-        structuralDensity: 0,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-        temporalComplexity: 0,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-        contextDependency: 0,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-        emergentComplexity: 0,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-        metaFunctionality: 0
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    };
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Process each script
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    for (const script of scripts) {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      const { content, filename } = script;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      const lines = content.split('\n');
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      // Determine script type
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      const scriptType = this.determineScriptType(content, filename);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.scriptTypes[script.path] = scriptType;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      // Count lines
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.metrics.totalLines += lines.length;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      // Calculate average line length
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      const totalCharCount = content.length;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      const avgLineLength = totalCharCount / Math.max(lines.length, 1);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.metrics.avgLineLength += avgLineLength;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      // Extract dependencies and imports
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      const deps = this.extractDependencies(content, scriptType);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      for (const dep of deps) {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-        scriptData.dependencies[dep] = (scriptData.dependencies[dep] || 0) + 1;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      // Extract patterns (function definitions, classes, etc.)
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      const patterns = this.extractPatterns(content, scriptType);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.patterns.push(...patterns);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      // Calculate metrics for this script
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.metrics.complexityEstimate += this.estimateComplexity(content, scriptType);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.metrics.structuralDensity += this.calculateStructuralDensity(content, scriptType);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.metrics.temporalComplexity += this.calculateTemporalComplexity(content, scriptType);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.metrics.contextDependency += this.calculateContextDependency(content, scriptType);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.metrics.emergentComplexity += this.calculateEmergentComplexity(content, scriptType);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.metrics.metaFunctionality += this.calculateMetaFunctionality(content, scriptType);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Normalize metrics
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const scriptCount = scripts.length;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    scriptData.metrics.avgLineLength /= scriptCount;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    scriptData.metrics.complexityEstimate /= scriptCount;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    scriptData.metrics.structuralDensity /= scriptCount;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    scriptData.metrics.temporalComplexity /= scriptCount;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    scriptData.metrics.contextDependency /= scriptCount;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    scriptData.metrics.emergentComplexity /= scriptCount;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    scriptData.metrics.metaFunctionality /= scriptCount;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    return scriptData;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-  }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-  async extractStructure(scriptData) {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    if (!scriptData || !scriptData.scripts) {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      return 0.5;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Structure is determined by:
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // 1. Organization patterns in code (functions, classes, modules)
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // 2. Dependency structure
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // 3. File organization
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Use previously calculated structural density
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const structuralDensity = scriptData.metrics.structuralDensity;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Analyze dependency graph complexity
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const dependencyComplexity = this.analyzeDependencyComplexity(scriptData.dependencies);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Analyze file organization
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const fileOrganization = this.analyzeFileOrganization(scriptData.scripts);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Keywords presence
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const keywordScore = this.analyzeKeywordsInScripts(
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.scripts,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      this.structureKeywords
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    );
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    return (
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      structuralDensity * 0.4 +
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      dependencyComplexity * 0.3 +
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      fileOrganization * 0.1 +
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      keywordScore * 0.2
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    );
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-  }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-  async extractTemporality(scriptData) {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    if (!scriptData || !scriptData.scripts) {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      return 0.5;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Temporality is determined by:
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // 1. Version control patterns (if available)
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // 2. Lifecycle management code
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // 3. Time-related functions and operations
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Use previously calculated temporal complexity
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const temporalComplexity = scriptData.metrics.temporalComplexity;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Analyze time-related functions
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const timeRelatedFunctions = this.analyzeTimeRelatedFunctions(scriptData.scripts);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Keywords presence
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const keywordScore = this.analyzeKeywordsInScripts(
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.scripts,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      this.temporalityKeywords
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    );
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    return (
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      temporalComplexity * 0.5 +
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      timeRelatedFunctions * 0.3 +
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      keywordScore * 0.2
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    );
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-  }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-  async extractContextuality(scriptData) {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    if (!scriptData || !scriptData.scripts) {
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      return 0.5;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    }
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Contextuality is determined by:
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // 1. Environment-specific code
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // 2. Configuration management
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // 3. Context-dependent behavior
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Use previously calculated context dependency
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const contextDependency = scriptData.metrics.contextDependency;
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Analyze environment checks
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const environmentChecks = this.analyzeEnvironmentChecks(scriptData.scripts);
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    // Keywords presence
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    const keywordScore = this.analyzeKeywordsInScripts(
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      scriptData.scripts,
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      this.contextualityKeywords
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    );
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-    return (
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      contextDependency * 0.5 +
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-      environmentChecks * 0.3 +
/tmp/upl-setup-1744566716/upl-adapter-implementations.txt-
