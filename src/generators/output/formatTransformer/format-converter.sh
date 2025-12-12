#!/bin/bash

# format-converter.sh - A command-line tool for converting between document formats
# Dependencies: pandoc, node (optional for prettier formatting)

set -e

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Check for required dependencies
check_dependencies() {
  if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Error: pandoc is required but not installed.${NC}"
    echo "Install it using your package manager:"
    echo "  - Ubuntu/Debian: sudo apt-get install pandoc"
    echo "  - macOS: brew install pandoc"
    echo "  - Windows: choco install pandoc"
    exit 1
  fi

  # Check for node (optional)
  if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Warning: Node.js not found. HTML/CSS prettification will be disabled.${NC}"
  fi
}

# Display help message
show_help() {
  echo -e "${BOLD}Format Converter${NC} - Convert between document formats"
  echo
  echo -e "${BOLD}Usage:${NC}"
  echo "  $0 [options] input_file output_file"
  echo
  echo -e "${BOLD}Options:${NC}"
  echo "  -h, --help             Show this help message"
  echo "  -f, --from FORMAT      Source format (markdown, html, docx, etc.)"
  echo "  -t, --to FORMAT        Target format (markdown, html, docx, pdf, etc.)"
  echo "  -s, --standalone       Create standalone document with proper headers"
  echo "  -e, --email            Create email-friendly HTML (when target is html)"
  echo "  -p, --pretty           Format HTML/CSS output nicely (requires Node.js)"
  echo "  -c, --css FILE         Include custom CSS file (for HTML output)"
  echo "  -v, --verbose          Show detailed conversion information"
  echo
  echo -e "${BOLD}Examples:${NC}"
  echo "  $0 -f markdown -t html document.md document.html"
  echo "  $0 -f html -t markdown -v website.html website.md"
  echo "  $0 -f markdown -t html -e -s document.md email.html"
  echo "  $0 -f docx -t markdown report.docx report.md"
  echo
  echo -e "${BOLD}Supported Formats:${NC}"
  echo "  Input: markdown, html, docx, odt, tex, rst, and more"
  echo "  Output: markdown, html, docx, odt, pdf, tex, rst, and more"
  echo
  echo "For complete format list, see: pandoc --list-input-formats and --list-output-formats"
}

# Create email-friendly HTML template
create_email_html() {
  local content="$1"
  
  cat <<EOT
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Email</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            font-size: 16px;
            line-height: 1.6;
            color: #333333;
        }
        table {
            border-collapse: collapse;
        }
        td {
            padding: 0;
        }
        img {
            border: 0;
            height: auto;
            line-height: 100%;
            outline: none;
            text-decoration: none;
            max-width: 100%;
        }
        h1, h2, h3, h4, h5, h6 {
            margin-top: 20px;
            margin-bottom: 10px;
            line-height: 1.2;
        }
        p, ul, ol {
            margin-top: 0;
            margin-bottom: 16px;
        }
        .content {
            padding: 20px;
            max-width: 600px;
        }
        table.data-table {
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
        }
        table.data-table th, table.data-table td {
            border: 1px solid #dddddd;
            text-align: left;
            padding: 8px;
        }
        table.data-table tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        code {
            font-family: monospace;
            background-color: #f1f1f1;
            padding: 2px 4px;
            border-radius: 3px;
        }
        pre {
            background-color: #f1f1f1;
            padding: 16px;
            overflow: auto;
            border-radius: 3px;
        }
    </style>
</head>
<body>
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td align="center">
                <table class="content" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">
                    <tr>
                        <td>
$content
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
EOT
}

# Format HTML using prettier (if available)
prettify_html() {
  local input="$1"
  local temp_file
  
  if command -v node &> /dev/null; then
    temp_file=$(mktemp)
    echo "$input" > "$temp_file"
    
    # Use Node.js to run prettier on the HTML
    node -e "
      try {
        const fs = require('fs');
        const html = fs.readFileSync('$temp_file', 'utf8');
        console.log(html
          .replace(/\\n\\s*\\n/g, '\\n\\n')
          .split('\\n')
          .map(line => line.trim())
          .join('\\n')
          .replace(/<\\/tr>\\s*<tr/g, '<\\/tr>\\n<tr')
          .replace(/<\\/td>\\s*<td/g, '<\\/td>\\n  <td')
          .replace(/<\\/th>\\s*<th/g, '<\\/th>\\n  <th')
          .replace(/<\\/thead>\\s*<tbody/g, '<\\/thead>\\n<tbody')
          .replace(/<\\/tbody>\\s*<\\/table>/g, '<\\/tbody>\\n<\\/table>')
          .replace(/<table>\\s*<thead/g, '<table>\\n<thead')
          .replace(/<\\/h([1-6])>\\s*<([^h])/g, '<\\/h$1>\\n\\n<$2')
          .replace(/<\\/p>\\s*<p/g, '<\\/p>\\n\\n<p')
          .replace(/<\\/div>\\s*<div/g, '<\\/div>\\n\\n<div')
          .replace(/<\\/ul>\\s*<p/g, '<\\/ul>\\n\\n<p')
          .replace(/<\\/ol>\\s*<p/g, '<\\/ol>\\n\\n<p')
          .replace(/<\\/p>\\s*<ul/g, '<\\/p>\\n\\n<ul')
          .replace(/<\\/p>\\s*<ol/g, '<\\/p>\\n\\n<ol')
          .replace(/<li>\\s*<p>/g, '<li>')
          .replace(/<\\/p>\\s*<\\/li>/g, '<\\/li>')
        );
      } catch (error) {
        console.error('Error formatting HTML:', error);
        fs.readFileSync('$temp_file', 'utf8');
      }
    "
    rm "$temp_file"
  else
    echo "$input"
  fi
}

# Main function to handle format conversion
convert_format() {
  local input_file="$1"
  local output_file="$2"
  local from_format="$3"
  local to_format="$4"
  local opts=()
  
  # Check if input file exists
  if [ ! -f "$input_file" ]; then
    echo -e "${RED}Error: Input file '$input_file' not found.${NC}"
    exit 1
  fi
  
  # Build pandoc options
  if [ "$standalone" = true ]; then
    opts+=("--standalone")
  fi
  
  if [ "$verbose" = true ]; then
    opts+=("--verbose")
  fi
  
  if [ -n "$css_file" ]; then
    if [ ! -f "$css_file" ]; then
      echo -e "${YELLOW}Warning: CSS file '$css_file' not found. Ignoring.${NC}"
    else
      opts+=("--css=$css_file")
    fi
  fi
  
  echo -e "${BLUE}Converting from $from_format to $to_format...${NC}"
  
  # Special handling for email HTML
  if [ "$to_format" = "html" ] && [ "$email_format" = true ]; then
    # First convert to regular HTML
    local html_content
    html_content=$(pandoc -f "$from_format" -t html "${opts[@]}" "$input_file")
    
    # Then wrap in email template
    local email_html
    email_html=$(create_email_html "$html_content")
    
    # Format if requested
    if [ "$pretty_format" = true ]; then
      email_html=$(prettify_html "$email_html")
    fi
    
    echo "$email_html" > "$output_file"
  else
    # Standard pandoc conversion
    if [ "$to_format" = "html" ] && [ "$pretty_format" = true ]; then
      # For HTML with pretty formatting
      local html_content
      html_content=$(pandoc -f "$from_format" -t html "${opts[@]}" "$input_file")
      prettify_html "$html_content" > "$output_file"
    else
      # Default conversion
      pandoc -f "$from_format" -t "$to_format" "${opts[@]}" -o "$output_file" "$input_file"
    fi
  fi
  
  if [ -f "$output_file" ]; then
    echo -e "${GREEN}Successfully converted to: $output_file${NC}"
  else
    echo -e "${RED}Conversion failed!${NC}"
    exit 1
  fi
}

# Initialize variables
input_file=""
output_file=""
from_format=""
to_format=""
standalone=false
email_format=false
pretty_format=false
css_file=""
verbose=false

# Parse command-line arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -f|--from)
      from_format="$2"
      shift 2
      ;;
    -t|--to)
      to_format="$2"
      shift 2
      ;;
    -s|--standalone)
      standalone=true
      shift
      ;;
    -e|--email)
      email_format=true
      shift
      ;;
    -p|--pretty)
      pretty_format=true
      shift
      ;;
    -c|--css)
      css_file="$2"
      shift 2
      ;;
    -v|--verbose)
      verbose=true
      shift
      ;;
    -*)
      echo -e "${RED}Unknown option: $1${NC}"
      show_help
      exit 1
      ;;
    *)
      if [ -z "$input_file" ]; then
        input_file="$1"
      elif [ -z "$output_file" ]; then
        output_file="$1"
      else
        echo -e "${RED}Error: Unexpected argument '$1'${NC}"
        show_help
        exit 1
      fi
      shift
      ;;
  esac
done

# Check for required arguments
if [ -z "$input_file" ] || [ -z "$output_file" ]; then
  echo -e "${RED}Error: Both input and output files must be specified.${NC}"
  show_help
  exit 1
fi

# Auto-detect formats if not specified
if [ -z "$from_format" ]; then
  case "$input_file" in
    *.md|*.markdown)
      from_format="markdown"
      ;;
    *.html|*.htm)
      from_format="html"
      ;;
    *.docx)
      from_format="docx"
      ;;
    *.tex)
      from_format="latex"
      ;;
    *.rst)
      from_format="rst"
      ;;
    *)
      echo -e "${RED}Error: Could not determine input format. Please specify with -f/--from.${NC}"
      exit 1
      ;;
  esac
  echo -e "${YELLOW}Auto-detected input format: $from_format${NC}"
fi

if [ -z "$to_format" ]; then
  case "$output_file" in
    *.md|*.markdown)
      to_format="markdown"
      ;;
    *.html|*.htm)
      to_format="html"
      ;;
    *.docx)
      to_format="docx"
      ;;
    *.pdf)
      to_format="pdf"
      ;;
    *.tex)
      to_format="latex"
      ;;
    *.rst)
      to_format="rst"
      ;;
    *)
      echo -e "${RED}Error: Could not determine output format. Please specify with -t/--to.${NC}"
      exit 1
      ;;
  esac
  echo -e "${YELLOW}Auto-detected output format: $to_format${NC}"
fi

# Main execution
check_dependencies
convert_format "$input_file" "$output_file" "$from_format" "$to_format"

# Additional helpful information
echo -e "\n${BOLD}Next steps:${NC}"

case "$to_format" in
  html)
    echo -e "• View your HTML file in a web browser: ${BLUE}open $output_file${NC}"
    if [ "$email_format" = true ]; then
      echo -e "• This HTML is formatted for email clients and should display well in Gmail, Outlook, etc."
    fi
    ;;
  markdown)
    echo -e "• Your markdown file is ready: ${BLUE}cat $output_file${NC}"
    ;;
  pdf)
    echo -e "• View your PDF file: ${BLUE}open $output_file${NC}"
    ;;
  docx)
    echo -e "• Your Word document is ready to be opened in Microsoft Word or similar applications."
    ;;
esac

echo -e "\n${GREEN}Conversion complete!${NC}"
