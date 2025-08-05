#!/bin/bash

# File Inventory Generator for Copilot Studio Development
# This script scans the repository and generates a comprehensive file inventory
# Useful for tracking development assets and planning Copilot Studio deployment

echo "=== Microsoft Copilot Studio - Repository File Inventory ==="
echo "Generated on: $(date)"
echo ""

# Function to categorize files
categorize_file() {
    local file="$1"
    local extension="${file##*.}"
    local basename=$(basename "$file")
    
    case "$extension" in
        "md")
            echo "📋 Documentation"
            ;;
        "py")
            echo "🐍 Python Script"
            ;;
        "sh")
            echo "🔧 Shell Script"
            ;;
        "json")
            echo "⚙️ Configuration"
            ;;
        "yaml"|"yml")
            echo "⚙️ Configuration"
            ;;
        "js"|"ts")
            echo "🌐 JavaScript/TypeScript"
            ;;
        "txt")
            echo "📄 Text File"
            ;;
        *)
            if [[ "$basename" == "LICENSE" ]]; then
                echo "📄 License"
            elif [[ "$basename" == ".gitignore" ]]; then
                echo "⚙️ Git Configuration"
            else
                echo "📁 Other"
            fi
            ;;
    esac
}

# Function to assess Copilot Studio relevance
assess_copilot_relevance() {
    local file="$1"
    local basename=$(basename "$file")
    
    case "$basename" in
        "README.md")
            echo "⭐⭐⭐⭐⭐ Critical - Primary documentation"
            ;;
        "SECURITY.md")
            echo "⭐⭐⭐⭐⭐ Critical - Security requirements"
            ;;
        "SUPPORT.md")
            echo "⭐⭐⭐⭐ High - Support procedures"
            ;;
        "CODE_OF_CONDUCT.md")
            echo "⭐⭐⭐ Medium - Team collaboration"
            ;;
        "LICENSE")
            echo "⭐⭐⭐⭐ High - Legal compliance"
            ;;
        ".gitignore")
            echo "⭐⭐⭐ Medium - Development workflow"
            ;;
        *.py)
            echo "⭐⭐⭐⭐⭐ Critical - Core development"
            ;;
        *.sh)
            echo "⭐⭐⭐⭐ High - Automation"
            ;;
        *manifest.json)
            echo "⭐⭐⭐⭐⭐ Critical - Teams deployment"
            ;;
        *bot*.json)
            echo "⭐⭐⭐⭐⭐ Critical - Bot configuration"
            ;;
        *)
            echo "⭐⭐ Low - General purpose"
            ;;
    esac
}

# Get repository root
REPO_ROOT="/home/runner/work/Copilot-Studio/Copilot-Studio"

echo "Repository Path: $REPO_ROOT"
echo ""

# Count files by type
echo "=== File Type Summary ==="
total_files=$(find "$REPO_ROOT" -type f -not -path "*/\.git/*" | wc -l)
echo "Total Files: $total_files"

md_files=$(find "$REPO_ROOT" -name "*.md" -not -path "*/\.git/*" | wc -l)
py_files=$(find "$REPO_ROOT" -name "*.py" -not -path "*/\.git/*" | wc -l)
sh_files=$(find "$REPO_ROOT" -name "*.sh" -not -path "*/\.git/*" | wc -l)
json_files=$(find "$REPO_ROOT" -name "*.json" -not -path "*/\.git/*" | wc -l)
yaml_files=$(find "$REPO_ROOT" \( -name "*.yaml" -o -name "*.yml" \) -not -path "*/\.git/*" | wc -l)

echo "Markdown Files: $md_files"
echo "Python Scripts: $py_files"
echo "Shell Scripts: $sh_files"
echo "JSON Files: $json_files"
echo "YAML Files: $yaml_files"
echo ""

# Detailed file inventory
echo "=== Detailed File Inventory ==="
echo ""

find "$REPO_ROOT" -type f -not -path "*/\.git/*" | sort | while read -r file; do
    relative_path=${file#$REPO_ROOT/}
    category=$(categorize_file "$file")
    relevance=$(assess_copilot_relevance "$file")
    file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "Unknown")
    
    echo "📁 File: $relative_path"
    echo "   Category: $category"
    echo "   Copilot Studio Relevance: $relevance"
    echo "   Size: $file_size bytes"
    echo ""
done

echo "=== Teams Deployment Readiness Assessment ==="
echo ""

# Check for critical Teams deployment files
teams_manifest=$(find "$REPO_ROOT" -name "manifest.json" -not -path "*/\.git/*")
bot_config=$(find "$REPO_ROOT" -name "*bot*.json" -not -path "*/\.git/*")
deployment_scripts=$(find "$REPO_ROOT" -name "deploy*.sh" -not -path "*/\.git/*")

echo "Teams App Manifest: $([ -n "$teams_manifest" ] && echo "✅ Found" || echo "❌ Missing")"
echo "Bot Configuration: $([ -n "$bot_config" ] && echo "✅ Found" || echo "❌ Missing")"
echo "Deployment Scripts: $([ -n "$deployment_scripts" ] && echo "✅ Found" || echo "❌ Missing")"

# Calculate readiness score
readiness_score=0
[ -f "$REPO_ROOT/README.md" ] && ((readiness_score += 20))
[ -f "$REPO_ROOT/SECURITY.md" ] && ((readiness_score += 15))
[ -f "$REPO_ROOT/LICENSE" ] && ((readiness_score += 10))
[ -f "$REPO_ROOT/.gitignore" ] && ((readiness_score += 5))
[ -n "$teams_manifest" ] && ((readiness_score += 25))
[ -n "$bot_config" ] && ((readiness_score += 25))

echo ""
echo "Teams Deployment Readiness: $readiness_score/100"

if [ $readiness_score -ge 80 ]; then
    echo "Status: ✅ Ready for deployment"
elif [ $readiness_score -ge 50 ]; then
    echo "Status: ⚠️ Needs enhancement"
else
    echo "Status: ❌ Requires significant development"
fi

echo ""
echo "=== Recommendations ==="
echo ""

if [ $readiness_score -lt 80 ]; then
    echo "Priority Actions:"
    [ -z "$teams_manifest" ] && echo "- Create Teams app manifest (manifest.json)"
    [ -z "$bot_config" ] && echo "- Add bot framework configuration"
    [ -z "$deployment_scripts" ] && echo "- Create deployment automation scripts"
    [ $py_files -eq 0 ] && echo "- Add Python development scripts"
    echo "- Enhance documentation with Copilot Studio specifics"
fi

echo ""
echo "=== End of Report ==="