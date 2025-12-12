#!/bin/bash
# bazinga-git-setup.sh - Prepare BAZINGA for Git

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}⟨ψ|⟳| BAZINGA Git Setup |ψ⟩${NC}"

BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
cd "$BAZINGA_DIR" || exit 1

# Create .gitignore if it doesn't exist or update it
if [ ! -f .gitignore ]; then
  echo -e "${YELLOW}Creating .gitignore...${NC}"
  cat > .gitignore << 'EOL'
# BAZINGA system .gitignore

# Node.js
node_modules/
npm-debug.log

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
venv_bazinga/
*.egg-info/
dist/
build/

# Logs and temp files
logs/
*.log
*.bak
*~
*.tmp
.DS_Store

# Generated files (selectively excluded)
generated/dashboard/*
!generated/dashboard/latest-framework-visual.svg
generated/temp/
EOL
else
  echo -e "${YELLOW}Updating .gitignore...${NC}"
  for pattern in "__pycache__/" "*.pyc" "node_modules/" "*.log" "*.bak" "*~" "*.tmp" ".DS_Store"; do
    if ! grep -q "$pattern" .gitignore; then
      echo "$pattern" >> .gitignore
    fi
  done
fi

# Create README.md if it doesn't exist or update it
if [ ! -f README.md ]; then
  echo -e "${YELLOW}Creating README.md...${NC}"
  cat > README.md << 'EOL'
# BAZINGA Framework

A quantum-inspired pattern recognition framework with recursive self-reference.

## Core Concept

`⟨ψ|⟳|The framework recognizes patterns that recognize themselves being recognized⟩`

## Installation

```bash
git clone https://github.com/yourusername/BAZINGA.git
cd BAZINGA
./system/bazinga setup
```

## Usage

```bash
./baz <command> [options]
```

See the [Usage Guide](docs/USAGE.md) for detailed documentation.

## Framework Components

- **Pattern Detection**: Recursive pattern recognition across domains
- **Visualization**: Framework component visualization with SVG
- **Trust Corrector**: Relationship pattern analysis
- **Integration**: Claude AI integration

## License

MIT
EOL
fi

# Create docs directory and USAGE.md
mkdir -p docs
cp -f bazinga-usage-guide.md docs/USAGE.md 2>/dev/null || {
  echo -e "${YELLOW}Creating usage guide in docs/USAGE.md...${NC}"
  cat > docs/USAGE.md << 'EOL'
# BAZINGA Framework Usage Guide

## Core Commands

```bash
./baz <command> [options]
```

| Command | Description |
|---------|-------------|
| `visualize` | Generate framework visualization |
| `trust` | Run trust corrector |
| `glance` | Get activity snapshot |
| `optimize` | Run script optimization |

See full documentation in the repository.
EOL
}

# Create .gitattributes for line ending normalization
if [ ! -f .gitattributes ]; then
  echo -e "${YELLOW}Creating .gitattributes...${NC}"
  cat > .gitattributes << 'EOL'
# Auto detect text files and perform LF normalization
* text=auto

# Explicitly declare text files
*.py text
*.js text
*.sh text eol=lf
*.md text
*.txt text

# Binary files
*.png binary
*.jpg binary
*.svg text
EOL
fi

# Clean up unnecessary files
echo -e "${YELLOW}Cleaning up unnecessary files...${NC}"
find . -name "*.bak" -o -name "*~" -o -name "*.tmp" -delete

# Initialize git if not already
if [ ! -d .git ]; then
  echo -e "${YELLOW}Initializing git repository...${NC}"
  git init
fi

# Stage critical files
echo -e "${YELLOW}Staging critical files...${NC}"

# Core system files
git add system/bazinga baz 2>/dev/null
git add bin/bazinga-delegator.sh bin/bazinga-fractal.sh 2>/dev/null
git add bazinga-fractal.sh bazinga-delegator.sh 2>/dev/null

# Documentation
git add README.md docs/USAGE.md .gitignore .gitattributes

# Core scripts by category
for category in "visual" "trust" "glance" "integrate"; do
  files=$(find . -name "*$category*.sh" -o -name "*$category*.py" | grep -v "node_modules")
  if [ -n "$files" ]; then
    echo "$files" | xargs git add
  fi
done

# Add visualizations
git add generated/*/latest-framework-visual.svg 2>/dev/null
git add artifacts/visualization/*.svg 2>/dev/null

# Ignore large data files and temp directories
git reset -- venv/ venv_bazinga/ node_modules/ 2>/dev/null

echo -e "${GREEN}BAZINGA is ready for git commit!${NC}"
echo -e "${CYAN}Next steps:${NC}"
echo -e "1. Review staged files: ${YELLOW}git status${NC}"
echo -e "2. Commit changes: ${YELLOW}git commit -m \"Initial BAZINGA framework\"${NC}"
echo -e "3. Add remote repository: ${YELLOW}git remote add origin <your-repo-url>${NC}"
echo -e "4. Push changes: ${YELLOW}git push -u origin main${NC}"
