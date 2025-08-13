// Test the new Fields(All) implementation
System.debug('=== Testing Fields(All) Implementation ===');

try {
    // Get a test user
    List<User> testUsers = [SELECT Id, Name, ProfileId FROM User WHERE IsActive = true LIMIT 1];
    if (testUsers.isEmpty()) {
        System.debug('ERROR: No active users found');
        return;
    }
    
    User testUser = testUsers[0];
    System.debug('Testing with user: ' + testUser.Name + ' (ID: ' + testUser.Id + ')');
    
    // Test the getUserPermissions method
    List<UserAccessSummaryController.UserPermissionInfo> permissions = 
        UserAccessQueryHelper.getUserPermissions(testUser.Id);
    
    System.debug('SUCCESS: Retrieved ' + permissions.size() + ' permissions');
    
    // Display first few permissions as sample
    Integer displayCount = Math.min(5, permissions.size());
    System.debug('Sample permissions:');
    for (Integer i = 0; i < displayCount; i++) {
        UserAccessSummaryController.UserPermissionInfo perm = permissions[i];
        System.debug('  - ' + perm.name + ' (' + perm.label + ') = ' + perm.isGranted + ' [' + perm.source + ']');
    }
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

System.debug('=== Test Complete ===');
