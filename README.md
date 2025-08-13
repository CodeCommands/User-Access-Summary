# User Access Summary App

A comprehensive Salesforce Lightning application that provides administrators with enhanced capabilities to view, analyze, and export user access permissions for auditing and compliance purposes.

## Features

### 🔍 Enhanced User Search & Filtering
- **Real-time Search**: Search users by name, username, or email with instant results
- **Profile Filtering**: Filter users by specific profiles or view all profiles
- **Active/Inactive Toggle**: Include or exclude inactive users from search results
- **Pagination Support**: Handle large user datasets efficiently

### 👤 Comprehensive User Access Summary
- **User Overview**: Display basic user information, manager details, and status
- **Permission Sets**: View all assigned permission sets, permission set groups, and their sources
- **Object Permissions**: Complete CRUD permissions analysis for all objects
- **Field Permissions**: Detailed field-level read/edit access information
- **Tab Visibility**: Available and visible tabs with permission details
- **Connected Apps**: Access to connected applications and their permissions

### 📊 Advanced Export Capabilities
- **Excel/CSV Export**: Generate comprehensive reports in spreadsheet format
- **Multi-tab Structure**: Organized data export with separate sections for each permission type
- **Formatted Output**: Professional formatting with headers, conditional formatting, and proper structure
- **Audit Trail**: Export timestamps and user information for compliance documentation

### 🔐 Security & Compliance
- **Permission-based Access**: Controlled access through custom permission set
- **Field-level Security**: Respects existing Salesforce security settings
- **Audit-ready Reports**: Generate compliance-ready documentation
- **Secure Data Handling**: All operations respect sharing rules and object-level security

## Installation

### Option 1: Package Installation (Recommended)

**📦 Install via Package URL:**
```
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tgL0000004sLCQAY
```

**📋 Package Details:**
- Package Name: UserAccessSummaryApp
- Version: 1.0.0-2
- Type: Unlocked Package
- No installation key required

**🛠️ Alternative: Install via Salesforce CLI**
```bash
sf package install --package 04tgL0000004sLCQAY --installation-key-bypass --target-org YOUR_ORG_ALIAS
```

**📝 Post-Installation Steps:**
1. Assign the "User_Access_Summary_App_User" permission set to users
2. Navigate to App Launcher → User Access Summary
3. Ensure users have the required permissions to view user data

### Option 2: Source Deployment (For Developers)

### Prerequisites
- Salesforce org with Lightning Experience enabled
- System Administrator access
- SFDX CLI installed (for deployment)

### Deployment Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/CodeCommands/User-Access-Summary.git
   cd User-Access-Summary
   ```

2. **Authenticate with your Salesforce Org**
   ```bash
   sf org login web --alias myorg
   ```

3. **Deploy the Application**
   ```bash
   sf project deploy start --target-org myorg
   ```

4. **Assign Permission Set**
   - Navigate to Setup → Permission Sets
   - Find "User Access Summary App User" permission set
   - Assign to appropriate users/administrators

5. **Access the Application**
   - Open App Launcher (9 dots icon)
   - Search for "User Access Summary"
   - Click to open the application

## Usage Guide

### Getting Started

1. **Open the Application**
   - Launch "User Access Summary" from the App Launcher
   - The main interface displays with user search capabilities

2. **Search and Filter Users**
   - Use the search box to find specific users (minimum 2 characters)
   - Apply profile filters to narrow down results
   - Toggle "Include Inactive Users" as needed
   - Navigate through pages using pagination controls

3. **View User Access Details**
   - Click on any user name to view detailed access information
   - Review information across five comprehensive tabs:
     - **User Permissions**: Permission sets and groups
     - **Object Permissions**: CRUD access by object
     - **Field Permissions**: Read/edit access by field
     - **Tabs**: Tab visibility and availability
     - **Connected Apps**: Application access permissions

4. **Export User Data**
   - Click "Export to Excel" from the user details view
   - Download automatically generated CSV/Excel file
   - File includes all permission data in organized tabs

## Security Model

### Permission Set: "User Access Summary App User"

**Required Permissions:**
- `ViewAllUsers`: View all users in the organization
- `ViewSetup`: Access setup and configuration
- `ManageUsers`: User management capabilities

**Object Access:**
- **User**: Read access with "View All Records"
- **Profile**: Read access with "View All Records"
- **PermissionSet**: Read access with "View All Records"
- **PermissionSetAssignment**: Read access with "View All Records"
- **PermissionSetGroup**: Read access with "View All Records"
- **ConnectedApplication**: Read access with "View All Records"

## Components

### Lightning Web Components
- `userAccessSummaryApp`: Main application component
- `userAccessCard`: User display component

### Apex Classes
- `UserAccessSummaryController`: Core application logic
- `UserAccessExportHelper`: Export functionality
- Test classes with 90%+ coverage

### Metadata
- Custom Application: User Access Summary
- Permission Set: User Access Summary App User
- FlexiPage: Application home page
- Custom Tab: Navigation tab

## Troubleshooting

### Common Issues

1. **"Insufficient Privileges" Error**
   - Ensure the current user has the "User Access Summary App User" permission set assigned

2. **No Users Displayed**
   - Check if "Include Inactive Users" toggle is set correctly
   - Verify search filters and profile selections

3. **Export Not Working**
   - Ensure browser allows file downloads
   - Check browser console for JavaScript errors

## Development

### Local Development
```bash
# Install dependencies
npm install

# Run tests
npm run test:unit

# Deploy to scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias userAccessApp
sf project deploy start --target-org userAccessApp
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

## License

This project is licensed under the MIT License.

---

**Developed for enhanced Salesforce user access management and compliance reporting.**
