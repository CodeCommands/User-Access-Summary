// Test static Fields(All) query
try {
    String currentUserId = UserInfo.getUserId();
    List<User> users = [SELECT Id, ProfileId FROM User WHERE Id = :currentUserId LIMIT 1];
    Id profileId = users[0].ProfileId;
    System.debug('Profile ID: ' + profileId);
    
    // Try static Fields(All) query - this should work
    List<PermissionSet> staticResult = [SELECT Fields(All) FROM PermissionSet WHERE IsOwnedByProfile = true LIMIT 1];
    System.debug('Static Fields(All) query successful, got ' + staticResult.size() + ' results');
    
    if (staticResult.size() > 0) {
        System.debug('Sample permission set label: ' + staticResult[0].Label);
    }
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
