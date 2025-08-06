# Tools and Utilities

This directory contains helper scripts, configuration files, and utility tools to support Microsoft 365 Copilot Studio development and deployment.

## Available Tools

### 1. Environment Setup Scripts
- **setup-environment.ps1** - PowerShell script to configure Power Platform environment
- **configure-azure-ad.ps1** - Azure AD app registration and permission setup
- **validate-prerequisites.ps1** - Check system requirements and dependencies

### 2. Deployment Automation
- **deploy-agent.yml** - Azure DevOps pipeline for agent deployment
- **github-actions.yml** - GitHub Actions workflow for CI/CD
- **terraform-config** - Infrastructure as Code templates

### 3. Testing and Validation
- **test-agent.ps1** - Automated testing scripts for agent validation
- **performance-test.js** - Load testing scripts for performance validation
- **security-scan.yml** - Security scanning and compliance checks

### 4. Monitoring and Analytics
- **monitoring-setup.ps1** - Configure Azure Monitor and Application Insights
- **analytics-dashboard.json** - Power BI dashboard templates
- **alerting-rules.json** - Azure Monitor alerting configurations

### 5. Configuration Templates
- **app-manifest.json** - Teams app manifest template
- **flow-templates** - Power Automate flow export files
- **environment-config.json** - Environment configuration templates

## Usage Instructions

### Environment Setup
```powershell
# Run environment setup script
.\tools\setup-environment.ps1 -EnvironmentName "YourEnvironment" -Region "unitedstates"

# Configure Azure AD
.\tools\configure-azure-ad.ps1 -AppName "YourCopilotApp" -RequiredPermissions @("User.Read", "Calendars.ReadWrite")
```

### Deployment
```bash
# Using GitHub Actions
git push origin main  # Triggers automated deployment

# Using Azure DevOps
az pipelines run --name "Deploy-Copilot-Agent" --branch main
```

### Testing
```powershell
# Run comprehensive tests
.\tools\test-agent.ps1 -AgentUrl "https://your-agent-url" -TestSuite "comprehensive"

# Performance testing
node tools\performance-test.js --concurrent-users 100 --duration 300
```

### Monitoring Setup
```powershell
# Configure monitoring
.\tools\monitoring-setup.ps1 -ResourceGroup "YourResourceGroup" -AgentName "YourAgent"
```

## Tool Documentation

Each tool includes comprehensive documentation and usage examples. Refer to individual tool directories for detailed instructions and configuration options.

## Contributing

When contributing new tools or utilities:
1. Include comprehensive documentation
2. Add usage examples and test cases
3. Follow PowerShell/scripting best practices
4. Update this README with new tool information