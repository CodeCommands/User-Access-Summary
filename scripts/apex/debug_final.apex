// Test the explicit permission fields approach
try {
    String currentUserId = UserInfo.getUserId();
    System.debug('Testing getUserPermissions with explicit fields...');
    
    List<UserAccessSummaryController.UserPermissionInfo> permissions = 
        UserAccessSummaryController.getUserPermissions(currentUserId);
    
    System.debug('SUCCESS: Retrieved ' + permissions.size() + ' permissions');
    
    if (permissions.size() > 0) {
        System.debug('First permission: ' + permissions[0].name + ' = ' + permissions[0].isGranted + ' (Source: ' + permissions[0].source + ')');
        
        // Show first few permissions
        for (Integer i = 0; i < Math.min(5, permissions.size()); i++) {
            System.debug('Permission ' + i + ': ' + permissions[i].name + ' = ' + permissions[i].isGranted);
        }
    }
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
