// Test PermissionSet schema to get permission fields
try {
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.PermissionSet.fields.getMap();
    List<String> permissionFields = new List<String>();
    
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.startsWith('permissions') && fieldName.toLowerCase() != 'permissions') {
            permissionFields.add(fieldName);
        }
    }
    
    System.debug('Found ' + permissionFields.size() + ' permission fields');
    
    // Show first 10 fields as sample
    for (Integer i = 0; i < Math.min(10, permissionFields.size()); i++) {
        System.debug('Permission field ' + i + ': ' + permissionFields[i]);
    }
    
    // Test a normal query with specific fields
    String currentUserId = UserInfo.getUserId();
    List<User> users = [SELECT Id, ProfileId FROM User WHERE Id = :currentUserId LIMIT 1];
    Id profileId = users[0].ProfileId;
    
    // Build a dynamic query with specific fields instead of Fields(All)
    String queryString = 'SELECT Id, Label';
    for (Integer i = 0; i < Math.min(50, permissionFields.size()); i++) {
        queryString += ', ' + permissionFields[i];
    }
    queryString += ' FROM PermissionSet WHERE Id = :profileId LIMIT 1';
    
    System.debug('Test query: ' + queryString);
    List<PermissionSet> testResults = Database.query(queryString);
    System.debug('Successfully queried PermissionSet with ' + testResults.size() + ' results');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
