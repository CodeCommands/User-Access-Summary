# Developer Guide: Creating New Versions of User Access Summary App

## 📋 Prerequisites

Before creating a new version, ensure you have:

- ✅ **Salesforce CLI installed** and updated
- ✅ **Dev Hub org connected** (`agentforce-devhub`)
- ✅ **Development org** for testing changes
- ✅ **Git repository** with latest changes
- ✅ **Package created** (`UserAccessSummaryApp`)

## 🔄 Complete Version Release Process

### Phase 1: Development and Testing

#### 1.1 Set Up Development Environment
```bash
# Navigate to project directory
cd "C:/Users/pawan/Documents/Salesforce Projects/User Access Summary"

# Check current org connections
sf org list

# Connect to development org if needed
sf org login web --alias dev-org

# Verify Dev Hub connection
sf org display --target-org agentforce-devhub
```

#### 1.2 Make Your Changes
```bash
# Create a new branch for your changes (optional but recommended)
git checkout -b feature/new-version

# Make your code changes in force-app/main/default/
# - Update Apex classes
# - Modify Lightning Web Components
# - Update metadata
```

#### 1.3 Deploy and Test Changes
```bash
# Deploy to development org for testing
sf project deploy start --target-org dev-org

# Run tests to ensure everything works
sf apex run test --target-org dev-org --result-format human --code-coverage

# Test manually in the org
sf org open --target-org dev-org
```

### Phase 2: Package Version Creation

#### 2.1 Verify Dev Hub and Package Status
```bash
# Check current package versions
sf package version list --target-dev-hub agentforce-devhub --packages "UserAccessSummaryApp"

# Check package details
sf package list --target-dev-hub agentforce-devhub
```

#### 2.2 Update Version Information
```bash
# Check current sfdx-project.json
cat sfdx-project.json

# The version number will auto-increment from "1.0.0.NEXT"
# If you want to change version name, edit sfdx-project.json:
# "versionName": "ver 1.1" (for feature updates)
# "versionName": "ver 2.0" (for major updates)
```

#### 2.3 Create New Package Version

**Option A: With Full Validation (Recommended for Production)**
```bash
sf package version create \
  --package "UserAccessSummaryApp" \
  --installation-key-bypass \
  --wait 15 \
  --target-dev-hub agentforce-devhub \
  --code-coverage
```

**Option B: Skip Validation (For Quick Testing)**
```bash
sf package version create \
  --package "UserAccessSummaryApp" \
  --installation-key-bypass \
  --wait 15 \
  --target-dev-hub agentforce-devhub \
  --skip-validation
```

#### 2.4 Get Package Version Details
```bash
# List all versions
sf package version list --target-dev-hub agentforce-devhub --packages "UserAccessSummaryApp"

# Get specific version details (replace with your version ID)
sf package version report --package "UserAccessSummaryApp@1.0.0-3" --target-dev-hub agentforce-devhub
```

### Phase 3: Update Project Documentation

#### 3.1 Update sfdx-project.json
The package aliases are automatically updated, but verify:
```json
{
  "packageAliases": {
    "UserAccessSummaryApp": "0HogL0000000PPpSAM",
    "UserAccessSummaryApp@1.0.0-1": "04tgL0000004sMnQAI",
    "UserAccessSummaryApp@1.0.0-2": "04tgL0000004sLCQAY",
    "UserAccessSummaryApp@1.0.0-3": "NEW_VERSION_ID_HERE"
  }
}
```

#### 3.2 Update Installation Scripts
```bash
# Get the new installation URL from the package creation output
# Update scripts/install-package.sh
# Update scripts/install-package.bat
```

**Example update for install-package.sh:**
```bash
# Find this line:
echo "https://login.salesforce.com/packaging/installPackage.apexp?p0=04tgL0000004sLCQAY"

# Replace with new Package Version ID:
echo "https://login.salesforce.com/packaging/installPackage.apexp?p0=NEW_PACKAGE_VERSION_ID"

# Also update version number:
echo "• Version: 1.0.0-3"
echo "• Subscriber Package Version Id: NEW_PACKAGE_VERSION_ID"
```

#### 3.3 Update README.md
```bash
# Update the installation section with new URL and version
# Update package details
# Add new features to the features list if applicable
```

#### 3.4 Update docs/UPDATE_GUIDE.md
```bash
# Update the latest version information
# Add new version to version history
# Update the installation URL
```

### Phase 4: Testing and Validation

#### 4.1 Test Package Installation
```bash
# Create a fresh scratch org for testing
sf org create scratch --definition-file config/project-scratch-def.json --alias test-package --duration-days 7 --target-dev-hub agentforce-devhub

# Install the new package version
sf package install --package "NEW_PACKAGE_VERSION_ID" --installation-key-bypass --target-org test-package --wait 10

# Assign permission set
sf org assign permset --name "User_Access_Summary_App_User" --target-org test-package

# Test the application
sf org open --target-org test-package
```

#### 4.2 Test Package Update
```bash
# Install previous version first
sf package install --package "04tgL0000004sLCQAY" --installation-key-bypass --target-org test-package --wait 10

# Then update to new version
sf package install --package "NEW_PACKAGE_VERSION_ID" --installation-key-bypass --target-org test-package --wait 10

# Verify update worked correctly
```

### Phase 5: Release and Documentation

#### 5.1 Commit and Tag Release
```bash
# Commit all changes
git add .
git commit -m "Release version 1.0.0-3 - [describe changes]"

# Create a git tag for the release
git tag -a v1.0.0-3 -m "Version 1.0.0-3 release"

# Push to repository
git push origin main
git push origin v1.0.0-3
```

#### 5.2 Create Release Notes
Create a file `RELEASE_NOTES.md` or update existing one:
```markdown
# Release Notes

## Version 1.0.0-3 (Date)

### New Features
- Feature 1 description
- Feature 2 description

### Bug Fixes
- Bug fix 1
- Bug fix 2

### Installation
Install URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=NEW_PACKAGE_VERSION_ID
```

## 🛠️ Quick Reference Commands

### Essential Commands for New Version
```bash
# 1. Create package version
sf package version create --package "UserAccessSummaryApp" --installation-key-bypass --wait 15 --target-dev-hub agentforce-devhub --skip-validation

# 2. List versions
sf package version list --target-dev-hub agentforce-devhub --packages "UserAccessSummaryApp"

# 3. Test installation
sf package install --package "PACKAGE_VERSION_ID" --installation-key-bypass --target-org test-org

# 4. Check package details
sf package version report --package "UserAccessSummaryApp@1.0.0-X" --target-dev-hub agentforce-devhub
```

### File Update Checklist
- [ ] `sfdx-project.json` - Package aliases updated
- [ ] `scripts/install-package.sh` - New URL and version
- [ ] `scripts/install-package.bat` - New URL and version  
- [ ] `README.md` - Installation section updated
- [ ] `docs/UPDATE_GUIDE.md` - Latest version info
- [ ] `RELEASE_NOTES.md` - New version documented

## 🚨 Troubleshooting

### Common Issues and Solutions

#### Package Creation Fails
```bash
# Check org connection
sf org display --target-org agentforce-devhub

# Verify 2GP is enabled
sf org open --target-org agentforce-devhub --path "/setup/DevHub.apexp"

# Check for test failures
sf apex run test --target-org agentforce-devhub --result-format human
```

#### Installation Fails
```bash
# Check if previous version exists
sf package version list --target-dev-hub agentforce-devhub

# Verify package ID is correct
sf package version report --package "PACKAGE_VERSION_ID" --target-dev-hub agentforce-devhub

# Check target org permissions
sf org display --target-org target-org
```

## 📊 Version Management Strategy

### Version Numbering
- **X.Y.Z format** where:
  - X = Major version (breaking changes)
  - Y = Minor version (new features)
  - Z = Patch version (bug fixes)

### Example Release Cycle
1. **Development** → Deploy to dev org → Test
2. **Package Creation** → Create version → Validate
3. **Testing** → Install in scratch org → QA testing
4. **Documentation** → Update all files → Release notes
5. **Release** → Commit → Tag → Distribute

## 🎯 Best Practices

1. **Always test** in a scratch org before releasing
2. **Keep release notes** updated with each version
3. **Use git tags** for version tracking
4. **Validate packages** before production release
5. **Maintain backward compatibility** when possible
6. **Test update process** from previous versions
7. **Document breaking changes** clearly

---

**Current Package:** UserAccessSummaryApp  
**Current Dev Hub:** agentforce-devhub  
**Package ID:** 0HogL0000000PPpSAM
