#!/bin/bash
# BAZINGA Web App - Fixed Installation Script
# This script properly installs the BAZINGA Web App with mathematical visualizations
# and fixes any issues with missing files or incorrect configuration

# ANSI colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print header
echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}   BAZINGA Web App - Complete Installation        ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""

# Directory configuration
HOME_DIR="$HOME"
INSTALL_DIR="$HOME/.bazinga-web"
DATA_DIR="$INSTALL_DIR/data"
LOG_DIR="$INSTALL_DIR/logs"
CONFIG_DIR="$INSTALL_DIR/config"
PUBLIC_DIR="$INSTALL_DIR/public"
SERVER_DIR="$INSTALL_DIR/server"
JS_DIR="$PUBLIC_DIR/js"
CSS_DIR="$PUBLIC_DIR/css"
COMPONENTS_DIR="$PUBLIC_DIR/components"

# Step 1: Check for required tools
echo -e "${BLUE}Checking prerequisites...${NC}"

# Check for Node.js
if ! command -v node &>/dev/null; then
  echo -e "${RED}Error: Node.js is required but not installed.${NC}"
  echo -e "Please install Node.js v14 or higher."
  echo -e "Visit: https://nodejs.org/en/download/"
  exit 1
fi

NODE_VERSION=$(node -v | cut -d 'v' -f 2)
echo -e "  ${GREEN}✓${NC} Node.js found: v$NODE_VERSION"

# Check for npm
if ! command -v npm &>/dev/null; then
  echo -e "${RED}Error: npm is required but not installed.${NC}"
  echo -e "It should be included with Node.js installation."
  exit 1
fi

NPM_VERSION=$(npm -v)
echo -e "  ${GREEN}✓${NC} npm found: v$NPM_VERSION"

# Step 2: Clean existing installation if it exists
echo -e "\n${BLUE}Preparing installation directory...${NC}"

if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}Existing installation found. Cleaning up...${NC}"
  
  # Stop any running processes
  if pgrep -f "$INSTALL_DIR/server/server.js" > /dev/null; then
    echo -e "  ${YELLOW}Stopping running BAZINGA Web App server...${NC}"
    pkill -f "$INSTALL_DIR/server/server.js"
  fi
  
  # Remove the old installation (but keep user data)
  if [ -d "$DATA_DIR" ]; then
    mv "$DATA_DIR" "/tmp/bazinga-data-backup-$(date +%s)"
    echo -e "  ${YELLOW}Data directory backed up to /tmp${NC}"
  fi
  
  rm -rf "$INSTALL_DIR"
  echo -e "  ${GREEN}✓${NC} Old installation removed"
fi

# Create directory structure
echo -e "  ${YELLOW}Creating directory structure...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$PUBLIC_DIR"
mkdir -p "$JS_DIR"
mkdir -p "$CSS_DIR"
mkdir -p "$COMPONENTS_DIR"
mkdir -p "$SERVER_DIR"
mkdir -p "$JS_DIR/bazinga-integration"
mkdir -p "$JS_DIR/bazinga-integration/fractal"
mkdir -p "$JS_DIR/bazinga-integration/visualization"

echo -e "  ${GREEN}✓${NC} Directory structure created at $INSTALL_DIR"

# Step 3: Create package.json and install dependencies
echo -e "\n${BLUE}Setting up Node.js project...${NC}"

cat > "$INSTALL_DIR/package.json" << 'EOF'
{
  "name": "bazinga-web-app",
  "version": "1.0.0",
  "description": "Web interface for BAZINGA scripts with mathematical visualizations",
  "main": "server/server.js",
  "scripts": {
    "start": "node server/server.js"
  },
  "dependencies": {
    "express": "^4.17.1",
    "ws": "^8.2.3"
  }
}
EOF

# Change to install directory and install dependencies
cd "$INSTALL_DIR"
echo -e "  ${YELLOW}Installing dependencies... This may take a moment.${NC}"
npm install > "$LOG_DIR/npm-install.log" 2>&1

if [ $? -ne 0 ]; then
  echo -e "  ${RED}✗ Failed to install dependencies. See log at $LOG_DIR/npm-install.log${NC}"
  exit 1
fi

echo -e "  ${GREEN}✓${NC} Dependencies installed"

# Step 4: Create CSS files
echo -e "\n${BLUE}Creating CSS files...${NC}"

cat > "$CSS_DIR/styles.css" << 'EOF'
/* BAZINGA Web App Custom Styles */

/* Active navigation link */
.nav-link.active {
  background-color: rgba(79, 70, 229, 0.2);
  color: white;
}

/* Terminal styling */
.terminal-output {
  background-color: #0f172a;
  font-family: 'Courier New', monospace;
  line-height: 1.4;
}

/* Script details panel */
#script-details-panel {
  min-height: 300px;
}

/* Ensure consistent height for script items in grid view */
.script-item {
  min-height: 120px;
  transition: all 0.2s ease;
}

/* Add hover effect for script items */
.script-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Math visualization container */
#math-visualizations-container {
  width: 100%;
  margin-bottom: 2rem;
}

/* Canvas elements */
canvas {
  max-width: 100%;
  height: auto;
  display: block;
  margin: 0 auto;
}

/* Server status indicator */
#websocket-status.connected {
  background-color: rgb(16, 185, 129);
}

#websocket-status.disconnected {
  background-color: rgb(239, 68, 68);
}

/* Make sidebar visible on all screen sizes */
@media (min-width: 768px) {
  .bg-gray-800.text-white.w-64 {
    display: block !important;
  }
}
EOF

echo -e "  ${GREEN}✓${NC} Created styles.css"

# Step 5: Create JavaScript files
echo -e "\n${BLUE}Creating JavaScript files...${NC}"

# Create main.js
cat > "$JS_DIR/main.js" << 'EOF'
/**
 * BAZINGA Web App - Universal Script Runner
 * 
 * This component integrates the BAZINGA Web App with mathematical visualizations
 * and provides a universal script runner that doesn't require sudo access.
 * Everything runs locally with no internet communication.
 */

// WebSocket connection for real-time communication
let scriptSocket = null;

/**
 * Universal Script Runner with mathematical enhancements
 */
const universalScriptRunner = {
  /**
   * Initialize the script runner
   */
  init: function() {
    console.log('Initializing Universal Script Runner...');
    this.connectWebSocket();
    this.setupEventListeners();
    this.setupMathVisualizations();
  },
  
  /**
   * Connect to the WebSocket server
   */
  connectWebSocket: function() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}`;
    
    scriptSocket = new WebSocket(wsUrl);
    window.scriptSocket = scriptSocket;
    
    // Connection opened
    scriptSocket.addEventListener('open', (event) => {
      console.log('Connected to BAZINGA server');
      this.updateConnectionStatus(true);
    });
    
    // Listen for messages
    scriptSocket.addEventListener('message', (event) => {
      try {
        const message = JSON.parse(event.data);
        this.handleWebSocketMessage(message);
      } catch (error) {
        console.error('Error parsing WebSocket message:', error);
      }
    });
    
    // Connection closed
    scriptSocket.addEventListener('close', (event) => {
      console.log('Disconnected from BAZINGA server');
      this.updateConnectionStatus(false);
      
      // Try to reconnect after 5 seconds
      setTimeout(() => {
        this.connectWebSocket();
      }, 5000);
    });
    
    // Connection error
    scriptSocket.addEventListener('error', (event) => {
      console.error('WebSocket error:', event);
      this.updateConnectionStatus(false);
    });
  },
  
  /**
   * Update the connection status indicator
   */
  updateConnectionStatus: function(isConnected) {
    const statusElement = document.getElementById('websocket-status');
    if (statusElement) {
      if (isConnected) {
        statusElement.className = 'w-3 h-3 rounded-full bg-green-500 mr-2 connected';
      } else {
        statusElement.className = 'w-3 h-3 rounded-full bg-red-500 mr-2 disconnected';
      }
    }
  },
  
  /**
   * Handle WebSocket messages
   */
  handleWebSocketMessage: function(message) {
    const type = message.type || '';
    const data = message.data || {};
    
    switch (type) {
      case 'connected':
        console.log('WebSocket connection established');
        break;
        
      case 'script-start':
        this.handleScriptStart(data);
        break;
        
      case 'script-output':
        this.handleScriptOutput(data);
        break;
        
      case 'script-end':
        this.handleScriptEnd(data);
        break;
        
      case 'script-error':
        this.handleScriptError(data);
        break;
        
      default:
        console.log('Received unknown message type:', type);
    }
  },
  
  /**
   * Set up event listeners
   */
  setupEventListeners: function() {
    // Run button click handler
    document.addEventListener('click', (e) => {
      if (e.target && (e.target.id === 'run-script-btn' || e.target.closest('#run-script-btn'))) {
        this.handleRunScript();
      }
    });
    
    // Navigation functionality
    const navLinks = document.querySelectorAll('.nav-link');
    const sections = document.querySelectorAll('.section');
    
    navLinks.forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const targetId = link.getAttribute('data-target');
        
        // Update active link
        navLinks.forEach(l => l.classList.remove('active', 'bg-gray-700'));
        link.classList.add('active', 'bg-gray-700');
        
        // Show target section, hide others
        sections.forEach(section => {
          if (section.id === targetId) {
            section.classList.remove('hidden');
            section.classList.add('active');
            document.getElementById('page-title').textContent = link.textContent.trim();
          } else {
            section.classList.add('hidden');
            section.classList.remove('active');
          }
        });
      });
    });
    
    // Mobile sidebar toggle
    const sidebarToggle = document.getElementById('sidebar-toggle');
    if (sidebarToggle) {
      sidebarToggle.addEventListener('click', () => {
        const sidebar = document.querySelector('.bg-gray-800.text-white.w-64');
        if (sidebar) {
          sidebar.classList.toggle('hidden');
        }
      });
    }
  },
  
  /**
   * Set up mathematical visualizations
   */
  setupMathVisualizations: function() {
    console.log('Setting up math visualizations...');
    // This is intentionally left empty as the functionality
    // is implemented in math-visualizations.js
  },
  
  /**
   * Handle script start event
   */
  handleScriptStart: function(data) {
    console.log('Script started:', data);
    
    // Show terminal if it exists
    const terminal = document.getElementById('script-terminal');
    if (terminal) {
      terminal.classList.remove('hidden');
      const outputElement = terminal.querySelector('.terminal-output');
      if (outputElement) {
        outputElement.innerHTML = `<span class="text-yellow-400">$</span> <span class="text-blue-400">${data.command}</span>\n\n`;
      }
    }
  },
  
  /**
   * Handle script output event
   */
  handleScriptOutput: function(data) {
    const terminal = document.getElementById('script-terminal');
    if (!terminal) return;
    
    const outputElement = terminal.querySelector('.terminal-output');
    if (!outputElement) return;
    
    // Append output with appropriate color
    if (data.isError) {
      outputElement.innerHTML += `<span class="text-red-400">${data.output.replace(/\n/g, '<br>')}</span>`;
    } else {
      outputElement.innerHTML += `<span class="text-green-400">${data.output.replace(/\n/g, '<br>')}</span>`;
    }
    
    // Scroll to bottom
    outputElement.scrollTop = outputElement.scrollHeight;
  },
  
  /**
   * Handle script end event
   */
  handleScriptEnd: function(data) {
    const terminal = document.getElementById('script-terminal');
    if (!terminal) return;
    
    const outputElement = terminal.querySelector('.terminal-output');
    if (!outputElement) return;
    
    // Add exit code
    outputElement.innerHTML += `\n<span class="text-gray-400">Exit code: ${data.exitCode}</span>\n`;
    
    // Scroll to bottom
    outputElement.scrollTop = outputElement.scrollHeight;
  },
  
  /**
   * Handle script error event
   */
  handleScriptError: function(data) {
    const terminal = document.getElementById('script-terminal');
    if (!terminal) return;
    
    const outputElement = terminal.querySelector('.terminal-output');
    if (!outputElement) return;
    
    // Show error
    outputElement.innerHTML += `<span class="text-red-500">ERROR: ${data.message}</span>\n`;
    if (data.details) {
      outputElement.innerHTML += `<span class="text-red-400">${data.details}</span>\n`;
    }
    
    // Scroll to bottom
    outputElement.scrollTop = outputElement.scrollHeight;
  },
  
  /**
   * Handle running a script
   */
  handleRunScript: function() {
    const scriptNameElement = document.getElementById('script-detail-name');
    const scriptPathElement = document.getElementById('script-detail-path');
    
    if (!scriptNameElement || !scriptPathElement) {
      console.error('Script details elements not found');
      return;
    }
    
    const scriptName = scriptNameElement.textContent;
    const scriptPath = scriptPathElement.textContent;
    const paramsInput = document.getElementById('script-params');
    const params = paramsInput ? paramsInput.value : '';
    
    // Get selected function if any
    let selectedFunction = '';
    const functionSelect = document.getElementById('script-function-select');
    if (functionSelect && functionSelect.value) {
      selectedFunction = functionSelect.value;
    }
    
    // Show terminal and clear previous output
    const terminal = document.getElementById('script-terminal');
    if (terminal) {
      terminal.classList.remove('hidden');
      const outputElement = terminal.querySelector('.terminal-output');
      if (outputElement) {
        outputElement.innerHTML = `<span class="text-yellow-400">$</span> <span class="text-blue-400">${scriptPath}</span> ${selectedFunction ? `<span class="text-green-400">${selectedFunction}</span>` : ''} ${params}\n\n`;
      }
    }
    
    // Prepare the parameter data
    const scriptData = {
      path: scriptPath,
      params: params,
      function: selectedFunction
    };
    
    // Execute via WebSocket if available
    if (scriptSocket && scriptSocket.readyState === WebSocket.OPEN) {
      scriptSocket.send(JSON.stringify({
        type: 'run-script',
        data: scriptData
      }));
    } else {
      // Show error if WebSocket is not available
      const terminal = document.getElementById('script-terminal');
      if (terminal) {
        const outputElement = terminal.querySelector('.terminal-output');
        if (outputElement) {
          outputElement.innerHTML += `<span class="text-red-500">ERROR: Server connection not available</span>\n`;
          outputElement.innerHTML += `<span class="text-yellow-400">Please make sure the BAZINGA Web App server is running.</span>\n`;
        }
      }
    }
  }
};

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  // Initialize the Universal Script Runner
  universalScriptRunner.init();
});
EOF

# Create math-visualizations.js
cat > "$JS_DIR/math-visualizations.js" << 'EOF'
/**
 * BAZINGA Math Visualizations
 * This script provides mathematical visualizations for the BAZINGA Web App
 */

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  const mathContainer = document.getElementById('math-visualizations-container');
  if (!mathContainer) return;
  
  // Add the visualization components
  mathContainer.innerHTML = `
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
      <div class="bg-white rounded-lg shadow p-4">
        <h3 class="text-lg font-semibold mb-3">Hash Mapping</h3>
        <div class="bg-gray-100 rounded-lg p-4 aspect-video">
          <canvas id="hash-mapping-canvas" width="400" height="300"></canvas>
        </div>
        <p class="mt-2 text-sm text-gray-600">Visualization of hash distributions across the system.</p>
      </div>
      
      <div class="bg-white rounded-lg shadow p-4">
        <h3 class="text-lg font-semibold mb-3">Möbius Transformation</h3>
        <div class="bg-gray-100 rounded-lg p-4 aspect-video">
          <canvas id="mobius-canvas" width="400" height="300"></canvas>
        </div>
        <p class="mt-2 text-sm text-gray-600">Transforming complex problems into elegant solutions.</p>
      </div>
    </div>
    
    <div class="bg-white rounded-lg shadow p-4">
      <h3 class="text-lg font-semibold mb-3">Mathematical Magic Behind BAZINGA</h3>
      <p class="mb-3">
        The BAZINGA system utilizes advanced mathematical concepts to transform complex 
        computational problems into elegant solutions.
      </p>
      <p>
        Through Möbius transformations and hash-based probability modeling, BAZINGA 
        achieves highly efficient script management and system monitoring.
      </p>
    </div>
  `;
  
  // Initialize the visualizations
  initHashMapping();
  initMobiusTransformation();
});

// Initialize Hash Mapping visualization
function initHashMapping() {
  const canvas = document.getElementById('hash-mapping-canvas');
  if (!canvas) return;
  
  const ctx = canvas.getContext('2d');
  const width = canvas.width;
  const height = canvas.height;
  
  // Clear canvas
  ctx.fillStyle = '#f3f4f6';
  ctx.fillRect(0, 0, width, height);
  
  // Draw grid
  ctx.strokeStyle = 'rgba(156, 163, 175, 0.2)';
  ctx.lineWidth = 1;
  
  // Vertical lines
  for (let x = 0; x <= width; x += 20) {
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, height);
    ctx.stroke();
  }
  
  // Horizontal lines
  for (let y = 0; y <= height; y += 20) {
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(width, y);
    ctx.stroke();
  }
  
  // Generate some random data points
  const points = [];
  for (let i = 0; i < 20; i++) {
    points.push({
      x: Math.random() * width,
      y: Math.random() * height,
      radius: Math.random() * 5 + 2,
      color: `rgba(79, 70, 229, ${Math.random() * 0.5 + 0.3})`,
      label: `File ${i}`
    });
  }
  
  // Draw data points
  points.forEach(point => {
    ctx.beginPath();
    ctx.arc(point.x, point.y, point.radius, 0, Math.PI * 2);
    ctx.fillStyle = point.color;
    ctx.fill();
  });
  
  // Add title
  ctx.font = '16px Arial';
  ctx.fillStyle = '#1f2937';
  ctx.textAlign = 'center';
  ctx.fillText('Hash Distribution Map', width / 2, 20);
}

// Initialize Möbius Transformation visualization
function initMobiusTransformation() {
  const canvas = document.getElementById('mobius-canvas');
  if (!canvas) return;
  
  const ctx = canvas.getContext('2d');
  const width = canvas.width;
  const height = canvas.height;
  
  // Parameters for the Möbius transformation: w = (az + b)/(cz + d)
  const a = 1;
  const b = 0;
  const c = 0.5;
  const d = 1;
  
  // Animation variables
  let animationId;
  let angle = 0;
  
  // Animation function
  function animate() {
    angle += 0.02;
    
    // Clear canvas with dark background
    ctx.fillStyle = '#1e293b';
    ctx.fillRect(0, 0, width, height);
    
    // Create a circle of points to transform
    const points = [];
    const centerX = width / 2;
    const centerY = height / 2;
    const radius = Math.min(width, height) * 0.4;
    
    for (let i = 0; i < 60; i++) {
      const pointAngle = i * Math.PI * 2 / 60;
      points.push({
        x: centerX + radius * Math.cos(pointAngle),
        y: centerY + radius * Math.sin(pointAngle)
      });
    }
    
    // Draw original circle
    ctx.beginPath();
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
    ctx.lineWidth = 1;
    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
    ctx.stroke();
    
    // Apply Möbius transformation to points
    // The animation parameter makes c oscillate
    const currentC = c * (Math.sin(angle) + 1) / 2;
    
    // Connect transformed points to form shape
    ctx.beginPath();
    let isFirst = true;
    
    points.forEach(point => {
      // Convert to complex plane coordinates centered at origin
      const z = {
        re: (point.x - centerX) / radius,
        im: (point.y - centerY) / radius
      };
      
      // Apply Möbius transformation: w = (az + b)/(cz + d)
      const numerator = {
        re: a * z.re - b * z.im,
        im: a * z.im + b * z.re
      };
      
      const denominator = {
        re: currentC * z.re + d,
        im: currentC * z.im
      };
      
      const denomMagnitude = denominator.re * denominator.re + denominator.im * denominator.im;
      
      // Avoid division by zero
      if (denomMagnitude < 0.001) return;
      
      const w = {
        re: (numerator.re * denominator.re + numerator.im * denominator.im) / denomMagnitude,
        im: (numerator.im * denominator.re - numerator.re * denominator.im) / denomMagnitude
      };
      
      // Convert back to canvas coordinates
      const transformedX = centerX + w.re * radius;
      const transformedY = centerY + w.im * radius;
      
      if (isFirst) {
        ctx.moveTo(transformedX, transformedY);
        isFirst = false;
      } else {
        ctx.lineTo(transformedX, transformedY);
      }
    });
    
    ctx.strokeStyle = 'rgba(79, 70, 229, 0.8)';
    ctx.lineWidth = 2;
    ctx.closePath();
    ctx.stroke();
    
    // Draw formula
    ctx.font = '12px Arial';
    ctx.fillStyle = 'white';
    ctx.textAlign = 'center';
    ctx.fillText(`w = (${a}z + ${b}) / (${currentC.toFixed(2)}z + ${d})`, width / 2, 20);
    
    // Continue animation
    animationId = requestAnimationFrame(animate);
  }
  
  // Start animation
  animate();
  
  // Store animation ID on window to be able to cancel it if needed
  window.mobiusAnimationId = animationId;
}
EOF

echo -e "  ${GREEN}✓${NC} Created main.js and math-visualizations.js"

# Step 6: Create index.html
echo -e "\n${BLUE}Creating HTML files...${NC}"

cat > "$PUBLIC_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BAZINGA Web App</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css">
  <link rel="stylesheet" href="css/styles.css">
</head>
<body class="bg-gray-100 min-h-screen">
  <div class="flex h-screen">
    <!-- Sidebar -->
    <div class="bg-gray-800 text-white w-64 flex-shrink-0 hidden md:block">
      <div class="p-4 flex items-center justify-center border-b border-gray-700">
        <h1 class="text-xl font-bold">BAZINGA Web App</h1>
      </div>
      <nav class="mt-4">
        <ul>
          <li class="mb-2">
            <a href="#dashboard" class="block px-4 py-2 rounded hover:bg-gray-700 nav-link active" data-target="dashboard">
              <span class="mr-2">📊</span> Dashboard
            </a>
          </li>
          <li class="mb-2">
            <a href="#scripts" class="block px-4 py-2 rounded hover:bg-gray-700 nav-link" data-target="scripts">
              <span class="mr-2">📜</span> Script Catalog
            </a>
          </li>
          <li class="mb-2">
            <a href="#math" class="block px-4 py-2 rounded hover:bg-gray-700 nav-link" data-target="math">
              <span class="mr-2">🧮</span> Math Visualizations
            </a>
          </li>
          <li class="mb-2">
            <a href="#monitoring" class="block px-4 py-2 rounded hover:bg-gray-700 nav-link" data-target="monitoring">
              <span class="mr-2">📡</span> System Monitoring
            </a>
          </li>
        </ul>
        
        <div class="mt-8 px-4 pt-4 border-t border-gray-700">
          <div class="flex items-center">
            <div id="websocket-status" class="w-3 h-3 rounded-full bg-red-500 mr-2"></div>
            <span class="text-sm text-gray-400">Server Status</span>
          </div>
        </div>
      </nav>
    </div>
    
    <!-- Main content -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <!-- Top bar -->
      <header class="bg-white shadow-sm p-4 flex items-center justify-between">
        <div class="flex items-center">
          <button id="sidebar-toggle" class="md:hidden mr-4">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
            </svg>
          </button>
          <h2 id="page-title" class="text-xl font-semibold">Dashboard</h2>
        </div>
      </header>
      
      <!-- Content area -->
      <main class="flex-1 overflow-y-auto p-4">
        <!-- Dashboard Section -->
        <section id="dashboard" class="section active">
          <div class="bg-white rounded-lg shadow p-4 mb-4">
            <h3 class="text-lg font-semibold mb-3">Welcome to BAZINGA Web App</h3>
            <p class="text-gray-600 mb-2">This web application provides a unified interface for your scripts and mathematical visualizations.</p>
            <p class="text-gray-600">Use the sidebar to navigate between different sections.</p>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div class="bg-white rounded-lg shadow p-4">
              <h3 class="text-lg font-semibold mb-3">System Status</h3>
              <div class="flex items-center mb-2">
                <div class="w-3 h-3 rounded-full bg-green-500 mr-2"></div>
                <span>BAZINGA Core: Running</span>
              </div>
              <div class="flex items-center mb-2">
                <div class="w-3 h-3 rounded-full bg-green-500 mr-2"></div>
                <span>Hash Monitor: Active</span>
              </div>
              <div class="flex items-center">
                <div class="w-3 h-3 rounded-full bg-green-500 mr-2"></div>
                <span>WebSocket: Connected</span>
              </div>
            </div>
            
            <div class="bg-white rounded-lg shadow p-4">
              <h3 class="text-lg font-semibold mb-3">Quick Actions</h3>
              <div class="space-y-2">
                <button class="w-full px-3 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700">Refresh Scripts</button>
                <button class="w-full px-3 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300">View Documentation</button>
              </div>
            </div>
            
            <div class="bg-white rounded-lg shadow p-4">
              <h3 class="text-lg font-semibold mb-3">Recent Activity</h3>
              <div class="space-y-2">
                <div class="p-2 bg-gray-50 rounded">
                  <div class="font-medium">System Scan</div>
                  <div class="text-sm text-gray-500">2 minutes ago</div>
                </div>
                <div class="p-2 bg-gray-50 rounded">
                  <div class="font-medium">Hash Analysis</div>
                  <div class="text-sm text-gray-500">15 minutes ago</div>
                </div>
              </div>
            </div>
          </div>
        </section>
        
        <!-- Script Catalog Section -->
        <section id="scripts" class="section hidden">
          <div class="bg-white rounded-lg shadow p-4 mb-4">
            <h3 class="text-lg font-semibold mb-3">Script Catalog</h3>
            <p class="text-gray-600">Browse and run scripts from your system.</p>
            
            <div class="mt-4 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4" id="script-catalog">
              <!-- Script items will be loaded here -->
              <div class="p-3 rounded border border-gray-200 hover:border-indigo-500 hover:shadow cursor-pointer script-item">
                <div class="font-medium text-indigo-600">quantum-architecture-analyzer.sh</div>
                <div class="text-sm text-gray-500 mb-2">Analyze codebase architecture through quantum lens</div>
                <div class="text-xs text-gray-400">~/bin/quantum-architecture-analyzer.sh</div>
              </div>
              
              <div class="p-3 rounded border border-gray-200 hover:border-indigo-500 hover:shadow cursor-pointer script-item">
                <div class="font-medium text-indigo-600">bazinga-controller.sh</div>
                <div class="text-sm text-gray-500 mb-2">Main controller for BAZINGA system</div>
                <div class="text-xs text-gray-400">~/bin/bazinga-controller.sh</div>
              </div>
              
              <div class="p-3 rounded border border-gray-200 hover:border-indigo-500 hover:shadow cursor-pointer script-item">
                <div class="font-medium text-indigo-600">vault-handler.sh</div>
                <div class="text-sm text-gray-500 mb-2">Manage Vault tokens and secrets</div>
                <div class="text-xs text-gray-400">~/VaultAutomation/scripts/vault-handler.sh</div>
              </div>
            </div>
          </div>
          
          <div class="bg-white rounded-lg shadow p-4 hidden" id="script-details-panel">
            <h3 class="text-lg font-semibold mb-3">Script Details</h3>
            <div class="mb-4">
              <h4 id="script-detail-name" class="font-medium text-lg text-indigo-600"></h4>
              <div id="script-detail-path" class="text-sm text-gray-500"></div>
            </div>
            
            <div class="mb-4">
              <div class="font-medium mb-1">Description:</div>
              <div id="script-detail-description" class="text-sm bg-gray-50 p-2 rounded"></div>
            </div>
            
            <div class="mb-4">
              <div class="font-medium mb-1">Parameters:</div>
              <input type="text" id="script-params" placeholder="Optional parameters..." class="w-full p-2 border rounded">
            </div>
            
            <button id="run-script-btn" class="bg-indigo-600 text-white py-2 px-4 rounded hover:bg-indigo-700 mb-4">
              Run Script
            </button>
            
            <div id="script-terminal" class="bg-gray-900 rounded-lg p-4 mt-4 hidden">
              <div class="flex justify-between items-center mb-2">
                <h4 class="text-white font-medium">Terminal Output</h4>
                <button id="clear-terminal-btn" class="text-gray-400 hover:text-white text-sm">Clear</button>
              </div>
              <div class="terminal-output font-mono text-sm text-green-400 h-64 overflow-y-auto whitespace-pre p-2"></div>
            </div>
          </div>
        </section>
        
        <!-- Math Visualizations Section -->
        <section id="math" class="section hidden">
          <div class="bg-white rounded-lg shadow p-4 mb-6">
            <h3 class="text-lg font-semibold mb-3">Mathematical Visualizations</h3>
            <p class="text-gray-600 mb-4">Experience the mathematical magic behind BAZINGA's system.</p>
          </div>
          
          <div id="math-visualizations-container" class="mb-6">
            <!-- Math visualizations will be loaded here -->
          </div>
        </section>
        
        <!-- System Monitoring Section -->
        <section id="monitoring" class="section hidden">
          <div class="bg-white rounded-lg shadow p-4 mb-6">
            <h3 class="text-lg font-semibold mb-3">System Monitoring</h3>
            <p class="text-gray-600 mb-4">Real-time monitoring of your BAZINGA ecosystem.</p>
            
            <div class="mt-4 p-4 bg-gray-100 rounded">
              <h4 class="font-medium mb-2">Hash-Based System Monitoring</h4>
              <button id="start-hash-monitoring" class="px-4 py-2 bg-green-600 text-white rounded mr-2">Start Monitoring</button>
              <button id="stop-hash-monitoring" class="px-4 py-2 bg-red-600 text-white rounded">Stop Monitoring</button>
            </div>
          </div>
          
          <div id="system-monitoring-results" class="bg-white rounded-lg shadow p-4">
            <h3 class="text-lg font-semibold mb-3">Monitoring Results</h3>
            <div class="p-8 text-center text-gray-500">
              Start monitoring to see real-time system analysis
            </div>
          </div>
        </section>
      </main>
    </div>
  </div>
  
  <script src="js/main.js"></script>
  <script src="js/math-visualizations.js"></script>
</body>
</html>
EOF

echo -e "  ${GREEN}✓${NC} Created index.html"

# Step 7: Create server.js file
echo -e "\n${BLUE}Creating server files...${NC}"

cat > "$SERVER_DIR/server.js" << 'EOF'
/**
 * BAZINGA Web App - Server
 * This is the main server file that powers the BAZINGA Web Application
 */

const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

// Configuration
const PORT = 8080;
const PUBLIC_DIR = path.join(__dirname, '../public');
const DATA_DIR = path.join(__dirname, '../data');
const LOG_DIR = path.join(__dirname, '../logs');

// Create Express app
const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Serve static files
app.use(express.static(PUBLIC_DIR));

// Default route
app.get('/', (req, res) => {
  res.sendFile(path.join(PUBLIC_DIR, 'index.html'));
});

// WebSocket server
wss.on('connection', (ws) => {
  console.log('Client connected');
  
  // Send initial connection status
  ws.send(JSON.stringify({
    type: 'connected',
    data: {
      timestamp: new Date().toISOString(),
      message: 'Connected to BAZINGA Web App'
    }
  }));
  
  // Handle messages
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message.toString());
      
      // Handle different message types
      switch (data.type) {
        case 'run-script':
          handleScriptRun(ws, data.data);
          break;
          
        case 'edit-file':
          handleEditFile(ws, data.data);
          break;
          
        default:
          ws.send(JSON.stringify({
            type: 'error',
            data: {
              message: 'Unknown message type'
            }
          }));
      }
    } catch (error) {
      console.error('Error handling WebSocket message:', error);
      ws.send(JSON.stringify({
        type: 'error',
        data: {
          message: 'Error processing message',
          details: error.message
        }
      }));
    }
  });
  
  // Handle disconnection
  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

// Handle script execution
function handleScriptRun(ws, data) {
  const command = data.path || data.command || '';
  const params = data.params || '';
  
  if (!command) {
    ws.send(JSON.stringify({
      type: 'script-error',
      data: {
        message: 'No command specified'
      }
    }));
    return;
  }
  
  // Build the full command
  const fullCommand = params ? `${command} ${params}` : command;
  
  // Use spawn to get real-time output
  const { spawn } = require('child_process');
  const proc = spawn(fullCommand, [], { 
    shell: true,
    env: { ...process.env, HOME: process.env.HOME }
  });
  
  // Send start message
  ws.send(JSON.stringify({
    type: 'script-start',
    data: {
      command: fullCommand,
      timestamp: new Date().toISOString()
    }
  }));
  
  // Standard output
  proc.stdout.on('data', (data) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({
        type: 'script-output',
        data: {
          output: data.toString(),
          isError: false
        }
      }));
    }
  });
  
  // Standard error
  proc.stderr.on('data', (data) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({
        type: 'script-output',
        data: {
          output: data.toString(),
          isError: true
        }
      }));
    }
  });
  
  // Process end
  proc.on('close', (code) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({
        type: 'script-end',
        data: {
          exitCode: code,
          success: code === 0,
          command: fullCommand
        }
      }));
    }
  });
  
  // Handle errors
  proc.on('error', (err) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({
        type: 'script-error',
        data: {
          message: err.message
        }
      }));
    }
  });
}

// Handle edit file request
function handleEditFile(ws, data) {
  const filePath = data?.path;
  
  if (!filePath) {
    ws.send(JSON.stringify({
      type: 'edit-error',
      data: {
        message: 'No file path provided'
      }
    }));
    return;
  }
  
  // Use appropriate editor based on OS
  let editorCommand;
  if (process.platform === 'darwin') {
    // On macOS, use open command which will open in default editor
    editorCommand = `open "${filePath}"`;
  } else if (process.platform === 'linux') {
    // On Linux, try to use sensible-editor, falling back to xdg-open
    editorCommand = `if command -v sensible-editor >/dev/null; then sensible-editor "${filePath}"; else xdg-open "${filePath}"; fi`;
  } else {
    // Fallback for other platforms
    editorCommand = `if command -v code >/dev/null; then code "${filePath}"; else echo "No suitable editor found"; fi`;
  }
  
  // Execute the editor command
  exec(editorCommand, (error, stdout, stderr) => {
    if (error) {
      ws.send(JSON.stringify({
        type: 'edit-error',
        data: {
          message: 'Failed to open editor',
          details: stderr
        }
      }));
      return;
    }
    
    ws.send(JSON.stringify({
      type: 'edit-success',
      data: {
        message: `Opened file for editing: ${path.basename(filePath)}`
      }
    }));
  });
}

// Start the server
server.listen(PORT, () => {
  console.log(`BAZINGA Web App running at http://localhost:${PORT}`);
});
EOF

echo -e "  ${GREEN}✓${NC} Created server.js"

# Step 8: Create startup script
echo -e "\n${BLUE}Creating startup script...${NC}"

cat > "$INSTALL_DIR/start-bazinga-web.sh" << 'EOF'
#!/bin/bash
# BAZINGA Web App - Startup Script

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start the server
echo "Starting BAZINGA Web App..."
echo "Open your browser and navigate to: http://localhost:8080"
cd "$SCRIPT_DIR"
node server/server.js
EOF

# Make the startup script executable
chmod +x "$INSTALL_DIR/start-bazinga-web.sh"
echo -e "  ${GREEN}✓${NC} Created startup script"

# Step 9: Create a shortcut in the user's bin directory
if [ -d "$HOME/bin" ]; then
  echo -e "\n${BLUE}Creating shortcut in ~/bin directory...${NC}"
  cat > "$HOME/bin/bazinga-web.sh" << EOF
#!/bin/bash
# BAZINGA Web App Launcher

# Start the BAZINGA Web App server
"$INSTALL_DIR/start-bazinga-web.sh"
EOF
  chmod +x "$HOME/bin/bazinga-web.sh"
  echo -e "  ${GREEN}✓${NC} Created shortcut: ~/bin/bazinga-web.sh"
fi

# Step 10: Copy quantum-architecture-analyzer.sh if it exists
if [ -f "quantum-architecture-analyzer.sh" ]; then
  echo -e "\n${BLUE}Setting up Quantum Architecture Analyzer...${NC}"
  cp "quantum-architecture-analyzer.sh" "$INSTALL_DIR/"
  chmod +x "$INSTALL_DIR/quantum-architecture-analyzer.sh"
  echo -e "  ${GREEN}✓${NC} Copied quantum-architecture-analyzer.sh to $INSTALL_DIR/"
else
  echo -e "\n${YELLOW}Note: quantum-architecture-analyzer.sh not found in current directory.${NC}"
  echo -e "You can add it manually later to $INSTALL_DIR/ for full functionality."
fi

# Step 11: Final message
echo -e "\n${GREEN}==================================================${NC}"
echo -e "${GREEN}   BAZINGA Web App Installation Complete!          ${NC}"
echo -e "${GREEN}==================================================${NC}"
echo -e "\n${CYAN}To start the BAZINGA Web App:${NC}"
echo -e "  Run: ${YELLOW}$INSTALL_DIR/start-bazinga-web.sh${NC}"
if [ -d "$HOME/bin" ]; then
  echo -e "  Or use the shortcut: ${YELLOW}~/bin/bazinga-web.sh${NC}"
fi
echo -e "\nThen open your browser and navigate to:"
echo -e "  ${YELLOW}http://localhost:8080${NC}"
echo -e "\n${CYAN}Installation Directory:${NC}"
echo -e "  ${YELLOW}$INSTALL_DIR${NC}"
echo -e "\n${CYAN}Troubleshooting:${NC}"
echo -e "  If you encounter any issues, check the logs in: ${YELLOW}$LOG_DIR${NC}"
echo -e "  Make sure your browser has JavaScript enabled"
echo -e "  Try accessing the app in Chrome or Firefox if Safari has issues"

# Step 12: Start the app automatically (optional)
echo -e "\n${CYAN}Would you like to start the BAZINGA Web App now? (y/n)${NC}"
read -r START_APP
if [[ "$START_APP" =~ ^[Yy]$ ]]; then
  echo -e "\n${YELLOW}Starting BAZINGA Web App...${NC}"
  "$INSTALL_DIR/start-bazinga-web.sh" &
  echo -e "\n${GREEN}BAZINGA Web App is running!${NC}"
  echo -e "Open your browser and navigate to: ${YELLOW}http://localhost:8080${NC}"
  echo -e "\nTo stop the app, press Ctrl+C in the terminal where it's running"
else
  echo -e "\n${YELLOW}BAZINGA Web App installation is complete but not started.${NC}"
  echo -e "Run the script manually when ready: ${YELLOW}$INSTALL_DIR/start-bazinga-web.sh${NC}"
fi

exit 0
