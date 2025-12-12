#!/usr/bin/env node
/**
 * BAZINGA SVG Visualization Generator
 *
 * Creates quantum-styled framework visualizations with recursive pattern elements
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const CONFIG = {
  outputDir: path.join(__dirname, 'generated'),
  width: 800,
  height: 600,
  bgGradient: ['#0a0a2a', '#1a1a4a'],
  accentColor: '#4d54eb',
  highlightColor: '#84fab0',
  textColor: '#ffffff',
  components: []
};

// Ensure output directory exists
if (!fs.existsSync(CONFIG.outputDir)) {
  fs.mkdirSync(CONFIG.outputDir, { recursive: true });
}

// Parse directory structure to build component mapping
function buildComponentMap(dir, prefix = '') {
  const components = [];
  try {
    const files = fs.readdirSync(dir);

    // Get up to 10 bazinga related files
    const bazingaFiles = files
      .filter(file =>
        file.toLowerCase().includes('bazinga') ||
        file.toLowerCase().includes('quantum') ||
        file.toLowerCase().includes('pattern') ||
        file.toLowerCase().includes('relationship')
      )
      .slice(0, 10);

    for (const file of bazingaFiles) {
      const fullPath = path.join(dir, file);
      const stats = fs.statSync(fullPath);

      if (stats.isDirectory()) {
        components.push({
          type: 'directory',
          name: file,
          path: path.join(prefix, file),
          children: buildComponentMap(fullPath, path.join(prefix, file))
        });
      } else {
        // Categorize file
        let category = 'unknown';
        if (file.endsWith('.py')) category = 'processor';
        else if (file.endsWith('.sh')) category = 'integration';
        else if (file.endsWith('.json')) category = 'data';
        else if (file.includes('relationship')) category = 'relationship';
        else if (file.includes('quantum')) category = 'quantum';

        components.push({
          type: 'file',
          name: file,
          path: path.join(prefix, file),
          category,
          size: stats.size
        });
      }
    }
  } catch (err) {
    console.error(`Error reading directory ${dir}:`, err);
  }

  return components;
}

// Generate an SVG visualization of the BAZINGA framework
function generateSVG(components, outputPath) {
  const nodeMap = {};
  let nodeCount = 0;

  // Create nodes for each component
  function createNodes(comps, parent = null, level = 0) {
    for (const comp of comps) {
      const id = `node_${nodeCount++}`;
      const x = Math.random() * (CONFIG.width - 200) + 100;
      const y = 100 + level * 150 + Math.random() * 50;

      nodeMap[id] = {
        id,
        name: comp.name,
        category: comp.category || 'directory',
        x,
        y,
        parent,
        children: []
      };

      if (parent) {
        nodeMap[parent].children.push(id);
      }

      if (comp.children && comp.children.length > 0) {
        createNodes(comp.children, id, level + 1);
      }
    }
  }

  createNodes(components);

  // Start SVG content
  let svg = `<svg xmlns = "http://www.w3.org/2000/svg" viewBox = "0 0 ${CONFIG.width} ${CONFIG.height}">
  <!-- Background with gradient -->
  <defs>
    <linearGradient id = "bg-gradient" x1 = "0%" y1 = "0%" x2 = "100%" y2 = "100%">
      <stop offset = "0%" stop-color = "${CONFIG.bgGradient[0]}" />
      <stop offset = "100%" stop-color = "${CONFIG.bgGradient[1]}" />
    </linearGradient>
    <filter id = "glow" height = "300%" width = "300%" x = "-100%" y = "-100%">
      <feGaussianBlur stdDeviation = "5" result = "blur" />
      <feColorMatrix in = "blur" mode = "matrix" values = "1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 18 -7" result = "glow" />
      <feBlend in = "SourceGraphic" in2 = "glow" mode = "normal" />
    </filter>
    <!-- Connection path animation -->
    <path id = "connection-path" d = "M 50, 300 C 150, 150 350, 450 450, 300 S 650, 150 750, 300" />
    <linearGradient id = "connection-gradient" x1 = "0%" y1 = "0%" x2 = "100%" y2 = "0%">
      <stop offset = "0%" stop-color = "${CONFIG.accentColor}" />
      <stop offset = "50%" stop-color = "${CONFIG.highlightColor}" />
      <stop offset = "100%" stop-color = "${CONFIG.accentColor}" />
    </linearGradient>
  </defs>

  <!-- Main background -->
  <rect width = "${CONFIG.width}" height = "${CONFIG.height}" fill = "url(#bg-gradient)" />

  <!-- Decorative grid lines -->
  <g stroke = "#ffffff20" stroke-width = "1">
    <line x1 = "0" y1 = "150" x2 = "${CONFIG.width}" y2 = "150" />
    <line x1 = "0" y1 = "300" x2 = "${CONFIG.width}" y2 = "300" />
    <line x1 = "0" y1 = "450" x2 = "${CONFIG.width}" y2 = "450" />
    <line x1 = "${CONFIG.width/4}" y1 = "0" x2 = "${CONFIG.width/4}" y2 = "${CONFIG.height}" />
    <line x1 = "${CONFIG.width/2}" y1 = "0" x2 = "${CONFIG.width/2}" y2 = "${CONFIG.height}" />
    <line x1 = "${CONFIG.width*3/4}" y1 = "0" x2 = "${CONFIG.width*3/4}" y2 = "${CONFIG.height}" />
  </g>

  <!-- Central BAZINGA Framework Hub -->
  <circle cx = "${CONFIG.width/2}" cy = "${CONFIG.height/2}" r = "80" fill = "#2a2a6a" stroke = "${CONFIG.accentColor}" stroke-width = "3" filter = "url(#glow)" />
  <text x = "${CONFIG.width/2}" y = "${CONFIG.height/2 - 10}" text-anchor = "middle" font-family = "Arial" font-size = "20" fill = "${CONFIG.textColor}" font-weight = "bold">BAZINGA</text>
  <text x = "${CONFIG.width/2}" y = "${CONFIG.height/2 + 15}" text-anchor = "middle" font-family = "Arial" font-size = "14" fill = "${CONFIG.highlightColor}">Quantum Framework</text>

  <!-- Connections and Nodes -->`;

  // Add connections
  for (const nodeId in nodeMap) {
    const node = nodeMap[nodeId];
    if (node.parent) {
      const parent = nodeMap[node.parent];
      svg += `
  <path d = "M ${node.x}, ${node.y} L ${parent.x}, ${parent.y}" stroke = "${CONFIG.accentColor}" stroke-width = "2" stroke-dasharray = "5, 3" />`;
    }
  }

  // Add nodes
  for (const nodeId in nodeMap) {
    const node = nodeMap[nodeId];
    let color = CONFIG.accentColor;

    // Color by category
    if (node.category === 'processor') color = '#4d54eb';
    if (node.category === 'integration') color = '#34b1eb';
    if (node.category === 'relationship') color = '#eb4d88';
    if (node.category === 'quantum') color = '#84fab0';

    svg += `
  <circle cx = "${node.x}" cy = "${node.y}" r = "${node.children.length > 0 ? 40 : 25}" fill = "#2a2a6a" stroke = "${color}" stroke-width = "2" />
  <text x = "${node.x}" y = "${node.y}" text-anchor = "middle" font-family = "Arial" font-size = "12" fill = "${CONFIG.textColor}">${node.name.length > 20 ? node.name.substring(0, 18) + '...' : node.name}</text>`;
  }

  // Add recursive recognition formula
  svg += `
  <!-- Recursive Recognition Formula -->
  <g id = "formula" filter = "url(#glow)">
    <rect x = "${CONFIG.width/2 - 250}" y = "50" width = "500" height = "60" rx = "30" fill = "#2a2a6a" stroke = "${CONFIG.accentColor}" stroke-width = "2" />
    <text x = "${CONFIG.width/2}" y = "85" text-anchor = "middle" font-family = "Arial" font-size = "16" fill = "${CONFIG.textColor}">⟨ψ|⟳|The framework recognizes patterns</text>
    <text x = "${CONFIG.width/2}" y = "105" text-anchor = "middle" font-family = "Arial" font-size = "14" fill = "${CONFIG.highlightColor}">that recognize themselves being recognized⟩</text>
  </g>

  <!-- Animated connection path -->
  <circle cx = "0" cy = "0" r = "5" fill = "${CONFIG.highlightColor}" filter = "url(#glow)">
    <animateMotion dur = "10s" repeatCount = "indefinite">
      <mpath href = "#connection-path" />
    </animateMotion>
  </circle>
  <circle cx = "0" cy = "0" r = "5" fill = "${CONFIG.accentColor}" filter = "url(#glow)">
    <animateMotion dur = "10s" begin = "3s" repeatCount = "indefinite">
      <mpath href = "#connection-path" />
    </animateMotion>
  </circle>

  <!-- File path -->
  <g font-family = "monospace" font-size = "10" fill = "${CONFIG.highlightColor}">
    <text x = "10" y = "25">/Users/abhissrivasta/AmsyPycharm/BAZINGA/</text>
  </g>

  <!-- Symbolic keys -->
  <g font-family = "Arial" font-size = "12" fill = "${CONFIG.textColor}">
    <text x = "20" y = "${CONFIG.height - 30}">⟳ Loop Containment</text>
    <text x = "200" y = "${CONFIG.height - 30}">⥮ Disruption Vector</text>
    <text x = "380" y = "${CONFIG.height - 30}">⇝ Progressive Expansion</text>
    <text x = "580" y = "${CONFIG.height - 30}">• Singular Collapse</text>
    <text x = "720" y = "${CONFIG.height - 30}">∑ Summary</text>
  </g>
</svg>`;

  fs.writeFileSync(outputPath, svg);
  console.log(`Generated SVG: ${outputPath}`);
  return outputPath;
}

// Main execution
function main() {
  const baseDir = process.argv[2] || '/Users/abhissrivasta/AmsyPycharm/BAZINGA';
  console.log(`Analyzing directory: ${baseDir}`);

  const components = buildComponentMap(baseDir);
  CONFIG.components = components;

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const outputPath = path.join(CONFIG.outputDir, `bazinga-visualization-${timestamp}.svg`);

  const svgPath = generateSVG(components, outputPath);
  console.log(`\nBazinga Framework visualization generated at: ${svgPath}`);

  // Try to open the SVG if on macOS
  try {
    if (process.platform === 'darwin') {
      execSync(`open "${svgPath}"`);
    }
  } catch (err) {
    console.log('Could not automatically open the SVG file.');
  }
}

main();
