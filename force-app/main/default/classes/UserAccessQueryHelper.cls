/**
 * @description Query helper class for User Access Summary operations
 * @author Salesforce Development Team
 * @date 2025
 */
public with sharing class UserAccessQueryHelper {
    
    /**
     * @description Build dynamic user query with filters
     * @param searchTerm Search term for filtering
     * @param profileIds Profile IDs to filter by
     * @param includeInactive Include inactive users
     * @param limitSize Limit number of results
     * @param offset Offset for pagination
     * @return List of User records
     */
    public static List<User> getUsersWithFilters(String searchTerm, List<String> profileIds, 
                                                Boolean includeInactive, Integer limitSize, Integer offset) {
        if (!UserAccessSecurityUtil.hasUserAccessPermission()) {
            throw new AuraHandledException('Insufficient permissions to access user data');
        }
        
        String query = 'SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, ' +
                      'LastLoginDate, CreatedDate, Manager.Name, Department, Title FROM User';
        
        List<String> conditions = buildUserQueryConditions(searchTerm, profileIds, includeInactive);
        
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        
        query += ' ORDER BY Name ASC';
        
        if (limitSize != null && limitSize > 0) {
            query += ' LIMIT ' + limitSize;
        }
        if (offset != null && offset > 0) {
            query += ' OFFSET ' + offset;
        }
        
        return Database.query(query);
    }
    
    /**
     * @description Build query conditions for user filtering
     * @param searchTerm Search term
     * @param profileIds Profile IDs
     * @param includeInactive Include inactive users
     * @return List of query conditions
     */
    private static List<String> buildUserQueryConditions(String searchTerm, List<String> profileIds, Boolean includeInactive) {
        List<String> conditions = new List<String>();
        
        if (String.isNotBlank(searchTerm)) {
            String searchPattern = '%' + String.escapeSingleQuotes(searchTerm) + '%';
            conditions.add('(Name LIKE :searchPattern OR Username LIKE :searchPattern OR Email LIKE :searchPattern)');
        }
        
        if (profileIds != null && !profileIds.isEmpty()) {
            conditions.add('ProfileId IN :profileIds');
        }
        
        if (!includeInactive) {
            conditions.add('IsActive = TRUE');
        }
        
        return conditions;
    }
    
    /**
     * @description Get user details by ID
     * @param userId User ID
     * @return User record
     */
    public static User getUserById(String userId) {
        if (!UserAccessSecurityUtil.hasUserAccessPermission()) {
            throw new AuraHandledException('Insufficient permissions to access user data');
        }
        
        return [SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, 
                LastLoginDate, CreatedDate, Manager.Name, Department, Title, ManagerId
                FROM User WHERE Id = :userId LIMIT 1];
    }
    
    /**
     * @description Get permission set assignments for user
     * @param userId User ID
     * @return List of PermissionSetAssignment records
     */
    public static List<PermissionSetAssignment> getPermissionSetAssignments(String userId) {
        if (!UserAccessSecurityUtil.hasPermissionSetAccessPermission()) {
            throw new AuraHandledException('Insufficient permissions to access permission set data');
        }
        
        return [SELECT PermissionSet.Id, PermissionSet.Name, PermissionSet.Label, 
                PermissionSet.Description, PermissionSet.Type, PermissionSet.IsOwnedByProfile
                FROM PermissionSetAssignment 
                WHERE AssigneeId = :userId
                ORDER BY PermissionSet.Label ASC];
    }
    
    /**
     * @description Get object permissions for permission sets
     * @param permissionSetIds Set of permission set IDs
     * @return List of ObjectPermissions records
     */
    public static List<ObjectPermissions> getObjectPermissions(Set<Id> permissionSetIds) {
        if (!UserAccessSecurityUtil.hasObjectPermissionAccessPermission()) {
            throw new AuraHandledException('Insufficient permissions to access object permission data');
        }
        
        return [SELECT SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, 
                PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords,
                Parent.Label
                FROM ObjectPermissions 
                WHERE ParentId IN :permissionSetIds
                ORDER BY SobjectType ASC];
    }
    
    /**
     * @description Get field permissions for permission sets
     * @param permissionSetIds Set of permission set IDs
     * @return List of FieldPermissions records
     */
    public static List<FieldPermissions> getFieldPermissions(Set<Id> permissionSetIds) {
        if (!UserAccessSecurityUtil.hasFieldPermissionAccessPermission()) {
            throw new AuraHandledException('Insufficient permissions to access field permission data');
        }
        
        return [SELECT Field, PermissionsRead, PermissionsEdit, Parent.Label
                FROM FieldPermissions 
                WHERE ParentId IN :permissionSetIds
                ORDER BY Field ASC];
    }
    
    /**
     * @description Get connected applications
     * @return List of ConnectedApplication records
     */
    public static List<ConnectedApplication> getConnectedApplications() {
        if (!UserAccessSecurityUtil.hasConnectedAppAccessPermission()) {
            throw new AuraHandledException('Insufficient permissions to access connected app data');
        }
        
        return [SELECT Id, Name FROM ConnectedApplication ORDER BY Name ASC LIMIT 100];
    }
}
