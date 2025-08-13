# User Access Summary App - AI Development Guide

## Architecture Overview

This is a Salesforce Lightning application for auditing user permissions and access. The system uses a **controller pattern with helper classes** and **comprehensive security validation** throughout.

### Core Components Architecture
- **Main Controller**: `UserAccessSummaryController` - Entry point for all Lightning operations
- **Security Layer**: `UserAccessSecurityUtil` - Validates FLS, CRUD, and object permissions before any data access
- **Query Layer**: `UserAccessQueryHelper` - Handles all SOQL operations with security checks
- **Filter Pattern**: `UserAccessFilterCriteria` - Type-safe filter parameter passing
- **Export Engine**: `UserAccessExportHelper` - Generates CSV/Excel exports with comprehensive data

### Lightning Web Components
- **Main App**: `userAccessSummaryApp` - Handles search, pagination, user selection, and multi-tab permission display
- **User Card**: `userAccessCard` - Displays individual user information with action buttons
- **Data Pattern**: Uses `@wire` for profiles, imperative calls for user-specific data with loading states

## Development Patterns

### Security-First Approach
Every data operation follows this pattern:
```apex
// 1. Check permissions first
if (!UserAccessSecurityUtil.hasUserAccessPermission()) {
    throw new AuraHandledException('Insufficient permissions');
}

// 2. Validate object accessibility
if (!Schema.sObjectType.User.isAccessible()) {
    throw new AuraHandledException('Insufficient permissions to access User records.');
}

// 3. Execute query with escaped parameters
// Static SOQL patterns to prevent injection
```

### Performance Optimization Strategy
- **Field Permissions**: Uses cursor-based processing with CPU monitoring to handle large datasets
- **Pagination**: 50 records per page with offset-based loading
- **Export**: Comprehensive field permissions loaded separately for exports vs. UI display
- **CPU Limits**: Implements fallback patterns when system limits are exceeded

### Error Handling Pattern
```javascript
// LWC pattern
try {
    const data = await apexMethod({ param });
    // Success handling
} catch (error) {
    this.showToast('Error', error.body?.message || error.message, 'error');
} finally {
    this.isLoading = false;
}
```

## Testing Patterns

### Test Data Setup
Uses `@TestSetup` with realistic user creation including:
- Active/inactive users with different profiles
- Permission set assignments
- Manager relationships
- Department/title data

### Security Testing
All test classes include negative tests for insufficient permissions and validate proper exception handling.

## Build & Deployment

### Standard Commands
```bash
# Run tests with coverage
npm run test:unit:coverage

# Deploy to org
sf project deploy start --target-org your-org-alias

# Assign permission set
sf org assign permset --name "User_Access_Summary_App_User"
```

### Deployment Scripts
Use `scripts/deploy.sh` (Linux/Mac) or `scripts/deploy.bat` (Windows) for automated deployment with:
- Org validation
- Pre-deployment testing
- Permission set assignment
- Post-deployment verification

## Critical Implementation Details

### Permission Set Requirements
The app requires specific Salesforce permissions:
- `ViewAllUsers` - Access all user records
- `ViewSetup` + `ViewRoles` - Access permission metadata
- Read access to: User, Profile, PermissionSet, PermissionSetAssignment, ObjectPermissions, FieldPermissions

### Lightning Web Security Considerations
- SheetJS static resource used for Excel exports may be slow under LWS
- Fallback CSV export pattern implemented for compatibility
- Multiple file download pattern for comprehensive exports

### Performance Bottlenecks
- **Field Permissions**: Most CPU-intensive operation, limited to prevent timeouts
- **Large Permission Sets**: Uses batching and fallback patterns
- **Export Generation**: Loads comprehensive data separately from UI display

### Data Access Patterns
- **Search**: Real-time with 2+ character minimum, debounced 500ms
- **Filtering**: Profile-based with active/inactive toggle
- **Detail Loading**: Sequential loading pattern (user → permissions → objects → fields)
- **Field Permissions by Object**: On-demand loading when object selected

## Common Customization Points

### Extending Search Functionality
Modify `getUsersWithFilters()` in `UserAccessQueryHelper` - uses static SOQL patterns to prevent injection.

### Adding New Permission Types
1. Add security check to `UserAccessSecurityUtil`
2. Add query method to `UserAccessQueryHelper`
3. Add wrapper class to main controller
4. Update LWC tab system

### Customizing Export Format
Modify `UserAccessExportHelper` - follows multi-sheet pattern with headers, data sections, and proper CSV escaping.

### Performance Tuning
- Adjust `pageSize` in LWC (currently 50)
- Modify field permission limits in controller (currently 200 for display, unlimited for export)
- Update CPU monitoring thresholds in cursor processing

## Integration Points

### External Systems
- Uses Salesforce standard objects only
- No external API dependencies
- Static resource (SheetJS) for client-side Excel generation

### Salesforce Platform Integration
- Follows Lightning Design System patterns
- Uses platform events for toasts
- Respects org-wide sharing settings and FLS
- Compatible with both Classic and Lightning Experience

When modifying this application, always maintain the security-first approach and test permission boundary conditions thoroughly.
