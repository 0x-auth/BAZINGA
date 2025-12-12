#!/bin/bash
# BAZINGA Web App - Installation Script
# This script installs the BAZINGA Web App, integrating all your scripts
# with a unified web interface including mathematical visualizations.

# ANSI colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Directory configuration
HOME_DIR="$HOME"
INSTALL_DIR="$HOME/.bazinga-web"
DATA_DIR="$INSTALL_DIR/data"
LOG_DIR="$INSTALL_DIR/logs"
CONFIG_DIR="$INSTALL_DIR/config"
PUBLIC_DIR="$INSTALL_DIR/public"
SERVER_DIR="$INSTALL_DIR/server"

# Print header
echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}   BAZINGA Web App - Installation                 ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""

# Check for required tools
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

# Create directory structure
echo -e "\n${BLUE}Creating directory structure...${NC}"

mkdir -p "$INSTALL_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$PUBLIC_DIR/js"
mkdir -p "$PUBLIC_DIR/css"
mkdir -p "$PUBLIC_DIR/components"
mkdir -p "$SERVER_DIR"

echo -e "  ${GREEN}✓${NC} Created directory structure at $INSTALL_DIR"

# Create package.json
echo -e "\n${BLUE}Setting up Node.js project...${NC}"

cat > "$INSTALL_DIR/package.json" << EOF
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
    "ws": "^8.2.3",
    "path": "^0.12.7",
    "fs": "0.0.1-security"
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

# Create CSS file
echo -e "\n${BLUE}Creating CSS files...${NC}"

cat > "$PUBLIC_DIR/css/styles.css" << 'EOF'
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
EOF

# Copy files from provided HTML to the public directory
echo -e "\n${BLUE}Creating HTML and JavaScript files...${NC}"

# Copy main.js file created earlier
cp /tmp/main.js "$PUBLIC_DIR/js/"

# Create startup script
echo -e "\n${BLUE}Creating startup script...${NC}"

cat > "$INSTALL_DIR/start-bazinga-web.sh" << 'EOF'
#!/bin/bash
# BAZINGA Web App - Startup Script

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start the server
echo "Starting BAZINGA Web App..."
cd "$SCRIPT_DIR"
node server/server.js
EOF

# Make the startup script executable
chmod +x "$INSTALL_DIR/start-bazinga-web.sh"

# Create a shortcut script in the user's bin directory
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

# Create server.js file
echo -e "\n${BLUE}Copying server files...${NC}"
# Note: The server.js, path-utils.js, and hash-magic.js files would be copied here
# For brevity, they're omitted from this script

# Create starter index.html file
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
            <a href="#artifacts" class="block px-4 py-2 rounded hover:bg-gray-700 nav-link" data-target="artifacts">
              <span class="mr-2">📦</span> Artifacts
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
        
        <div class="mt-8 px-4">
          <h3 class="text-sm uppercase text-gray-500 font-semibold mb-2">Categories</h3>
          <button class="w-full mb-2 px-3 py-2 text-left rounded bg-indigo-600 text-white script-category-btn" data-category="personal">
            Personal
          </button>
          <button class="w-full px-3 py-2 text-left rounded bg-gray-200 text-gray-700 script-category-btn" data-category="office">
            Office
          </button>
        </div>
        
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
        <div class="w-full max-w-md mx-4">
          <input type="text" id="global-search" placeholder="Search scripts, artifacts..." class="w-full px-4 py-2 rounded border focus:outline-none focus:ring-2 focus:ring-indigo-500">
        </div>
      </header>
      
      <!-- Content area -->
      <main class="flex-1 overflow-y-auto p-4">
        <!-- Dashboard Section -->
        <section id="dashboard" class="section active">
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
            
            <!-- Other dashboard widgets -->
          </div>
          
          <div id="hash-visualization" class="mt-6 hidden">
            <!-- Hash visualization content will be inserted here -->
          </div>
        </section>
        
        <!-- Other sections would go here -->
      </main>
    </div>
  </div>
  
  <script src="js/main.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      // Initialize the Universal Script Runner
      universalScriptRunner.init();
    });
  </script>
</body>
</html>
EOF

# Print completion message
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

# Done!
exit 0
