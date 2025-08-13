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
            throw new System.CalloutException('Insufficient permissions to access user data');
        }
        
        // Check CRUD permissions for User object
        if (!Schema.sObjectType.User.isAccessible()) {
            throw new System.CalloutException('Insufficient permissions to access User records.');
        }
        
        // Use different static queries based on filter criteria to avoid SOQL injection
        String searchPattern = String.isNotBlank(filterCriteria.searchTerm) ? 
            '%' + String.escapeSingleQuotes(filterCriteria.searchTerm) + '%' : null;
        List<String> profileIds = (filterCriteria.profileIds != null && !filterCriteria.profileIds.isEmpty()) ? 
            filterCriteria.profileIds : null;
        Integer limitSize = filterCriteria.limitSize != null ? filterCriteria.limitSize : 200;
        
        // Query all users if no filters
        if (searchPattern == null && profileIds == null && filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, IsActive, 
                    LastLoginDate, Manager.Name, Department, Title 
                    FROM User ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Query active users only
        if (searchPattern == null && profileIds == null && !filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, IsActive, 
                    LastLoginDate, Manager.Name, Department, Title 
                    FROM User WHERE IsActive = TRUE ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Query with search term only (active users)
        if (searchPattern != null && profileIds == null && !filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, IsActive, 
                    LastLoginDate, Manager.Name, Department, Title 
                    FROM User WHERE IsActive = TRUE AND 
                    (Name LIKE :searchPattern OR Username LIKE :searchPattern OR Email LIKE :searchPattern)
                    ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Query with profile filter only (active users)
        if (searchPattern == null && profileIds != null && !filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, IsActive, 
                    LastLoginDate, Manager.Name, Department, Title 
                    FROM User WHERE IsActive = TRUE AND ProfileId IN :profileIds
                    ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Query with both search and profile filters (active users)
        if (searchPattern != null && profileIds != null && !filterCriteria.includeInactive) {
            return [SELECT Id, Name, Username, Email, Profile.Name, IsActive, 
                    LastLoginDate, Manager.Name, Department, Title 
                    FROM User WHERE IsActive = TRUE AND ProfileId IN :profileIds AND
                    (Name LIKE :searchPattern OR Username LIKE :searchPattern OR Email LIKE :searchPattern)
                    ORDER BY Name ASC LIMIT :limitSize];
        }
        
        // Default fallback - active users only
        return [SELECT Id, Name, Username, Email, Profile.Name, IsActive, 
                LastLoginDate, Manager.Name, Department, Title 
                FROM User WHERE IsActive = TRUE ORDER BY Name ASC LIMIT :limitSize];
    }
    
    /**
     * @description Get user details by ID
     * @param userId User ID
     * @return User record
     */
    public static User getUserById(String userId) {
        if (!UserAccessSecurityUtil.hasUserAccessPermission()) {
            throw new System.CalloutException('Insufficient permissions to access user data');
        }
        
        // Check CRUD permissions for User object
        if (!Schema.sObjectType.User.isAccessible()) {
            throw new System.CalloutException('Insufficient permissions to access User records.');
        }
        
        return [SELECT Id, Name, Username, Email, Profile.Name, IsActive, 
                LastLoginDate, Manager.Name, Department, Title, ManagerId
                FROM User WHERE Id = :userId LIMIT 1];
    }
    
    /**
     * @description Get permission set assignments for user
     * @param userId User ID
     * @return List of PermissionSetAssignment records
     */
    public static List<PermissionSetAssignment> getPermissionSetAssignments(String userId) {
        if (!UserAccessSecurityUtil.hasPermissionSetAccessPermission()) {
            throw new System.CalloutException('Insufficient permissions to access permission set data');
        }
        
        // Check CRUD permissions for PermissionSetAssignment object
        if (!Schema.sObjectType.PermissionSetAssignment.isAccessible()) {
            throw new System.CalloutException('Insufficient permissions to access PermissionSetAssignment records.');
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
            throw new System.CalloutException('Insufficient permissions to access object permission data');
        }
        
        // Check CRUD permissions for ObjectPermissions object
        if (!Schema.sObjectType.ObjectPermissions.isAccessible()) {
            throw new System.CalloutException('Insufficient permissions to access ObjectPermissions records.');
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
            throw new System.CalloutException('Insufficient permissions to access field permission data');
        }
        
        // Check CRUD permissions for FieldPermissions object
        if (!Schema.sObjectType.FieldPermissions.isAccessible()) {
            throw new System.CalloutException('Insufficient permissions to access FieldPermissions records.');
        }
        
        return [SELECT Field, PermissionsRead, PermissionsEdit, Parent.Label
                FROM FieldPermissions 
                WHERE ParentId IN :permissionSetIds
                ORDER BY Field ASC];
    }

    /**
     * @description Get field permissions for permission sets in batches
     * @param permissionSetIds List of permission set IDs (batch)
     * @return List of FieldPermissions records
     */
    public static List<FieldPermissions> getFieldPermissionsBatch(List<Id> permissionSetIds) {
        if (!UserAccessSecurityUtil.hasFieldPermissionAccessPermission()) {
            throw new System.CalloutException('Insufficient permissions to access field permission data');
        }
        
        // Check CRUD permissions for FieldPermissions object
        if (!Schema.sObjectType.FieldPermissions.isAccessible()) {
            throw new System.CalloutException('Insufficient permissions to access FieldPermissions records.');
        }
        
        return [SELECT Field, PermissionsRead, PermissionsEdit, Parent.Label
                FROM FieldPermissions 
                WHERE ParentId IN :permissionSetIds
                ORDER BY Field ASC
                LIMIT 500]; // Limit per batch to prevent memory issues
    }

    /**
     * @description Get limited field permissions for quick display
     * @param permissionSetIds Set of permission set IDs
     * @param recordLimit Maximum number of records to return
     * @return List of FieldPermissions records
     */
    public static List<FieldPermissions> getFieldPermissionsLimited(Set<Id> permissionSetIds, Integer recordLimit) {
        if (!UserAccessSecurityUtil.hasFieldPermissionAccessPermission()) {
            throw new System.CalloutException('Insufficient permissions to access field permission data');
        }
        
        // Check CRUD permissions for FieldPermissions object
        if (!Schema.sObjectType.FieldPermissions.isAccessible()) {
            throw new System.CalloutException('Insufficient permissions to access FieldPermissions records.');
        }
        
        return [SELECT Field, PermissionsRead, PermissionsEdit, Parent.Label
                FROM FieldPermissions 
                WHERE ParentId IN :permissionSetIds
                ORDER BY Field ASC
                LIMIT :recordLimit];
    }
    
    /**
     * @description Get connected applications
     * @return List of ConnectedApplication records
     */
    public static List<ConnectedApplication> getConnectedApplications() {
        if (!UserAccessSecurityUtil.hasConnectedAppAccessPermission()) {
            throw new System.CalloutException('Insufficient permissions to access connected app data');
        }
        
        // Check CRUD permissions for ConnectedApplication object
        if (!Schema.sObjectType.ConnectedApplication.isAccessible()) {
            throw new System.CalloutException('Insufficient permissions to access ConnectedApplication records.');
        }
        
        return [SELECT Id, Name FROM ConnectedApplication ORDER BY Name ASC LIMIT 100];
    }
    
    /**
     * @description Get comprehensive user permissions using dynamic Fields(All) approach
     * @param userId The ID of the user to get permissions for
     * @return List of UserPermissionInfo objects with comprehensive permission details
     */
    public static List<UserAccessSummaryController.UserPermissionInfo> getUserPermissions(String userId) {
        List<UserAccessSummaryController.UserPermissionInfo> result = new List<UserAccessSummaryController.UserPermissionInfo>();
        
        try {
            System.debug('Starting getUserPermissions for user: ' + userId);
            
            // Validate user exists and get user details
            List<User> users = [SELECT Id, Name, ProfileId FROM User WHERE Id = :userId LIMIT 1];
            if (users.isEmpty()) {
                throw new System.CalloutException('User not found: ' + userId);
            }
            User targetUser = users[0];
            System.debug('Found user: ' + targetUser.Name + ', Profile: ' + targetUser.ProfileId);
            
            // Use a Set to store unique permissions (no duplicates)
            Set<String> grantedPermissions = new Set<String>();
            Map<String, String> permissionSources = new Map<String, String>();
            
            // 1. Get Profile PermissionSet and process with FIELDS(STANDARD)
            List<PermissionSet> profilePermissionSets = [
                SELECT Id, Label FROM PermissionSet 
                WHERE IsOwnedByProfile = true AND ProfileId = :targetUser.ProfileId
                LIMIT 1
            ];
            
            if (!profilePermissionSets.isEmpty()) {
                PermissionSet profilePS = profilePermissionSets[0];
                
                // Query profile with FIELDS(STANDARD) using static SOQL
                List<PermissionSet> profileWithAllFields = [
                    SELECT FIELDS(STANDARD) FROM PermissionSet 
                    WHERE Id = :profilePS.Id
                    LIMIT 1
                ];
                
                if (!profileWithAllFields.isEmpty()) {
                    processPermissionSetFields(profileWithAllFields[0], grantedPermissions, permissionSources);
                    System.debug('Processed profile: ' + profilePS.Label);
                }
            }
            
            // 2. Get Permission Set assignments and process each one individually with FIELDS(STANDARD)
            List<PermissionSetAssignment> assignments = getPermissionSetAssignments(userId);
            System.debug('Found ' + assignments.size() + ' permission set assignments');
            
            for (PermissionSetAssignment psa : assignments) {
                try {
                    // Query individual permission set with FIELDS(STANDARD) using static SOQL
                    List<PermissionSet> singlePS = [
                        SELECT FIELDS(STANDARD) FROM PermissionSet 
                        WHERE Id = :psa.PermissionSet.Id
                        LIMIT 1
                    ];
                    
                    if (!singlePS.isEmpty()) {
                        processPermissionSetFields(singlePS[0], grantedPermissions, permissionSources);
                        System.debug('Processed permission set: ' + singlePS[0].Label);
                    }
                } catch (Exception psEx) {
                    System.debug('Could not process permission set ' + psa.PermissionSet.Id + ': ' + psEx.getMessage());
                }
            }
            
            // 3. Convert Set of granted permissions to UserPermissionInfo objects
            for (String permissionName : grantedPermissions) {
                String source = permissionSources.get(permissionName);
                String label = generateHumanReadableLabel(permissionName);
                
                UserAccessSummaryController.UserPermissionInfo permInfo = new UserAccessSummaryController.UserPermissionInfo();
                permInfo.name = permissionName;
                permInfo.label = label;
                permInfo.apiName = 'Permissions' + permissionName;
                permInfo.isGranted = true; // Only granted permissions are in our set
                permInfo.source = source;
                permInfo.description = label; // Use label as description for now
                
                result.add(permInfo);
            }
            
            // Sort results by permission name for consistent display
            result.sort(new UserPermissionInfoComparator());
            
            System.debug('Found ' + grantedPermissions.size() + ' granted permissions for user');
            return result;
            
        } catch (Exception e) {
            System.debug('Error in getUserPermissions: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw e; // Re-throw the original exception, controller will handle AuraHandledException conversion
        }
    }
    
    /**
     * @description Helper method to aggregate permissions from multiple permission sets
     */
    private static void aggregatePermission(Map<String, Boolean> aggregatedPermissions, Map<String, String> permissionSources, 
                                           String permissionName, Boolean hasPermission, String source) {
        if (hasPermission == true) {
            aggregatedPermissions.put(permissionName, true);
            if (!permissionSources.containsKey(permissionName)) {
                permissionSources.put(permissionName, source);
            } else {
                permissionSources.put(permissionName, permissionSources.get(permissionName) + ', ' + source);
            }
        } else if (!aggregatedPermissions.containsKey(permissionName)) {
            aggregatedPermissions.put(permissionName, false);
        }
    }
    
    /**
     * @description Generate human-readable label from camelCase permission name
     */
    private static String generateHumanReadableLabel(String permissionName) {
        if (String.isBlank(permissionName)) {
            return permissionName;
        }
        
        // Convert camelCase to space-separated words
        String result = permissionName.replaceAll('([a-z])([A-Z])', '$1 $2');
        
        // Handle specific abbreviations and patterns
        result = result.replaceAll('API', 'API');
        result = result.replaceAll('SMS', 'SMS');
        result = result.replaceAll('IP', 'IP');
        result = result.replaceAll('URL', 'URL');
        result = result.replaceAll('HTML', 'HTML');
        result = result.replaceAll('XML', 'XML');
        result = result.replaceAll('JSON', 'JSON');
        result = result.replaceAll('OAuth', 'OAuth');
        result = result.replaceAll('SAML', 'SAML');
        result = result.replaceAll('CMS', 'CMS');
        result = result.replaceAll('CDP', 'CDP');
        result = result.replaceAll('FSC', 'FSC');
        
        // Capitalize first letter and return
        if (result.length() > 0) {
            result = result.substring(0, 1).toUpperCase() + result.substring(1);
        }
        
        return result;
    }
    
    /**
     * @description Helper method to process all permission fields from a PermissionSet using FIELDS(STANDARD)
     */
    private static void processPermissionSetFields(PermissionSet ps, Set<String> grantedPermissions, Map<String, String> permissionSources) {
        // Get all field names from PermissionSet to identify permission fields
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.PermissionSet.fields.getMap();
        
        for (String fieldName : fieldMap.keySet()) {
            if (fieldName.startsWith('permissions') && fieldName.toLowerCase() != 'permissions') {
                try {
                    Object fieldValue = ps.get(fieldName);
                    if (fieldValue == true) {
                        // Remove 'permissions' prefix for cleaner permission name
                        String permissionName = fieldName.substring(11);
                        grantedPermissions.add(permissionName);
                        if (!permissionSources.containsKey(permissionName)) {
                            permissionSources.put(permissionName, ps.Label);
                        }
                    }
                } catch (Exception fieldEx) {
                    // Skip fields that can't be processed
                    System.debug('Could not process field ' + fieldName + ': ' + fieldEx.getMessage());
                }
            }
        }
    }
    
    /**
     * @description Comparator for sorting UserPermissionInfo objects by name
     */
    public class UserPermissionInfoComparator implements Comparator<UserAccessSummaryController.UserPermissionInfo> {
        public Integer compare(UserAccessSummaryController.UserPermissionInfo a, UserAccessSummaryController.UserPermissionInfo b) {
            if (a.name == null && b.name == null) return 0;
            if (a.name == null) return -1;
            if (b.name == null) return 1;
            return a.name.compareTo(b.name);
        }
    }
}
