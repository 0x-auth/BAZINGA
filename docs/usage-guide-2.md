# General Purpose File Analyzer

This tool finds and analyzes files and scripts across your system, providing insights into their patterns, characteristics, and organization.

## Features

- Customizable file search across multiple directories
- Support for a wide range of file types and patterns
- Detailed file analysis including size, content, and patterns
- Identification of common patterns in code files
- Visualization through interactive HTML reports
- Searchable file database for further analysis

## Quick Start

1. Download the script and make it executable:
   ```bash
   chmod +x file-analyzer.sh
   ```

2. Run with default settings (searches common directories for script files):
   ```bash
   ./file-analyzer.sh
   ```

3. View the generated HTML report that will open automatically in your browser.

## Command Line Options

```
Usage: ./file-analyzer.sh [options]

Options:
  -h, --help               Show this help message
  -p, --path PATH          Add search path (can be used multiple times)
  -f, --file-pattern PAT   Add file pattern (can be used multiple times)
  -e, --exclude PAT        Add exclusion pattern (can be used multiple times)
  -o, --output DIR         Set output directory
  -q, --quiet              Suppress progress messages
  -v, --verbose            Show detailed progress
```

## Examples

### Analyze Python files in a specific directory

```bash
./file-analyzer.sh --path ~/Projects/python-app --file-pattern "*.py"
```

### Analyze multiple file types across multiple directories

```bash
./file-analyzer.sh --path ~/Projects --path ~/Documents --file-pattern "*.js" --file-pattern "*.html" --file-pattern "*.css"
```

### Exclude certain directories

```bash
./file-analyzer.sh --path ~/Projects --exclude "node_modules" --exclude "venv" --exclude "dist"
```

### Specify output directory

```bash
./file-analyzer.sh --path ~/Projects --output ~/analysis-results
```

### Suppress progress messages

```bash
./file-analyzer.sh --path ~/Projects --quiet
```

## Understanding the Results

The analysis produces several outputs:

1. **HTML Report** - Interactive visualization of file analysis results
2. **Analysis JSON** - Raw analysis data in JSON format
3. **File Database** - Searchable database of files and their characteristics
4. **File Paths List** - List of all files found during search

## Pattern Identification

The tool identifies several common patterns in code files:

- **Network** - Code related to HTTP, URLs, APIs, sockets, etc.
- **Security** - Code related to authentication, encryption, tokens, etc.
- **Database** - Code related to SQL, queries, database operations, etc.
- **Filesystem** - Code related to file operations, paths, directories, etc.
- **Time** - Code related to dates, scheduling, timers, etc.
- **Error Handling** - Code related to exceptions, error management, etc.
- **Logging** - Code related to logging operations
- **Threading** - Code related to multithreading, concurrency, etc.

## Use Cases

- **Code Quality Assessment** - Identify files with insufficient comments or complex patterns
- **Security Auditing** - Find files with security-related code for review
- **Codebase Organization** - Understand file distribution and characteristics
- **Technical Debt Analysis** - Identify large, complex files that may need refactoring
- **Duplicate Detection** - Find potentially duplicate files through hash comparison

## Integration with Other Tools

The JSON database can be used to integrate with other analysis tools or custom scripts. Example of reading the database:

```python
import json

# Load the database
with open('file_database.json', 'r') as f:
    db = json.load(f)

# Find all JavaScript files
js_files = [file_info for file_id, file_info in db['files'].items() 
            if file_info['type'] == 'text/javascript']

# Find files with security patterns
security_files = [file_info for file_id, file_info in db['files'].items() 
                 if file_info.get('dominant_pattern') == 'security']

# Print results
print(f"Found {len(js_files)} JavaScript files")
print(f"Found {len(security_files)} files with security patterns")
```
