# Scripts Directory

This directory contains various scripts for managing the User Access Summary App.

## 📦 For End Users (Package Installation)

### `install-package.sh` / `install-package.bat`
**USE THESE for installing the app in your org**
- Displays package installation URL and instructions
- No technical knowledge required
- Recommended for all users

**Usage:**
```bash
# Linux/Mac
./scripts/install-package.sh

# Windows
scripts\install-package.bat
```

## 🛠️ For Developers Only

### `deploy.sh` / `deploy.bat` 
**⚠️ DEVELOPMENT ONLY - Deploys source code directly**
- For developers who want to modify the source code
- For contributing to the project
- For development and testing
- **NOT** for regular users

**Usage:**
```bash
# Linux/Mac
./scripts/deploy.sh your-org-alias

# Windows
scripts\deploy.bat your-org-alias
```

### `create-new-version.sh` / `create-new-version.bat`
**⚠️ MAINTAINER ONLY - Creates new package versions**
- For creating new versions of the package
- Requires Dev Hub access
- Only for project maintainers

**Usage:**
```bash
# Linux/Mac
./scripts/create-new-version.sh

# Windows
scripts\create-new-version.bat
```

## 🎯 Which Script Should I Use?

### I want to **install** the app in my org:
→ Use `install-package.sh/.bat`

### I want to **develop/modify** the source code:
→ Use `deploy.sh/.bat`

### I want to **create a new version** of the package:
→ Use `create-new-version.sh/.bat`

---

**Most users should use the package installation scripts only!**
