/**
 * @description Helper class for generating Excel exports of user access data
 * @author Salesforce Development Team
 * @date 2025
 */
public with sharing class UserAccessExportHelper {
    
    /**
     * @description Generate Excel content for user access summary
     * @param userId The user ID to export data for
     * @return Base64 encoded Excel file content
     */
    @AuraEnabled
    public static String generateExcelExport(String userId) {
        try {
            // Get all user data
            UserAccessSummaryController.UserInfo userDetails = UserAccessSummaryController.getUserDetails(userId);
            List<UserAccessSummaryController.PermissionSetInfo> permissionSets = UserAccessSummaryController.getUserPermissionSets(userId);
            List<UserAccessSummaryController.ObjectPermissionInfo> objectPermissions = UserAccessSummaryController.getUserObjectPermissions(userId);
            List<UserAccessSummaryController.FieldPermissionInfo> fieldPermissions = UserAccessSummaryController.getUserFieldPermissions(userId);
            List<UserAccessSummaryController.TabInfo> tabs = UserAccessSummaryController.getUserTabs(userId);
            List<UserAccessSummaryController.ConnectedAppInfo> connectedApps = UserAccessSummaryController.getUserConnectedApps(userId);
            
            // Generate Excel content using CSV format for simplicity
            // In a production environment, you might want to use a proper Excel library
            String csvContent = generateCSVContent(userDetails, permissionSets, objectPermissions, fieldPermissions, tabs, connectedApps);
            
            // Convert to Base64 for download
            Blob csvBlob = Blob.valueOf(csvContent);
            return EncodingUtil.base64Encode(csvBlob);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error generating export: ' + e.getMessage());
        }
    }
    
    /**
     * @description Generate comprehensive CSV content for all user access data
     * @param userDetails User basic information
     * @param permissionSets User's permission sets
     * @param objectPermissions User's object permissions
     * @param fieldPermissions User's field permissions
     * @param tabs User's tab permissions
     * @param connectedApps User's connected apps access
     * @return CSV formatted string
     */
    private static String generateCSVContent(
        UserAccessSummaryController.UserInfo userDetails,
        List<UserAccessSummaryController.PermissionSetInfo> permissionSets,
        List<UserAccessSummaryController.ObjectPermissionInfo> objectPermissions,
        List<UserAccessSummaryController.FieldPermissionInfo> fieldPermissions,
        List<UserAccessSummaryController.TabInfo> tabs,
        List<UserAccessSummaryController.ConnectedAppInfo> connectedApps
    ) {
        List<String> csvLines = new List<String>();
        
        // Header with export information
        csvLines.add('User Access Summary Report');
        csvLines.add('Generated on: ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss'));
        csvLines.add('');
        
        // User Summary Section
        csvLines.add('=== USER INFORMATION ===');
        csvLines.add('Field,Value');
        csvLines.add('"Name","' + escapeCsvValue(userDetails.name) + '"');
        csvLines.add('"Username","' + escapeCsvValue(userDetails.username) + '"');
        csvLines.add('"Email","' + escapeCsvValue(userDetails.email) + '"');
        csvLines.add('"Profile","' + escapeCsvValue(userDetails.profileName) + '"');
        csvLines.add('"Status","' + (userDetails.isActive ? 'Active' : 'Inactive') + '"');
        csvLines.add('"Manager","' + escapeCsvValue(userDetails.managerName != null ? userDetails.managerName : 'None') + '"');
        csvLines.add('"Department","' + escapeCsvValue(userDetails.department != null ? userDetails.department : 'None') + '"');
        csvLines.add('"Title","' + escapeCsvValue(userDetails.title != null ? userDetails.title : 'None') + '"');
        csvLines.add('"Last Login","' + (userDetails.lastLoginDate != null ? userDetails.lastLoginDate.format('yyyy-MM-dd HH:mm:ss') : 'Never') + '"');
        csvLines.add('"Created Date","' + userDetails.createdDate.format('yyyy-MM-dd HH:mm:ss') + '"');
        csvLines.add('');
        
        // Permission Sets Section
        csvLines.add('=== PERMISSION SETS ===');
        if (!permissionSets.isEmpty()) {
            csvLines.add('Label,API Name,Description,Type,Source');
            for (UserAccessSummaryController.PermissionSetInfo ps : permissionSets) {
                csvLines.add('"' + escapeCsvValue(ps.label) + '","' + 
                           escapeCsvValue(ps.name) + '","' + 
                           escapeCsvValue(ps.description != null ? ps.description : '') + '","' + 
                           escapeCsvValue(ps.type) + '","' + 
                           escapeCsvValue(ps.source) + '"');
            }
        } else {
            csvLines.add('No permission sets assigned');
        }
        csvLines.add('');
        
        // Object Permissions Section
        csvLines.add('=== OBJECT PERMISSIONS ===');
        if (!objectPermissions.isEmpty()) {
            csvLines.add('Object Label,API Name,Create,Read,Edit,Delete,View All,Modify All');
            for (UserAccessSummaryController.ObjectPermissionInfo op : objectPermissions) {
                csvLines.add('"' + escapeCsvValue(op.objectLabel) + '","' + 
                           escapeCsvValue(op.objectName) + '",' + 
                           (op.canCreate ? 'Yes' : 'No') + ',' +
                           (op.canRead ? 'Yes' : 'No') + ',' +
                           (op.canEdit ? 'Yes' : 'No') + ',' +
                           (op.canDelete ? 'Yes' : 'No') + ',' +
                           (op.canViewAll ? 'Yes' : 'No') + ',' +
                           (op.canModifyAll ? 'Yes' : 'No'));
            }
        } else {
            csvLines.add('No object permissions found');
        }
        csvLines.add('');
        
        // Field Permissions Section
        csvLines.add('=== FIELD PERMISSIONS ===');
        if (!fieldPermissions.isEmpty()) {
            csvLines.add('Object Label,Object API Name,Field Label,Field API Name,Read Access,Edit Access');
            for (UserAccessSummaryController.FieldPermissionInfo fp : fieldPermissions) {
                csvLines.add('"' + escapeCsvValue(fp.objectLabel) + '","' + 
                           escapeCsvValue(fp.objectName) + '","' + 
                           escapeCsvValue(fp.fieldLabel) + '","' + 
                           escapeCsvValue(fp.fieldName) + '",' +
                           (fp.canRead ? 'Yes' : 'No') + ',' +
                           (fp.canEdit ? 'Yes' : 'No'));
            }
        } else {
            csvLines.add('No field permissions found');
        }
        csvLines.add('');
        
        // Tabs Section
        csvLines.add('=== TAB PERMISSIONS ===');
        if (!tabs.isEmpty()) {
            csvLines.add('Tab Label,API Name,Visibility,Available,Type');
            for (UserAccessSummaryController.TabInfo tab : tabs) {
                csvLines.add('"' + escapeCsvValue(tab.tabLabel) + '","' + 
                           escapeCsvValue(tab.tabName) + '","' + 
                           escapeCsvValue(tab.visibility) + '",' +
                           (tab.isAvailable ? 'Yes' : 'No') + ',"' +
                           escapeCsvValue(tab.tabType) + '"');
            }
        } else {
            csvLines.add('No tab information found');
        }
        csvLines.add('');
        
        // Connected Apps Section
        csvLines.add('=== CONNECTED APPS ===');
        if (!connectedApps.isEmpty()) {
            csvLines.add('App Name,Description,Access Type');
            for (UserAccessSummaryController.ConnectedAppInfo app : connectedApps) {
                csvLines.add('"' + escapeCsvValue(app.name) + '","' + 
                           escapeCsvValue(app.description != null ? app.description : '') + '","' + 
                           escapeCsvValue(app.accessType) + '"');
            }
        } else {
            csvLines.add('No connected apps found');
        }
        csvLines.add('');
        
        // Footer
        csvLines.add('=== END OF REPORT ===');
        csvLines.add('This report was generated by the User Access Summary App');
        
        return String.join(csvLines, '\n');
    }
    
    /**
     * @description Escape CSV values to handle commas, quotes, and newlines
     * @param value The value to escape
     * @return Escaped CSV value
     */
    private static String escapeCsvValue(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        
        // Replace double quotes with double double quotes
        value = value.replace('"', '""');
        
        // Remove line breaks for CSV compatibility
        value = value.replace('\n', ' ').replace('\r', ' ');
        
        return value;
    }
    
    /**
     * @description Generate filename for the export
     * @param username The username for the export
     * @return Formatted filename
     */
    @AuraEnabled
    public static String generateExportFilename(String username) {
        String sanitizedUsername = username.replaceAll('[^a-zA-Z0-9]', '_');
        String dateString = DateTime.now().format('yyyy-MM-dd');
        return 'UserAccessSummary_' + sanitizedUsername + '_' + dateString + '.csv';
    }
}
