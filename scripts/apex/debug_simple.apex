// Test simple permission query without full getUserPermissions method
try {
    String currentUserId = UserInfo.getUserId();
    System.debug('Current User ID: ' + currentUserId);
    
    // Test the specific query we're using in getUserPermissions
    List<User> users = [SELECT Id, Name, ProfileId FROM User WHERE Id = :currentUserId LIMIT 1];
    System.debug('Found user: ' + users[0].Name);
    
    Set<Id> permissionSetIds = new Set<Id>{users[0].ProfileId};
    
    String queryFields = 'Id, Label, Name, PermissionsApiEnabled, PermissionsManageUsers, PermissionsModifyAllData';
    List<PermissionSet> permissionSets = Database.query(
        'SELECT ' + queryFields + ' FROM PermissionSet WHERE Id IN :permissionSetIds'
    );
    
    System.debug('Successfully queried ' + permissionSets.size() + ' permission sets');
    if (permissionSets.size() > 0) {
        System.debug('Profile name: ' + permissionSets[0].Label);
        System.debug('API Enabled: ' + permissionSets[0].get('PermissionsApiEnabled'));
    }
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
