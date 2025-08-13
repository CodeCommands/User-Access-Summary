// Debug getUserPermissions method
try {
    String currentUserId = UserInfo.getUserId();
    System.debug('Current User ID: ' + currentUserId);
    
    List<UserAccessSummaryController.UserPermissionInfo> permissions = 
        UserAccessSummaryController.getUserPermissions(currentUserId);
    
    System.debug('Successfully retrieved ' + permissions.size() + ' permissions');
    if (permissions.size() > 0) {
        System.debug('First permission: ' + permissions[0].name + ' = ' + permissions[0].isGranted);
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
