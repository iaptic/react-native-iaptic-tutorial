#!/bin/bash

cd "$(dirname "$0")"

# Define directories
OUTPUT_DIR="tutorial-html"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to check if a tool is installed
check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "Error: $1 is required but not installed."
    echo "Please install it using your package manager."
    echo "For example: brew install $1 (on macOS) or apt-get install $1 (on Debian/Ubuntu)"
    exit 1
  fi
}

# Check if pandoc is installed
check_command pandoc

echo "Building tutorial..."

# Process all markdown files
for md_file in tutorial-*.md; do
  if [ -f "$md_file" ]; then
    echo "Converting $md_file to HTML..."
    base_name=$(basename "$md_file" .md)
    html_file="$OUTPUT_DIR/${base_name}.html"
    
    # Convert markdown to HTML using pandoc with some styling
    pandoc "$md_file" -o "$html_file" --standalone --css tutorial-style.css \
      --metadata title="React Native In-App Purchase Tutorial"

    echo "Created $html_file"
  fi
done

# Create a simple CSS file if it doesn't exist
if [ ! -f "$OUTPUT_DIR/tutorial-style.css" ]; then
  echo "Creating tutorial-style.css..."
  cat > "$OUTPUT_DIR/tutorial-style.css" << 'EOF'
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  line-height: 1.6;
  color: #333;
  max-width: 900px;
  margin: 0 auto;
  padding: 20px;
}

code {
  font-family: SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace;
  background-color: #f5f5f5;
  padding: 2px 4px;
  border-radius: 3px;
  font-size: 0.9em;
}

pre {
  background-color: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 16px;
  overflow: auto;
}

pre code {
  background-color: transparent;
  padding: 0;
}

h1, h2, h3, h4 {
  margin-top: 24px;
  margin-bottom: 16px;
  font-weight: 600;
  line-height: 1.25;
}

h1 {
  font-size: 2em;
  border-bottom: 1px solid #eaecef;
  padding-bottom: 0.3em;
}

h2 {
  font-size: 1.5em;
  border-bottom: 1px solid #eaecef;
  padding-bottom: 0.3em;
}

h3 {
  font-size: 1.25em;
}

h4 {
  font-size: 1em;
}

a {
  color: #0366d6;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

.navigation {
  display: flex;
  justify-content: space-between;
  margin: 30px 0;
  padding: 15px 0;
  border-top: 1px solid #eee;
  border-bottom: 1px solid #eee;
}

.nav-button {
  padding: 10px 15px;
  background-color: #007AFF;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-weight: bold;
}

.nav-button.prev {
  background-color: #6c757d;
}
EOF
  echo "Created tutorial-style.css"
fi

# Copy existing HTML files that don't have markdown equivalents
for html_file in tutorial-*.html; do
  if [ -f "$html_file" ]; then
    md_file="${html_file%.html}.md"
    if [ ! -f "$md_file" ]; then
      echo "Copying $html_file to output directory (no markdown equivalent)..."
      cp "$html_file" "$OUTPUT_DIR/"
      echo "Copied $html_file"
    fi
  fi
done

echo "Tutorial build complete in $OUTPUT_DIR directory." 
