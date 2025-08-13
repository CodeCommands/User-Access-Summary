// Test basic permission set query
try {
    String currentUserId = UserInfo.getUserId();
    System.debug('Current User ID: ' + currentUserId);
    
    // Test basic User query
    List<User> users = [SELECT Id, Name, ProfileId FROM User WHERE Id = :currentUserId LIMIT 1];
    System.debug('Found user: ' + users[0].Name);
    
    // Test permission set assignment query
    List<PermissionSetAssignment> assignments = [
        SELECT PermissionSet.Id, PermissionSet.Name, PermissionSet.Label
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUserId
    ];
    System.debug('Found ' + assignments.size() + ' permission set assignments');
    
    // Test basic permission set query with Fields(All)
    Set<Id> permissionSetIds = new Set<Id>{users[0].ProfileId};
    for (PermissionSetAssignment psa : assignments) {
        permissionSetIds.add(psa.PermissionSet.Id);
    }
    
    System.debug('Testing Fields(All) query for ' + permissionSetIds.size() + ' permission sets');
    List<PermissionSet> permissionSets = Database.query(
        'SELECT Fields(All) FROM PermissionSet WHERE Id IN :permissionSetIds LIMIT 3'
    );
    
    System.debug('Successfully queried ' + permissionSets.size() + ' permission sets');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
