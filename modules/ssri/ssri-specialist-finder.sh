#!/bin/bash
# SSRI SPECIALIST FINDER
# Specialized tool to find SSRI specialists in Pune and medication-related information

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define search paths and patterns
OUTPUT_DIR="$HOME/ssri_specialist_finder_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Main configuration
DEFAULT_SEARCH_PATHS=("$HOME/Documents" "$HOME/Downloads" "./ssri_specialists_pune" ".")
DEFAULT_FILE_PATTERNS=("*.json" "*.html" "*.txt" "*.md" "*.csv")
DEFAULT_EXCLUSION_PATTERNS=("node_modules" "vendor" ".git" "venv" "__pycache__")

# SSRI and psychiatric specialist keywords
SSRI_KEYWORDS=("SSRI" "sertraline" "antidepressant" "psychiatrist" "Pune" "apathy" 
                "emotional blunting" "medication" "decision-making" "psychiatry" 
                "Behere" "Pathare" "Dandekar" "Parker")

show_help() {
    echo -e "${GREEN}SSRI Specialist Finder Tool${NC}"
    echo -e "Specialized tool to find SSRI specialists in Pune and related information"
    echo -e "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help               Show this help message"
    echo "  -p, --path PATH          Add search path (can be used multiple times)"
    echo "  -f, --file-pattern PAT   Add file pattern (can be used multiple times)"
    echo "  -e, --exclude PAT        Add exclusion pattern (can be used multiple times)"
    echo "  -o, --output DIR         Set output directory (default: $OUTPUT_DIR)"
    echo "  -q, --quiet              Suppress progress messages"
    echo "  -v, --verbose            Show detailed progress"
    echo
    echo "Examples:"
    echo "  $0 --path ~/Downloads --file-pattern \"*.html\""
    echo "  $0 --path ./ssri_specialists_pune --output ~/ssri_results"
    exit 0
}

# Parse command line arguments
SEARCH_PATHS=()
FILE_PATTERNS=()
EXCLUSION_PATTERNS=()
QUIET=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -p|--path)
            SEARCH_PATHS+=("$2")
            shift 2
            ;;
        -f|--file-pattern)
            FILE_PATTERNS+=("$2")
            shift 2
            ;;
        -e|--exclude)
            EXCLUSION_PATTERNS+=("$2")
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            mkdir -p "$OUTPUT_DIR"
            shift 2
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help to see available options"
            exit 1
            ;;
    esac
done

# If no paths specified, use defaults
if [ ${#SEARCH_PATHS[@]} -eq 0 ]; then
    SEARCH_PATHS=("${DEFAULT_SEARCH_PATHS[@]}")
fi

# If no file patterns specified, use defaults
if [ ${#FILE_PATTERNS[@]} -eq 0 ]; then
    FILE_PATTERNS=("${DEFAULT_FILE_PATTERNS[@]}")
fi

# If no exclusion patterns specified, use defaults
if [ ${#EXCLUSION_PATTERNS[@]} -eq 0 ]; then
    EXCLUSION_PATTERNS=("${DEFAULT_EXCLUSION_PATTERNS[@]}")
fi

# Print banner
if ! $QUIET; then
    echo -e "${GREEN}=== SSRI SPECIALIST FINDER ===${NC}"
    echo -e "${BLUE}Output directory:${NC} $OUTPUT_DIR"
    echo -e "${BLUE}Search paths:${NC} ${SEARCH_PATHS[*]}"
    echo -e "${BLUE}SSRI Keywords:${NC} ${SSRI_KEYWORDS[*]}"
fi

# Find files matching patterns
find_files() {
    # Create temporary file to store file paths
    FILES_FILE="$OUTPUT_DIR/file_paths.txt"
    > "$FILES_FILE"  # Clear file if it exists
    
    if ! $QUIET; then
        echo -e "${BLUE}Finding files matching patterns...${NC}"
    fi
    
    # Build exclusion arguments
    EXCLUSION_ARGS=()
    for pattern in "${EXCLUSION_PATTERNS[@]}"; do
        EXCLUSION_ARGS+=(-not -path "*/$pattern/*")
    done
    
    # Find files in the specified directories
    for path in "${SEARCH_PATHS[@]}"; do
        if [ -d "$path" ]; then
            if $VERBOSE; then
                echo -e "${YELLOW}Searching in:${NC} $path"
            fi
            
            # Build find command with pattern arguments
            FIND_CMD=(find "$path" -type f "${EXCLUSION_ARGS[@]}" '(' )
            
            # Add file patterns with -o between them
            for ((i=0; i<${#FILE_PATTERNS[@]}; i++)); do
                FIND_CMD+=(-name "${FILE_PATTERNS[$i]}")
                if ((i < ${#FILE_PATTERNS[@]}-1)); then
                    FIND_CMD+=(-o)
                fi
            done
            
            # Close the parentheses and execute
            FIND_CMD+=( ')' )
            
            if $VERBOSE; then
                echo "${FIND_CMD[@]}"
            fi
            
            "${FIND_CMD[@]}" >> "$FILES_FILE"
        fi
    done
    
    # Count files
    FILE_COUNT=$(wc -l < "$FILES_FILE")
    if ! $QUIET; then
        echo -e "Found ${GREEN}$FILE_COUNT${NC} files"
    fi
    
    # Return the file path
    echo "$FILES_FILE"
}

# Search for SSRI keywords in files
search_ssri_content() {
    FILES_FILE="$1"
    RESULTS_FILE="$OUTPUT_DIR/ssri_results.txt"
    
    if ! $QUIET; then
        echo -e "${BLUE}Searching files for SSRI and psychiatric specialist keywords...${NC}"
    fi
    
    # Create search script
    SEARCH_SCRIPT="$OUTPUT_DIR/ssri_search.py"
    
    cat > "$SEARCH_SCRIPT" << 'PYEOF'
#!/usr/bin/env python3
"""
SSRI Specialist Search Tool
Searches files for SSRI-related keywords and extracts relevant information.
"""

import os
import sys
import re
import json
import html
from bs4 import BeautifulSoup
import csv

# SSRI and psychiatric specialist keywords
SSRI_KEYWORDS = [
    "ssri", "sertraline", "antidepressant", "psychiatrist", "pune", "apathy", 
    "emotional blunting", "medication effect", "decision-making", "psychiatry",
    "neuropsychiatry", "psychopharmacology", "behere", "pathare", "dandekar", "parker"
]

# Contact information patterns
CONTACT_PATTERNS = [
    r'\b[0-9]{10}\b',  # Indian phone numbers
    r'\b[0-9]{3}[-. ][0-9]{8}\b',  # Phone with area code
    r'\b[0-9]{5}[-. ][0-9]{5}\b',  # Phone with space or dash
    r'\b\d{2,4}[ -]?\d{6,8}\b',  # General phone pattern
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',  # Email
    r'(?:https?://)?(?:www\.)?practo\.com/[A-Za-z0-9/-]+',  # Practo URLs
    r'(?:https?://)?(?:www\.)?[A-Za-z0-9.-]+\.[A-Za-z]{2,}/[A-Za-z0-9/-]*psychiatr[A-Za-z0-9/-]*'  # Website URLs with psychiatrist
]

def read_file_content(file_path):
    """Read file content with appropriate handling based on file type"""
    _, ext = os.path.splitext(file_path)
    ext = ext.lower()
    
    try:
        # Handle different file types
        if ext in ['.json']:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                try:
                    return json.load(f)
                except json.JSONDecodeError:
                    # If not valid JSON, read as text
                    f.seek(0)
                    return f.read()
                    
        elif ext in ['.html', '.htm']:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                soup = BeautifulSoup(content, 'html.parser')
                return soup.get_text()
                
        elif ext in ['.csv']:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                reader = csv.reader(f)
                return '\n'.join([','.join(row) for row in reader])
                
        else:  # Default to text
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                return f.read()
    except Exception as e:
        print(f"Error reading {file_path}: {str(e)}", file=sys.stderr)
        return ""

def extract_context(text, keyword, context_size=50):
    """Extract context around keyword"""
    keyword_index = text.lower().find(keyword.lower())
    if keyword_index == -1:
        return ""
        
    start = max(0, keyword_index - context_size)
    end = min(len(text), keyword_index + len(keyword) + context_size)
    
    context = text[start:end]
    
    # Clean up context
    context = re.sub(r'\s+', ' ', context).strip()
    
    # Highlight keyword
    pattern = re.compile(re.escape(keyword), re.IGNORECASE)
    context = pattern.sub(f"[HIGHLIGHT]{keyword}[/HIGHLIGHT]", context)
    
    return context

def extract_contact_info(text):
    """Extract contact information from text"""
    contact_info = []
    
    for pattern in CONTACT_PATTERNS:
        matches = re.findall(pattern, text)
        contact_info.extend(matches)
    
    return list(set(contact_info))  # Remove duplicates

def extract_psychiatrist_info(text):
    """Extract information about psychiatrists"""
    psychiatrists = []
    
    # Look for common patterns in specialist listings
    name_patterns = [
        r'Dr\.?\s+[A-Z][a-z]+\s+[A-Z][a-z]+',  # Dr. First Last
        r'Dr\.?\s+[A-Z][a-z]+',  # Dr. Last
    ]
    
    for pattern in name_patterns:
        matches = re.findall(pattern, text)
        for name in matches:
            # Only include if name contains a doctor in Pune
            context = extract_context(text, name, 200)
            if 'pune' in context.lower() and any(kw in context.lower() for kw in ['psychiatr', 'ssri', 'medication']):
                # Extract contact info from context
                contact = extract_contact_info(context)
                
                psychiatrists.append({
                    'name': name,
                    'context': context,
                    'contact': contact
                })
    
    return psychiatrists

def search_file(file_path):
    """Search a file for SSRI-related content"""
    result = {
        'file_path': file_path,
        'matches': {},
        'psychiatrists': [],
        'contact_info': []
    }
    
    try:
        content = read_file_content(file_path)
        if not content:
            return None
            
        # Convert content to string if it's not already
        if not isinstance(content, str):
            try:
                content = json.dumps(content)
            except:
                content = str(content)
        
        # Search for keywords
        content_lower = content.lower()
        for keyword in SSRI_KEYWORDS:
            if keyword.lower() in content_lower:
                # Extract context for each occurrence
                contexts = []
                start_pos = 0
                while True:
                    pos = content_lower.find(keyword.lower(), start_pos)
                    if pos == -1:
                        break
                        
                    context = extract_context(content, keyword, 100)
                    contexts.append(context)
                    
                    start_pos = pos + len(keyword)
                    
                    # Limit to 5 contexts per keyword to avoid excessive output
                    if len(contexts) >= 5:
                        break
                
                result['matches'][keyword] = contexts
        
        # Extract psychiatrist information
        result['psychiatrists'] = extract_psychiatrist_info(content)
        
        # Extract contact information
        result['contact_info'] = extract_contact_info(content)
        
        return result if result['matches'] or result['psychiatrists'] or result['contact_info'] else None
        
    except Exception as e:
        print(f"Error searching {file_path}: {str(e)}", file=sys.stderr)
        return None

def main():
    """Main function to search files"""
    if len(sys.argv) != 3:
        print("Usage: ssri_search.py <files_list> <output_file>")
        sys.exit(1)
    
    files_list = sys.argv[1]
    output_file = sys.argv[2]
    
    # Read file paths
    with open(files_list, 'r') as f:
        file_paths = [line.strip() for line in f.readlines()]
    
    # Search each file
    results = []
    files_with_matches = 0
    
    total_files = len(file_paths)
    for i, file_path in enumerate(file_paths):
        # Progress indicator every 10% or for every file if verbose
        if i % max(1, total_files // 10) == 0 or i == total_files - 1:
            print(f"Searched {i+1}/{total_files} files ({((i+1)/total_files)*100:.1f}%)")
        
        result = search_file(file_path)
        if result:
            results.append(result)
            files_with_matches += 1
    
    # Write output
    with open(output_file, 'w') as f:
        json.dump({
            'summary': {
                'total_files': total_files,
                'files_with_matches': files_with_matches,
                'psychiatrist_count': sum(len(r['psychiatrists']) for r in results),
                'keyword_matches': {k: sum(1 for r in results if k in r['matches']) for k in SSRI_KEYWORDS}
            },
            'results': results
        }, f, indent=2)
    
    print(f"Search complete. Found matches in {files_with_matches} files.")
    print(f"Results saved to {output_file}")

if __name__ == "__main__":
    main()
PYEOF

    # Make the search script executable
    chmod +x "$SEARCH_SCRIPT"
    
    # Run the script
    if ! $QUIET; then
        echo -e "${YELLOW}Searching for SSRI content (this may take a few minutes)...${NC}"
    fi
    python3 "$SEARCH_SCRIPT" "$FILES_FILE" "$RESULTS_FILE"
    
    # Return the results file path
    echo "$RESULTS_FILE"
}

# Generate report from search results
generate_report() {
    RESULTS_FILE="$1"
    REPORT_FILE="$OUTPUT_DIR/ssri_specialists_report.html"
    
    if ! $QUIET; then
        echo -e "${BLUE}Generating specialist report...${NC}"
    fi
    
    # Create a Python script to generate the HTML report
    REPORT_GENERATOR="$OUTPUT_DIR/report_generator.py"
    
    cat > "$REPORT_GENERATOR" << 'PYEOF'
#!/usr/bin/env python3
"""
SSRI Specialist Report Generator
Creates an HTML report from search results.
"""

import json
import sys
import os
import datetime

def main():
    """Main function to generate report"""
    if len(sys.argv) != 3:
        print("Usage: report_generator.py <results_file> <output_file>")
        sys.exit(1)
    
    results_file = sys.argv[1]
    output_file = sys.argv[2]
    
    # Read search results
    with open(results_file, 'r') as f:
        data = json.load(f)
    
    # Extract summary and results
    summary = data['summary']
    results = data['results']
    
    # Create HTML report
    html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>SSRI Specialists in Pune - Report</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        :root {{
            --primary-color: #2c3e50;
            --secondary-color: #3498db;
            --accent-color: #e74c3c;
            --background-color: #f8f9fa;
            --card-background: #ffffff;
            --highlight-color: #ffffcc;
        }}
        
        body {{ 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            line-height: 1.6; 
            margin: 0;
            padding: 20px;
            background-color: var(--background-color);
            color: #333;
        }}
        
        h1, h2, h3 {{ color: var(--primary-color); }}
        
        .container {{
            max-width: 1200px;
            margin: 0 auto;
        }}
        
        .card {{
            background-color: var(--card-background);
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            padding: 20px;
        }}
        
        .highlight {{
            background-color: var(--highlight-color);
            padding: 2px;
            font-weight: bold;
        }}
        
        .specialist-card {{
            border-left: 4px solid var(--secondary-color);
            margin-bottom: 15px;
            padding: 10px 15px;
            background-color: #f8f9fa;
        }}
        
        .specialist-name {{
            font-size: 18px;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 5px;
        }}
        
        .contact-info {{
            font-family: monospace;
            background-color: #f0f0f0;
            padding: 5px;
            margin-top: 5px;
            border-radius: 4px;
        }}
        
        .context {{
            margin: 10px 0;
            font-size: 14px;
            line-height: 1.4;
        }}
        
        table {{
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 20px;
        }}
        
        th, td {{
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }}
        
        th {{
            background-color: var(--primary-color);
            color: white;
            font-weight: bold;
        }}
        
        tr:nth-child(even) {{
            background-color: #f2f2f2;
        }}
        
        tr:hover {{
            background-color: #ddd;
        }}
        
        .tabs {{
            display: flex;
            margin-bottom: 20px;
        }}
        
        .tab {{
            padding: 10px 20px;
            background-color: #f0f0f0;
            border: 1px solid #ddd;
            border-bottom: none;
            cursor: pointer;
            margin-right: 5px;
            border-radius: 5px 5px 0 0;
        }}
        
        .tab.active {{
            background-color: #fff;
            font-weight: bold;
        }}
        
        .tab-content {{
            display: none;
            padding: 20px;
            border: 1px solid #ddd;
            background-color: #fff;
        }}
        
        .tab-content.active {{
            display: block;
        }}
        
        .tag {{
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 12px;
            margin-right: 5px;
            margin-bottom: 5px;
            background-color: var(--secondary-color);
            color: white;
        }}
    </style>
    <script>
        function openTab(evt, tabName) {
            var i, tabcontent, tablinks;
            
            // Hide all tab contents
            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) {
                tabcontent[i].style.display = "none";
            }
            
            // Remove active class from all tabs
            tablinks = document.getElementsByClassName("tab");
            for (i = 0; i < tablinks.length; i++) {
                tablinks[i].className = tablinks[i].className.replace(" active", "");
            }
            
            // Show the selected tab content and add active class to the button
            document.getElementById(tabName).style.display = "block";
            evt.currentTarget.className += " active";
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>SSRI Specialists in Pune</h1>
        <p>Report generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        
        <div class="card">
            <h2>Summary</h2>
            <p>Analyzed {summary['total_files']} files and found matches in {summary['files_with_matches']} files.</p>
            <p>Identified approximately {summary['psychiatrist_count']} psychiatrist references.</p>
            
            <h3>Keyword Matches</h3>
            <table>
                <thead>
                    <tr>
                        <th>Keyword</th>
                        <th>Files with Matches</th>
                    </tr>
                </thead>
                <tbody>
"""
    
    # Add keyword matches table
    keyword_matches = summary.get('keyword_matches', {})
    sorted_keywords = sorted(keyword_matches.items(), key=lambda x: x[1], reverse=True)
    for keyword, count in sorted_keywords:
        if count > 0:
            html += f"""
                    <tr>
                        <td>{keyword}</td>
                        <td>{count}</td>
                    </tr>
"""
    
    html += """
                </tbody>
            </table>
        </div>
        
        <div class="tabs">
            <button class="tab active" onclick="openTab(event, 'SpecialistsTab')">Psychiatrists</button>
            <button class="tab" onclick="openTab(event, 'ContactTab')">Contact Information</button>
            <button class="tab" onclick="openTab(event, 'KeywordTab')">Keyword Matches</button>
        </div>
        
        <div id="SpecialistsTab" class="tab-content" style="display: block;">
            <h2>Psychiatrist Specialists in Pune</h2>
"""
    
    # Process psychiatrists
    all_psychiatrists = []
    for result in results:
        for psych in result.get('psychiatrists', []):
            # Skip if no context
            if not psych.get('context'):
                continue
                
            # Add file path to psychiatrist info
            psych['file_path'] = result['file_path']
            all_psychiatrists.append(psych)
    
    # Deduplicate psychiatrists by name
    unique_psychiatrists = {}
    for psych in all_psychiatrists:
        name = psych['name']
        if name not in unique_psychiatrists:
            unique_psychiatrists[name] = psych
        else:
            # Merge contact info
            existing_contact = set(unique_psychiatrists[name].get('contact', []))
            new_contact = set(psych.get('contact', []))
            unique_psychiatrists[name]['contact'] = list(existing_contact.union(new_contact))
            
            # Keep the context with the most information
            if len(psych['context']) > len(unique_psychiatrists[name]['context']):
                unique_psychiatrists[name]['context'] = psych['context']
    
    # Sort psychiatrists by name
    sorted_psychiatrists = sorted(unique_psychiatrists.values(), key=lambda x: x['name'])
    
    if sorted_psychiatrists:
        for psych in sorted_psychiatrists:
            # Process context to properly highlight keywords
            context = psych['context']
            context = context.replace("[HIGHLIGHT]", '<span class="highlight">').replace("[/HIGHLIGHT]", '</span>')
            
            html += f"""
            <div class="specialist-card">
                <div class="specialist-name">{psych['name']}</div>
                <div class="context">{context}</div>
"""
            
            if psych.get('contact'):
                html += f"""
                <div>
                    <strong>Contact Information:</strong>
                    <div class="contact-info">
                        <ul>
"""
                for contact in psych['contact']:
                    html += f"                            <li>{contact}</li>\n"
                html += """
                        </ul>
                    </div>
                </div>
"""
            
            html += """
            </div>
"""
    else:
        html += "<p>No psychiatrist specialists identified.</p>"
    
    html += """
        </div>
        
        <div id="ContactTab" class="tab-content">
            <h2>Contact Information</h2>
"""
    
    # Process contact information
    all_contacts = []
    for result in results:
        for contact in result.get('contact_info', []):
            all_contacts.append({
                'contact': contact,
                'file_path': result['file_path']
            })
    
    # Deduplicate contacts
    unique_contacts = {}
    for contact_info in all_contacts:
        contact = contact_info['contact']
        if contact not in unique_contacts:
            unique_contacts[contact] = contact_info
    
    # Sort contacts
    sorted_contacts = sorted(unique_contacts.values(), key=lambda x: x['contact'])
    
    if sorted_contacts:
        html += """
            <table>
                <thead>
                    <tr>
                        <th>Contact</th>
                        <th>Source</th>
                    </tr>
                </thead>
                <tbody>
"""
        
        for contact_info in sorted_contacts:
            html += f"""
                    <tr>
                        <td>{contact_info['contact']}</td>
                        <td>{os.path.basename(contact_info['file_path'])}</td>
                    </tr>
"""
        
        html += """
                </tbody>
            </table>
"""
    else:
        html += "<p>No contact information found.</p>"
    
    html += """
        </div>
        
        <div id="KeywordTab" class="tab-content">
            <h2>Keyword Matches</h2>
"""
    
    # Process keyword matches
    all_matches = []
    for result in results:
        for keyword, contexts in result.get('matches', {}).items():
            for context in contexts:
                all_matches.append({
                    'keyword': keyword,
                    'context': context,
                    'file_path': result['file_path']
                })
    
    # Sort matches by keyword
    sorted_matches = sorted(all_matches, key=lambda x: x['keyword'])
    
    if sorted_matches:
        # Group by keyword
        keyword_groups = {}
        for match in sorted_matches:
            keyword = match['keyword']
            if keyword not in keyword_groups:
                keyword_groups[keyword] = []
            keyword_groups[keyword].append(match)
        
        for keyword, matches in keyword_groups.items():
            html += f"""
            <div class="card">
                <h3>{keyword.upper()} <span class="tag">{len(matches)} matches</span></h3>
                <div>
"""
            
            for match in matches[:10]:  # Limit to 10 matches per keyword to avoid excessive output
                # Process context to properly highlight keywords
                context = match['context']
                context = context.replace("[HIGHLIGHT]", '<span class="highlight">').replace("[/HIGHLIGHT]", '</span>')
                
                html += f"""
                    <div style="margin-bottom: 15px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
                        <div>{context}</div>
                        <div style="font-size: 12px; color: #666; margin-top: 5px;">
                            Source: {os.path.basename(match['file_path'])}
                        </div>
                    </div>
"""
            
            if len(matches) > 10:
                html += f"""
                    <div style="font-style: italic; color: #666;">
                        {len(matches) - 10} more matches not shown
                    </div>
"""
            
            html += """
                </div>
            </div>
"""
    else:
        html += "<p>No keyword matches found.</p>"
    
    html += """
        </div>
        
        <div class="card">
            <h2>Recommended Actions</h2>
            <ol>
                <li>Contact Dr. Rishikesh Behere at Manoshanti Clinic (Baner)</li>
                <li>Inquire specifically about experience with SSRI-induced apathy syndrome</li>
                <li>Ask about their assessment of medication effects on decision-making capacity</li>
                <li>Request written evaluation on hospital letterhead</li>
                <li>Bring documentation of medication timeline (Mar-Nov 2024)</li>
            </ol>
        </div>
        
        <div style="margin-top: 30px; border-top: 1px solid #ddd; padding-top: 10px; font-size: 12px; color: #7f8c8d; text-align: center;">
            <p>Generated by SSRI Specialist Finder - For medical consultation purposes only</p>
        </div>
    </div>
</body>
</html>
"""

    # Write HTML report
    with open(output_file, 'w') as f:
        f.write(html)
    
    print(f"Report generated at {output_file}")

if __name__ == "__main__":
    main()
PYEOF

    # Make the report generator executable
    chmod +x "$REPORT_GENERATOR"
    
    # Run the report generator
    if ! $QUIET; then
        echo -e "${YELLOW}Generating specialist report...${NC}"
    fi
    python3 "$REPORT_GENERATOR" "$RESULTS_FILE" "$REPORT_FILE"
    
    # Return the report file path
    echo "$REPORT_FILE"
}

# Main execution
echo -e "${GREEN}Starting SSRI Specialist Finder...${NC}"

# Run core functions
FILES_FILE=$(find_files)
RESULTS_FILE=$(search_ssri_content "$FILES_FILE")
REPORT_FILE=$(generate_report "$RESULTS_FILE")

# Open the report
if [ -f "$REPORT_FILE" ]; then
    if ! $QUIET; then echo -e "${GREEN}Opening report...${NC}"; fi
    
    if command -v open &> /dev/null; then
        open "$REPORT_FILE"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$REPORT_FILE"
    else
        echo -e "${YELLOW}Report generated at: $REPORT_FILE${NC}"
    fi
fi

echo -e "${GREEN}SSRI Specialist Finder completed successfully!${NC}"
