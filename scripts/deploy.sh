#!/bin/bash

# Microsoft Copilot Studio - Teams Deployment Script
# This script automates the deployment of Copilot Studio agents to Microsoft Teams

set -e  # Exit on any error

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$REPO_ROOT/config"
TEAMS_APP_DIR="$REPO_ROOT/teams-app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log_warning "Azure CLI not found. Please install Azure CLI."
        echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    else
        log_success "Azure CLI found"
    fi
    
    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 not found. Please install Python 3.8 or later."
        exit 1
    else
        log_success "Python 3 found: $(python3 --version)"
    fi
    
    # Check if Node.js is installed (for Teams Toolkit)
    if ! command -v node &> /dev/null; then
        log_warning "Node.js not found. Teams Toolkit requires Node.js."
        echo "Visit: https://nodejs.org/"
    else
        log_success "Node.js found: $(node --version)"
    fi
    
    # Check if configuration files exist
    if [[ ! -f "$CONFIG_DIR/bot-config.json" ]]; then
        log_error "Bot configuration file not found: $CONFIG_DIR/bot-config.json"
        exit 1
    fi
    
    if [[ ! -f "$CONFIG_DIR/copilot-settings.json" ]]; then
        log_error "Copilot settings file not found: $CONFIG_DIR/copilot-settings.json"
        exit 1
    fi
    
    log_success "All prerequisites checked"
}

# Function to validate configuration
validate_configuration() {
    log_info "Validating configuration files..."
    
    # Validate bot-config.json
    if python3 -m json.tool "$CONFIG_DIR/bot-config.json" > /dev/null 2>&1; then
        log_success "bot-config.json is valid JSON"
    else
        log_error "bot-config.json is not valid JSON"
        exit 1
    fi
    
    # Validate copilot-settings.json
    if python3 -m json.tool "$CONFIG_DIR/copilot-settings.json" > /dev/null 2>&1; then
        log_success "copilot-settings.json is valid JSON"
    else
        log_error "copilot-settings.json is not valid JSON"
        exit 1
    fi
    
    # Check if Teams manifest exists
    if [[ -f "$TEAMS_APP_DIR/manifest.json" ]]; then
        if python3 -m json.tool "$TEAMS_APP_DIR/manifest.json" > /dev/null 2>&1; then
            log_success "Teams manifest is valid JSON"
        else
            log_error "Teams manifest is not valid JSON"
            exit 1
        fi
    else
        log_warning "Teams manifest not found. Using template."
        if [[ -f "$TEAMS_APP_DIR/manifest-template.json" ]]; then
            cp "$TEAMS_APP_DIR/manifest-template.json" "$TEAMS_APP_DIR/manifest.json"
            log_info "Copied manifest template to manifest.json"
        fi
    fi
}

# Function to install Python dependencies
install_dependencies() {
    log_info "Installing Python dependencies..."
    
    if [[ -f "$REPO_ROOT/requirements.txt" ]]; then
        python3 -m pip install --user -r "$REPO_ROOT/requirements.txt"
        log_success "Python dependencies installed"
    else
        log_warning "requirements.txt not found. Skipping dependency installation."
    fi
}

# Function to create Azure resources
create_azure_resources() {
    log_info "Creating Azure resources (simulation)..."
    
    # Note: This is a simulation - actual implementation would require Azure CLI commands
    log_info "Would create the following Azure resources:"
    echo "  - App Registration for Bot Framework"
    echo "  - Azure Bot Service"
    echo "  - App Service for hosting"
    echo "  - Application Insights for monitoring"
    
    log_warning "Azure resource creation is simulated. Please manually create resources or implement Azure CLI commands."
}

# Function to deploy to Teams
deploy_to_teams() {
    log_info "Preparing Teams app package..."
    
    # Create Teams app package directory if it doesn't exist
    mkdir -p "$TEAMS_APP_DIR"
    
    # Check for required icon files
    if [[ ! -f "$TEAMS_APP_DIR/color.png" ]]; then
        log_warning "color.png not found. Teams app requires a 192x192 color icon."
    fi
    
    if [[ ! -f "$TEAMS_APP_DIR/outline.png" ]]; then
        log_warning "outline.png not found. Teams app requires a 32x32 outline icon."
    fi
    
    # Create app package (simulation)
    if [[ -f "$TEAMS_APP_DIR/manifest.json" ]]; then
        log_info "Teams app manifest found. Ready for packaging."
        
        # In a real deployment, this would:
        # 1. Validate the manifest
        # 2. Create a .zip package with manifest and icons
        # 3. Upload to Teams App Catalog or submit for approval
        
        log_success "Teams deployment preparation complete"
    else
        log_error "Teams manifest not found. Cannot proceed with deployment."
        exit 1
    fi
}

# Function to run tests
run_tests() {
    log_info "Running deployment validation tests..."
    
    # Run the Python configuration manager validation
    if [[ -f "$SCRIPT_DIR/python/copilot_config_manager.py" ]]; then
        python3 "$SCRIPT_DIR/python/copilot_config_manager.py" --validate
        log_success "Configuration validation completed"
    else
        log_warning "Configuration manager not found. Skipping validation tests."
    fi
}

# Function to generate deployment report
generate_report() {
    log_info "Generating deployment report..."
    
    REPORT_FILE="$REPO_ROOT/deployment-report-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$REPORT_FILE" << EOF
# Copilot Studio Deployment Report

**Generated**: $(date)
**Repository**: $(basename "$REPO_ROOT")

## Deployment Summary

### Configuration Files
- Bot Configuration: $([ -f "$CONFIG_DIR/bot-config.json" ] && echo "✅ Present" || echo "❌ Missing")
- Copilot Settings: $([ -f "$CONFIG_DIR/copilot-settings.json" ] && echo "✅ Present" || echo "❌ Missing")
- Teams Manifest: $([ -f "$TEAMS_APP_DIR/manifest.json" ] && echo "✅ Present" || echo "❌ Missing")

### Dependencies
- Python Requirements: $([ -f "$REPO_ROOT/requirements.txt" ] && echo "✅ Present" || echo "❌ Missing")

### Deployment Status
- Azure Resources: ⚠️ Manual creation required
- Teams App Package: ⚠️ Requires manual validation and submission

## Next Steps

1. Configure Azure Bot Service
2. Update manifest.json with actual App IDs
3. Add Teams app icons (color.png, outline.png)
4. Test bot functionality
5. Submit to Teams App Catalog

## Files Generated
- Deployment report: $(basename "$REPORT_FILE")
EOF

    log_success "Deployment report generated: $REPORT_FILE"
}

# Main deployment function
main() {
    echo "========================================"
    echo "Microsoft Copilot Studio Teams Deployment"
    echo "========================================"
    echo ""
    
    check_prerequisites
    validate_configuration
    install_dependencies
    create_azure_resources
    deploy_to_teams
    run_tests
    generate_report
    
    echo ""
    log_success "Deployment script completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Review the deployment report"
    echo "2. Configure Azure resources manually"
    echo "3. Update configuration files with actual values"
    echo "4. Test the deployment in Teams"
}

# Handle script arguments
case "${1:-}" in
    "help"|"-h"|"--help")
        echo "Microsoft Copilot Studio Teams Deployment Script"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  help          Show this help message"
        echo "  check         Check prerequisites only"
        echo "  validate      Validate configuration only"
        echo "  test          Run tests only"
        echo "  (no args)     Run full deployment"
        ;;
    "check")
        check_prerequisites
        ;;
    "validate")
        validate_configuration
        ;;
    "test")
        run_tests
        ;;
    *)
        main
        ;;
esac