// Test the fixed getUserPermissions approach
try {
    String currentUserId = UserInfo.getUserId();
    List<User> users = [SELECT Id, ProfileId FROM User WHERE Id = :currentUserId LIMIT 1];
    Set<Id> permissionSetIds = new Set<Id>{users[0].ProfileId};
    
    System.debug('Testing individual Fields(All) queries for ' + permissionSetIds.size() + ' permission sets');
    
    List<PermissionSet> permissionSets = new List<PermissionSet>();
    
    for (Id permSetId : permissionSetIds) {
        try {
            List<PermissionSet> singlePermSet = Database.query(
                'SELECT Fields(All) FROM PermissionSet WHERE Id = :permSetId LIMIT 1'
            );
            if (!singlePermSet.isEmpty()) {
                permissionSets.addAll(singlePermSet);
                System.debug('Successfully queried permission set: ' + singlePermSet[0].Label);
            }
        } catch (Exception queryEx) {
            System.debug('Could not query permission set ' + permSetId + ': ' + queryEx.getMessage());
        }
    }
    
    System.debug('Total permission sets queried: ' + permissionSets.size());
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
