/**
 * @description Query helper class for User Access Summary operations
 * @author Salesforce Development Team
 * @date 2025
 */
public with sharing class UserAccessQueryHelper {
    
    /**
     * @description Get users with filters using static SOQL to prevent injection
     * @param filterCriteria Filter criteria object
     * @return List of User records
     */
    public static List<User> getUsersWithFilters(UserAccessFilterCriteria filterCriteria) {
        if (!UserAccessSecurityUtil.hasUserAccessPermission()) {
            throw new AuraHandledException('Insufficient permissions to access user data');
        }
        
        // Check CRUD permissions for User object
        if (!Schema.sObjectType.User.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access User records.');
        }
        
        // Use different static queries based on filter criteria to avoid SOQL injection
        String searchPattern = String.isNotBlank(filterCriteria.searchTerm) ? 
            '%' + String.escapeSingleQuotes(filterCriteria.searchTerm) + '%' : null;
        List<String> profileIds = (filterCriteria.profileIds != null && !filterCriteria.profileIds.isEmpty()) ? 
            filterCriteria.profileIds : null;
        Integer limitSize = filterCriteria.limitSize != null ? filterCriteria.limitSize : 200;
        
        // Query all users if no filters
        if (searchPattern == null && profileIds == null && filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, 
                    LastLoginDate, CreatedDate, Manager.Name, Department, Title 
                    FROM User ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Query active users only
        if (searchPattern == null && profileIds == null && !filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, 
                    LastLoginDate, CreatedDate, Manager.Name, Department, Title 
                    FROM User WHERE IsActive = TRUE ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Query with search term only (active users)
        if (searchPattern != null && profileIds == null && !filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, 
                    LastLoginDate, CreatedDate, Manager.Name, Department, Title 
                    FROM User WHERE IsActive = TRUE AND 
                    (Name LIKE :searchPattern OR Username LIKE :searchPattern OR Email LIKE :searchPattern)
                    ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Query with profile filter only (active users)
        if (searchPattern == null && profileIds != null && !filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, 
                    LastLoginDate, CreatedDate, Manager.Name, Department, Title 
                    FROM User WHERE IsActive = TRUE AND ProfileId IN :profileIds
                    ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Query with both search and profile filters (active users)
        if (searchPattern != null && profileIds != null && !filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, 
                    LastLoginDate, CreatedDate, Manager.Name, Department, Title 
                    FROM User WHERE IsActive = TRUE AND ProfileId IN :profileIds AND
                    (Name LIKE :searchPattern OR Username LIKE :searchPattern OR Email LIKE :searchPattern)
                    ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Default fallback - active users only
        return [SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, 
                LastLoginDate, CreatedDate, Manager.Name, Department, Title 
                FROM User WHERE IsActive = TRUE ORDER BY Name ASC LIMIT :limitSize];
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
        
        // Check CRUD permissions for User object
        if (!Schema.sObjectType.User.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access User records.');
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
        
        // Check CRUD permissions for PermissionSetAssignment object
        if (!Schema.sObjectType.PermissionSetAssignment.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access PermissionSetAssignment records.');
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
        
        // Check CRUD permissions for ObjectPermissions object
        if (!Schema.sObjectType.ObjectPermissions.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access ObjectPermissions records.');
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
        
        // Check CRUD permissions for FieldPermissions object
        if (!Schema.sObjectType.FieldPermissions.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access FieldPermissions records.');
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
        
        // Check CRUD permissions for ConnectedApplication object
        if (!Schema.sObjectType.ConnectedApplication.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access ConnectedApplication records.');
        }
        
        return [SELECT Id, Name FROM ConnectedApplication ORDER BY Name ASC LIMIT 100];
    }
}
