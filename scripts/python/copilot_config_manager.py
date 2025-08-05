#!/usr/bin/env python3
"""
Microsoft Copilot Studio Configuration Manager

This script helps manage Copilot Studio agent configurations and provides
utilities for Teams deployment preparation.

Usage:
    python copilot_config_manager.py --scan
    python copilot_config_manager.py --validate
    python copilot_config_manager.py --generate-manifest
"""

import os
import json
import argparse
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional

class CopilotConfigManager:
    """Manages Copilot Studio configurations and deployment assets."""
    
    def __init__(self, repo_root: str = None):
        self.repo_root = Path(repo_root) if repo_root else Path.cwd()
        self.config_dir = self.repo_root / "config"
        self.scripts_dir = self.repo_root / "scripts"
        
    def scan_repository(self) -> Dict[str, Any]:
        """Scan repository for Copilot Studio related files."""
        print("🔍 Scanning repository for Copilot Studio assets...")
        
        file_categories = {
            "documentation": [],
            "configuration": [],
            "scripts": [],
            "teams_assets": [],
            "bot_framework": [],
            "missing_critical": []
        }
        
        # Define file patterns for each category
        patterns = {
            "documentation": ["*.md", "*.txt", "*.rst"],
            "configuration": ["*.json", "*.yaml", "*.yml", "*.config"],
            "scripts": ["*.py", "*.sh", "*.ps1", "*.bat"],
            "teams_assets": ["manifest.json", "*.png", "*.ico"],
            "bot_framework": ["*.bot", "*bot*.json"]
        }
        
        # Scan for existing files
        for file_path in self.repo_root.rglob("*"):
            if file_path.is_file() and ".git" not in str(file_path):
                relative_path = file_path.relative_to(self.repo_root)
                
                # Categorize files
                categorized = False
                for category, pattern_list in patterns.items():
                    for pattern in pattern_list:
                        if file_path.match(pattern) or file_path.name.lower() in [p.lower() for p in pattern_list]:
                            file_categories[category].append({
                                "path": str(relative_path),
                                "size": file_path.stat().st_size,
                                "modified": datetime.fromtimestamp(file_path.stat().st_mtime).isoformat()
                            })
                            categorized = True
                            break
                    if categorized:
                        break
        
        # Check for missing critical files
        critical_files = [
            "teams-app/manifest.json",
            "config/bot-config.json",
            "config/copilot-settings.json",
            "scripts/deploy.sh",
            "requirements.txt"
        ]
        
        for critical_file in critical_files:
            if not (self.repo_root / critical_file).exists():
                file_categories["missing_critical"].append(critical_file)
        
        return file_categories
    
    def validate_configuration(self) -> Dict[str, Any]:
        """Validate current configuration for Teams deployment readiness."""
        print("✅ Validating configuration for Teams deployment...")
        
        validation_results = {
            "overall_score": 0,
            "max_score": 100,
            "checks": []
        }
        
        checks = [
            ("README.md exists", self._check_readme, 15),
            ("SECURITY.md exists", self._check_security, 10),
            ("LICENSE exists", self._check_license, 5),
            ("Bot configuration", self._check_bot_config, 25),
            ("Teams manifest", self._check_teams_manifest, 25),
            ("Deployment scripts", self._check_deployment_scripts, 10),
            ("Python dependencies", self._check_python_deps, 10)
        ]
        
        for check_name, check_func, points in checks:
            passed, message = check_func()
            validation_results["checks"].append({
                "name": check_name,
                "passed": passed,
                "message": message,
                "points": points if passed else 0
            })
            if passed:
                validation_results["overall_score"] += points
        
        return validation_results
    
    def generate_teams_manifest_template(self) -> Dict[str, Any]:
        """Generate a Teams app manifest template."""
        print("📱 Generating Teams app manifest template...")
        
        manifest = {
            "$schema": "https://developer.microsoft.com/en-us/json-schemas/teams/v1.16/MicrosoftTeams.schema.json",
            "manifestVersion": "1.16",
            "version": "1.0.0",
            "id": "00000000-0000-0000-0000-000000000000",  # Generate unique ID
            "packageName": "com.company.copilot-studio-agent",
            "developer": {
                "name": "Your Company",
                "websiteUrl": "https://your-company.com",
                "privacyUrl": "https://your-company.com/privacy",
                "termsOfUseUrl": "https://your-company.com/terms"
            },
            "icons": {
                "color": "color.png",
                "outline": "outline.png"
            },
            "name": {
                "short": "Copilot Studio Agent",
                "full": "Microsoft Copilot Studio Agent"
            },
            "description": {
                "short": "AI-powered assistant for Teams",
                "full": "Advanced AI assistant built with Microsoft Copilot Studio for enhanced productivity in Teams"
            },
            "accentColor": "#FFFFFF",
            "bots": [
                {
                    "botId": "00000000-0000-0000-0000-000000000000",  # Bot Framework App ID
                    "scopes": ["personal", "team", "groupchat"],
                    "supportsFiles": False,
                    "isNotificationOnly": False
                }
            ],
            "permissions": ["identity", "messageTeamMembers"],
            "validDomains": ["your-bot-domain.com"]
        }
        
        return manifest
    
    def _check_readme(self) -> tuple[bool, str]:
        readme_path = self.repo_root / "README.md"
        if readme_path.exists():
            content = readme_path.read_text()
            if "copilot studio" in content.lower() or "teams" in content.lower():
                return True, "README.md exists with Copilot Studio content"
            return True, "README.md exists but needs Copilot Studio enhancement"
        return False, "README.md missing"
    
    def _check_security(self) -> tuple[bool, str]:
        return (self.repo_root / "SECURITY.md").exists(), "Security documentation"
    
    def _check_license(self) -> tuple[bool, str]:
        return (self.repo_root / "LICENSE").exists(), "License file"
    
    def _check_bot_config(self) -> tuple[bool, str]:
        config_files = list(self.repo_root.rglob("*bot*.json"))
        return len(config_files) > 0, f"Bot configuration files: {len(config_files)} found"
    
    def _check_teams_manifest(self) -> tuple[bool, str]:
        manifest_files = list(self.repo_root.rglob("manifest.json"))
        return len(manifest_files) > 0, f"Teams manifest files: {len(manifest_files)} found"
    
    def _check_deployment_scripts(self) -> tuple[bool, str]:
        script_files = list(self.repo_root.rglob("deploy*"))
        return len(script_files) > 0, f"Deployment scripts: {len(script_files)} found"
    
    def _check_python_deps(self) -> tuple[bool, str]:
        req_file = self.repo_root / "requirements.txt"
        setup_file = self.repo_root / "setup.py"
        return req_file.exists() or setup_file.exists(), "Python dependencies configuration"
    
    def create_project_structure(self):
        """Create recommended project structure for Copilot Studio development."""
        print("🏗️ Creating recommended project structure...")
        
        directories = [
            "config",
            "scripts/python",
            "scripts/powershell", 
            "scripts/bash",
            "teams-app",
            "docs",
            "agents",
            "tests",
            "deployment"
        ]
        
        for directory in directories:
            dir_path = self.repo_root / directory
            dir_path.mkdir(parents=True, exist_ok=True)
            print(f"   Created: {directory}/")
            
            # Create README for each directory
            readme_path = dir_path / "README.md"
            if not readme_path.exists():
                readme_path.write_text(f"# {directory.title()}\n\nThis directory contains {directory} related files for Copilot Studio development.\n")

def main():
    parser = argparse.ArgumentParser(description="Microsoft Copilot Studio Configuration Manager")
    parser.add_argument("--scan", action="store_true", help="Scan repository for Copilot Studio assets")
    parser.add_argument("--validate", action="store_true", help="Validate configuration for Teams deployment")
    parser.add_argument("--generate-manifest", action="store_true", help="Generate Teams app manifest template")
    parser.add_argument("--create-structure", action="store_true", help="Create recommended project structure")
    parser.add_argument("--repo-root", help="Repository root path", default=".")
    
    args = parser.parse_args()
    
    if len(sys.argv) == 1:
        parser.print_help()
        return
    
    manager = CopilotConfigManager(args.repo_root)
    
    if args.scan:
        results = manager.scan_repository()
        print("\n📊 Repository Scan Results:")
        for category, files in results.items():
            print(f"\n{category.title().replace('_', ' ')}:")
            if isinstance(files, list) and files:
                for file_info in files:
                    if isinstance(file_info, dict):
                        print(f"  - {file_info['path']} ({file_info['size']} bytes)")
                    else:
                        print(f"  - {file_info}")
            elif not files:
                print("  - None found")
    
    if args.validate:
        results = manager.validate_configuration()
        print(f"\n🎯 Validation Score: {results['overall_score']}/{results['max_score']}")
        print("\nDetailed Results:")
        for check in results["checks"]:
            status = "✅" if check["passed"] else "❌"
            print(f"  {status} {check['name']}: {check['message']} ({check['points']} points)")
    
    if args.generate_manifest:
        manifest = manager.generate_teams_manifest_template()
        output_path = Path(args.repo_root) / "teams-app" / "manifest-template.json"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(manifest, indent=2))
        print(f"📱 Teams manifest template created: {output_path}")
    
    if args.create_structure:
        manager.create_project_structure()
        print("🎉 Project structure created successfully!")

if __name__ == "__main__":
    main()