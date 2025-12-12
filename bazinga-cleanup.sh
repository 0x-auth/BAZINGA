#!/bin/bash
# ============================================================================
# BAZINGA Project Cleanup and Organization Script
# 
# This script reorganizes the BAZINGA project structure, cleans up artifacts,
# and sets up proper directory organization.
# ============================================================================

# Terminal colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== BAZINGA Project Cleanup & Organization ===${NC}"

# Verify we're in the right directory
if [ ! -f "bazinga-architecture.json" ] && [ ! -d "src" ]; then
  echo -e "${RED}Error: This doesn't appear to be a BAZINGA project root.${NC}"
  echo -e "${YELLOW}Please run this script from the BAZINGA project root directory.${NC}"
  exit 1
fi

# Function to create directory if it doesn't exist
create_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo -e "${GREEN}Created directory: $1${NC}"
  fi
}

# -----------------------------------------------------------------------------
# 1. Create directory structure
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Creating directory structure...${NC}"

# Main directories
create_dir "docs/guides"
create_dir "docs/architecture"
create_dir "docs/api"
create_dir "src/core/patterns"
create_dir "src/core/quantum"
create_dir "src/core/token"
create_dir "src/integrations/dodo"
create_dir "src/tools"
create_dir "src/examples"
create_dir "tests/unit"
create_dir "tests/integration"
create_dir "tests/performance"
create_dir "scripts"
create_dir "build"

# -----------------------------------------------------------------------------
# 2. Organize documentation
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Organizing documentation...${NC}"

# Move markdown files to docs
find . -maxdepth 1 -name "*.md" -not -name "README.md" -exec mv {} docs/ \;

# Organize BAZINGA docs
find docs -maxdepth 1 -name "BAZINGA-*.md" -exec mv {} docs/guides/ \;
find docs -maxdepth 1 -name "*-guide.md" -exec mv {} docs/guides/ \;
find docs -maxdepth 1 -name "*-integration.md" -exec mv {} docs/architecture/ \;
find . -maxdepth 1 -name "*.html" -exec mv {} docs/ \;

# -----------------------------------------------------------------------------
# 3. Organize source code
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Organizing source code...${NC}"

# Move core files to their proper location
if [ -f "src/core/pure-pattern-communication.ts" ]; then
  mv src/core/pure-pattern-communication.ts src/core/patterns/
  echo -e "${GREEN}Moved pure-pattern-communication.ts to patterns directory${NC}"
fi

if [ -f "bazinga-token-integration.ts" ]; then
  mv bazinga-token-integration.ts src/core/token/
  echo -e "${GREEN}Moved bazinga-token-integration.ts to token directory${NC}"
fi

if [ -f "bazinga-harmonics-implementation.ts" ]; then
  mv bazinga-harmonics-implementation.ts src/core/patterns/
  echo -e "${GREEN}Moved bazinga-harmonics-implementation.ts to patterns directory${NC}"
fi

if [ -f "bazinga-quantum-integration.ts" ]; then
  mv bazinga-quantum-integration.ts src/core/quantum/
  echo -e "${GREEN}Moved bazinga-quantum-integration.ts to quantum directory${NC}"
fi

# Organize DODO integration files
find . -maxdepth 1 -name "*dodo*.ts" -exec mv {} src/integrations/dodo/ \;
find . -maxdepth 1 -name "*DODO*.ts" -exec mv {} src/integrations/dodo/ \;

# -----------------------------------------------------------------------------
# 4. Organize scripts
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Organizing scripts...${NC}"

# Move shell scripts to scripts directory, except this one
find . -maxdepth 1 -name "*.sh" -not -name "$(basename $0)" -exec mv {} scripts/ \;
chmod +x scripts/*.sh

# -----------------------------------------------------------------------------
# 5. Clean up artifacts directory
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Organizing artifacts...${NC}"

if [ -d "artifacts" ]; then
  # Create subdirectories
  create_dir "artifacts/fractal"
  create_dir "artifacts/generated"
  create_dir "artifacts/concepts"
  
  # Move files to appropriate directories
  find artifacts -maxdepth 1 -name "*fractal*.js" -exec mv {} artifacts/fractal/ \;
  find artifacts -maxdepth 1 -name "*fractal*.md" -exec mv {} artifacts/fractal/ \;
  find artifacts -maxdepth 1 -name "*generator*.js" -exec mv {} artifacts/generated/ \;
  find artifacts -maxdepth 1 -name "*.md" -not -path "artifacts/fractal/*" -exec mv {} artifacts/concepts/ \;
  
  # Organize "other_" prefixed files if there are many
  if [ $(find artifacts -maxdepth 1 -name "other_*.py" | wc -l) -gt 10 ]; then
    create_dir "artifacts/other"
    find artifacts -maxdepth 1 -name "other_*.py" -exec mv {} artifacts/other/ \;
  fi
fi

# -----------------------------------------------------------------------------
# 6. Create/update main index.ts
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Creating main index.ts...${NC}"

# Create index.ts if it doesn't exist
if [ ! -f "src/index.ts" ]; then
  cat > src/index.ts << 'EOF'
/**
 * BAZINGA System - Main exports
 * This file exports all public components of the BAZINGA system
 */

// Core Pattern System
export * from './core/patterns/pure-pattern-communication';

// Quantum Integration
export * from './core/quantum/bazinga-quantum-integration';

// Token System
export * from './core/token/bazinga-token-integration';

// DODO Integration
export * from './integrations/dodo';
EOF
  echo -e "${GREEN}Created new src/index.ts file${NC}"
else
  echo -e "${YELLOW}src/index.ts already exists, skipping${NC}"
fi

# -----------------------------------------------------------------------------
# 7. Update configuration files
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Updating configuration files...${NC}"

# Create a prettier config if it doesn't exist
if [ ! -f ".prettierrc" ]; then
  cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
EOF
  echo -e "${GREEN}Created .prettierrc${NC}"
fi

# Create eslint config if it doesn't exist
if [ ! -f ".eslintrc.js" ]; then
  cat > .eslintrc.js << 'EOF'
module.exports = {
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  env: {
    node: true,
    es6: true,
  },
  rules: {
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
  },
};
EOF
  echo -e "${GREEN}Created .eslintrc.js${NC}"
fi

# Create or update .gitignore
if [ ! -f ".gitignore" ]; then
  cat > .gitignore << 'EOF'
# Build output
/build
/dist

# Dependencies
/node_modules

# Logs
*.log
npm-debug.log*

# Environment variables
.env
.env.local
.env.*.local

# Editor directories and files
.idea
.vscode
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# OS specific
.DS_Store
Thumbs.db
EOF
  echo -e "${GREEN}Created .gitignore${NC}"
fi

# -----------------------------------------------------------------------------
# 8. Remove temporary files
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Cleaning up temporary files...${NC}"

# Remove temp files
find . -name "*.tmp" -type f -delete
find . -name "*.log" -type f -delete

# -----------------------------------------------------------------------------
# Final message
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}BAZINGA project organization complete!${NC}"
echo -e "\nNext steps:"
echo -e "1. Review the new project structure"
echo -e "2. Update any import paths in your code"
echo -e "3. Run your test suite to verify everything works"
echo -e "4. Install additional dependencies if needed:"
echo -e "   ${YELLOW}npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin prettier${NC}"
