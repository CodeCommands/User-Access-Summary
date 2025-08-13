// Test profile vs permission set query
try {
    String currentUserId = UserInfo.getUserId();
    List<User> users = [SELECT Id, Name, ProfileId FROM User WHERE Id = :currentUserId LIMIT 1];
    Id profileId = users[0].ProfileId;
    
    System.debug('Profile ID: ' + profileId);
    
    // Try to query the profile directly
    List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id = :profileId];
    System.debug('Profile query result: ' + profiles.size() + ' profiles found');
    if (profiles.size() > 0) {
        System.debug('Profile name: ' + profiles[0].Name);
    }
    
    // Try to query it as a PermissionSet
    List<PermissionSet> permissionSets = [SELECT Id, Label, Name FROM PermissionSet WHERE Id = :profileId];
    System.debug('PermissionSet query result: ' + permissionSets.size() + ' permission sets found');
    
    // Try querying permission sets for the user
    List<PermissionSetAssignment> assignments = [
        SELECT PermissionSet.Id, PermissionSet.Name, PermissionSet.Label
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUserId
    ];
    System.debug('Permission set assignments: ' + assignments.size());
    
    // Try querying profiles as permission sets
    List<PermissionSet> profileAsPermSet = [
        SELECT Id, Label, Name, IsOwnedByProfile 
        FROM PermissionSet 
        WHERE IsOwnedByProfile = true AND ProfileId = :profileId
    ];
    System.debug('Profile as PermissionSet query: ' + profileAsPermSet.size() + ' results');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
