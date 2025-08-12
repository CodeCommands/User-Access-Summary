/**
 * @description Controller class for User Access Summary Lightning Web Component
 * @author Salesforce Development Team
 * @date 2025
 */
public with sharing class UserAccessSummaryController {
    
    /**
     * @description Wrapper class for user information
     */
    public class UserInfo {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String username;
        @AuraEnabled public String email;
        @AuraEnabled public String profileName;
        @AuraEnabled public String profileId;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public DateTime lastLoginDate;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String managerId;
        @AuraEnabled public String managerName;
        @AuraEnabled public String department;
        @AuraEnabled public String title;
    }
    
    /**
     * @description Wrapper class for permission set information
     */
    public class PermissionSetInfo {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean isGroup;
        @AuraEnabled public String source;
    }
    
    /**
     * @description Wrapper class for object permissions
     */
    public class ObjectPermissionInfo {
        @AuraEnabled public String objectName;
        @AuraEnabled public String objectLabel;
        @AuraEnabled public Boolean canCreate;
        @AuraEnabled public Boolean canRead;
        @AuraEnabled public Boolean canEdit;
        @AuraEnabled public Boolean canDelete;
        @AuraEnabled public Boolean canViewAll;
        @AuraEnabled public Boolean canModifyAll;
        @AuraEnabled public String source;
    }
    
    /**
     * @description Wrapper class for field permissions
     */
    public class FieldPermissionInfo {
        @AuraEnabled public String objectName;
        @AuraEnabled public String objectLabel;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public Boolean canRead;
        @AuraEnabled public Boolean canEdit;
        @AuraEnabled public String source;
    }
    
    /**
     * @description Wrapper class for tab information
     */
    public class TabInfo {
        @AuraEnabled public String tabName;
        @AuraEnabled public String tabLabel;
        @AuraEnabled public String visibility;
        @AuraEnabled public Boolean isAvailable;
        @AuraEnabled public String tabType;
    }
    
    /**
     * @description Wrapper class for connected app information
     */
    public class ConnectedAppInfo {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public List<String> permissions;
        @AuraEnabled public String accessType;
    }
    
    /**
     * @description Get all users with basic information for the user selection interface
     * @param searchTerm Search term to filter users
     * @param profileIds List of profile IDs to filter by
     * @param includeInactive Whether to include inactive users
     * @param limitSize Number of records to return
     * @param offset Offset for pagination
     * @return List of UserInfo objects
     */
    @AuraEnabled(cacheable=true)
    public static List<UserInfo> getUsers(String searchTerm, List<String> profileIds, Boolean includeInactive, Integer limitSize, Integer offset) {
        try {
            String query = 'SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, LastLoginDate, CreatedDate, Manager.Name, Department, Title FROM User';
            List<String> conditions = new List<String>();
            
            // Add search condition
            if (String.isNotBlank(searchTerm)) {
                String searchPattern = '%' + String.escapeSingleQuotes(searchTerm) + '%';
                conditions.add('(Name LIKE :searchPattern OR Username LIKE :searchPattern OR Email LIKE :searchPattern)');
            }
            
            // Add profile filter
            if (profileIds != null && !profileIds.isEmpty()) {
                conditions.add('ProfileId IN :profileIds');
            }
            
            // Add active status filter
            if (!includeInactive) {
                conditions.add('IsActive = TRUE');
            }
            
            // Build WHERE clause
            if (!conditions.isEmpty()) {
                query += ' WHERE ' + String.join(conditions, ' AND ');
            }
            
            // Add ORDER BY and LIMIT
            query += ' ORDER BY Name ASC';
            if (limitSize != null && limitSize > 0) {
                query += ' LIMIT ' + limitSize;
            }
            if (offset != null && offset > 0) {
                query += ' OFFSET ' + offset;
            }
            
            List<User> users = Database.query(query);
            List<UserInfo> result = new List<UserInfo>();
            
            for (User u : users) {
                UserInfo userInfo = new UserInfo();
                userInfo.id = u.Id;
                userInfo.name = u.Name;
                userInfo.username = u.Username;
                userInfo.email = u.Email;
                userInfo.profileName = u.Profile.Name;
                userInfo.profileId = u.Profile.Id;
                userInfo.isActive = u.IsActive;
                userInfo.lastLoginDate = u.LastLoginDate;
                userInfo.createdDate = u.CreatedDate;
                userInfo.managerName = u.Manager?.Name;
                userInfo.department = u.Department;
                userInfo.title = u.Title;
                result.add(userInfo);
            }
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving users: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get all profiles for filter dropdown
     * @return List of profile options
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getProfiles() {
        try {
            List<Profile> profiles = [SELECT Id, Name FROM Profile ORDER BY Name ASC];
            List<Map<String, String>> result = new List<Map<String, String>>();
            
            for (Profile p : profiles) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', p.Name);
                option.put('value', p.Id);
                result.add(option);
            }
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving profiles: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get detailed user information for summary view
     * @param userId The user ID to get details for
     * @return UserInfo object with detailed information
     */
    @AuraEnabled
    public static UserInfo getUserDetails(String userId) {
        try {
            User user = [SELECT Id, Name, Username, Email, Profile.Name, Profile.Id, IsActive, 
                        LastLoginDate, CreatedDate, Manager.Name, Department, Title, ManagerId
                        FROM User WHERE Id = :userId LIMIT 1];
            
            UserInfo userInfo = new UserInfo();
            userInfo.id = user.Id;
            userInfo.name = user.Name;
            userInfo.username = user.Username;
            userInfo.email = user.Email;
            userInfo.profileName = user.Profile.Name;
            userInfo.profileId = user.Profile.Id;
            userInfo.isActive = user.IsActive;
            userInfo.lastLoginDate = user.LastLoginDate;
            userInfo.createdDate = user.CreatedDate;
            userInfo.managerId = user.ManagerId;
            userInfo.managerName = user.Manager?.Name;
            userInfo.department = user.Department;
            userInfo.title = user.Title;
            
            return userInfo;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving user details: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get permission sets assigned to a user
     * @param userId The user ID to get permission sets for
     * @return List of PermissionSetInfo objects
     */
    @AuraEnabled
    public static List<PermissionSetInfo> getUserPermissionSets(String userId) {
        try {
            List<PermissionSetAssignment> assignments = [
                SELECT PermissionSet.Id, PermissionSet.Name, PermissionSet.Label, 
                       PermissionSet.Description, PermissionSet.Type, PermissionSet.IsOwnedByProfile
                FROM PermissionSetAssignment 
                WHERE AssigneeId = :userId
                ORDER BY PermissionSet.Label ASC
            ];
            
            List<PermissionSetInfo> result = new List<PermissionSetInfo>();
            
            for (PermissionSetAssignment psa : assignments) {
                PermissionSetInfo psInfo = new PermissionSetInfo();
                psInfo.id = psa.PermissionSet.Id;
                psInfo.name = psa.PermissionSet.Name;
                psInfo.label = psa.PermissionSet.Label;
                psInfo.description = psa.PermissionSet.Description;
                psInfo.type = psa.PermissionSet.Type;
                psInfo.isGroup = psa.PermissionSet.Type == 'Group';
                psInfo.source = psa.PermissionSet.IsOwnedByProfile ? 'Profile' : 'Permission Set';
                result.add(psInfo);
            }
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving permission sets: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get object permissions for a user
     * @param userId The user ID to get object permissions for
     * @return List of ObjectPermissionInfo objects
     */
    @AuraEnabled
    public static List<ObjectPermissionInfo> getUserObjectPermissions(String userId) {
        try {
            // Get all permission set IDs for the user
            List<PermissionSetAssignment> assignments = [
                SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId
            ];
            
            Set<Id> permissionSetIds = new Set<Id>();
            for (PermissionSetAssignment psa : assignments) {
                permissionSetIds.add(psa.PermissionSetId);
            }
            
            // Get object permissions
            List<ObjectPermissions> objectPerms = [
                SELECT SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, 
                       PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords,
                       Parent.Label
                FROM ObjectPermissions 
                WHERE ParentId IN :permissionSetIds
                ORDER BY SobjectType ASC
            ];
            
            Map<String, ObjectPermissionInfo> objectPermMap = new Map<String, ObjectPermissionInfo>();
            
            for (ObjectPermissions op : objectPerms) {
                String objName = op.SobjectType;
                ObjectPermissionInfo objPermInfo;
                
                if (objectPermMap.containsKey(objName)) {
                    objPermInfo = objectPermMap.get(objName);
                    // Merge permissions (OR logic)
                    objPermInfo.canCreate = objPermInfo.canCreate || op.PermissionsCreate;
                    objPermInfo.canRead = objPermInfo.canRead || op.PermissionsRead;
                    objPermInfo.canEdit = objPermInfo.canEdit || op.PermissionsEdit;
                    objPermInfo.canDelete = objPermInfo.canDelete || op.PermissionsDelete;
                    objPermInfo.canViewAll = objPermInfo.canViewAll || op.PermissionsViewAllRecords;
                    objPermInfo.canModifyAll = objPermInfo.canModifyAll || op.PermissionsModifyAllRecords;
                } else {
                    objPermInfo = new ObjectPermissionInfo();
                    objPermInfo.objectName = objName;
                    objPermInfo.objectLabel = getObjectLabel(objName);
                    objPermInfo.canCreate = op.PermissionsCreate;
                    objPermInfo.canRead = op.PermissionsRead;
                    objPermInfo.canEdit = op.PermissionsEdit;
                    objPermInfo.canDelete = op.PermissionsDelete;
                    objPermInfo.canViewAll = op.PermissionsViewAllRecords;
                    objPermInfo.canModifyAll = op.PermissionsModifyAllRecords;
                    objPermInfo.source = op.Parent.Label;
                    objectPermMap.put(objName, objPermInfo);
                }
            }
            
            return objectPermMap.values();
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving object permissions: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get field permissions for a user
     * @param userId The user ID to get field permissions for
     * @return List of FieldPermissionInfo objects
     */
    @AuraEnabled
    public static List<FieldPermissionInfo> getUserFieldPermissions(String userId) {
        try {
            // Get all permission set IDs for the user
            List<PermissionSetAssignment> assignments = [
                SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId
            ];
            
            Set<Id> permissionSetIds = new Set<Id>();
            for (PermissionSetAssignment psa : assignments) {
                permissionSetIds.add(psa.PermissionSetId);
            }
            
            // Get field permissions
            List<FieldPermissions> fieldPerms = [
                SELECT Field, PermissionsRead, PermissionsEdit, Parent.Label
                FROM FieldPermissions 
                WHERE ParentId IN :permissionSetIds
                ORDER BY Field ASC
            ];
            
            Map<String, FieldPermissionInfo> fieldPermMap = new Map<String, FieldPermissionInfo>();
            
            for (FieldPermissions fp : fieldPerms) {
                String fieldKey = fp.Field;
                FieldPermissionInfo fieldPermInfo;
                
                if (fieldPermMap.containsKey(fieldKey)) {
                    fieldPermInfo = fieldPermMap.get(fieldKey);
                    // Merge permissions (OR logic)
                    fieldPermInfo.canRead = fieldPermInfo.canRead || fp.PermissionsRead;
                    fieldPermInfo.canEdit = fieldPermInfo.canEdit || fp.PermissionsEdit;
                } else {
                    fieldPermInfo = new FieldPermissionInfo();
                    String[] fieldParts = fieldKey.split('\\.');
                    if (fieldParts.size() >= 2) {
                        fieldPermInfo.objectName = fieldParts[0];
                        fieldPermInfo.fieldName = fieldParts[1];
                        fieldPermInfo.objectLabel = getObjectLabel(fieldParts[0]);
                        fieldPermInfo.fieldLabel = getFieldLabel(fieldParts[0], fieldParts[1]);
                    }
                    fieldPermInfo.canRead = fp.PermissionsRead;
                    fieldPermInfo.canEdit = fp.PermissionsEdit;
                    fieldPermInfo.source = fp.Parent.Label;
                    fieldPermMap.put(fieldKey, fieldPermInfo);
                }
            }
            
            return fieldPermMap.values();
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving field permissions: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get tab information for a user
     * @param userId The user ID to get tab information for
     * @return List of TabInfo objects
     */
    @AuraEnabled
    public static List<TabInfo> getUserTabs(String userId) {
        try {
            // Get user's profile
            User user = [SELECT ProfileId FROM User WHERE Id = :userId LIMIT 1];
            
            // Get tab visibility settings
            List<PermissionSetTabSetting> tabSettings = [
                SELECT Name, Visibility
                FROM PermissionSetTabSetting 
                WHERE ParentId = :user.ProfileId
                ORDER BY Name ASC
            ];
            
            List<TabInfo> result = new List<TabInfo>();
            
            for (PermissionSetTabSetting tabSetting : tabSettings) {
                TabInfo tabInfo = new TabInfo();
                tabInfo.tabName = tabSetting.Name;
                tabInfo.tabLabel = getTabLabel(tabSetting.Name);
                tabInfo.visibility = tabSetting.Visibility;
                tabInfo.isAvailable = tabSetting.Visibility != 'Hidden';
                tabInfo.tabType = 'Custom'; // Default to Custom, could be enhanced
                result.add(tabInfo);
            }
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving tab information: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get connected apps information for a user
     * @param userId The user ID to get connected apps for
     * @return List of ConnectedAppInfo objects
     */
    @AuraEnabled
    public static List<ConnectedAppInfo> getUserConnectedApps(String userId) {
        try {
            // Note: Connected app access is complex and may require additional setup
            // This is a simplified implementation
            List<ConnectedApplication> connectedApps = [
                SELECT Id, Name, Description
                FROM ConnectedApplication
                ORDER BY Name ASC
                LIMIT 100
            ];
            
            List<ConnectedAppInfo> result = new List<ConnectedAppInfo>();
            
            for (ConnectedApplication app : connectedApps) {
                ConnectedAppInfo appInfo = new ConnectedAppInfo();
                appInfo.id = app.Id;
                appInfo.name = app.Name;
                appInfo.label = app.Name;
                appInfo.description = app.Description;
                appInfo.permissions = new List<String>(); // Would need additional queries
                appInfo.accessType = 'Available'; // Simplified
                result.add(appInfo);
            }
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving connected apps: ' + e.getMessage());
        }
    }
    
    /**
     * @description Helper method to get object label
     * @param objectName API name of the object
     * @return Object label
     */
    private static String getObjectLabel(String objectName) {
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType != null) {
                return objType.getDescribe().getLabel();
            }
            return objectName;
        } catch (Exception e) {
            return objectName;
        }
    }
    
    /**
     * @description Helper method to get field label
     * @param objectName API name of the object
     * @param fieldName API name of the field
     * @return Field label
     */
    private static String getFieldLabel(String objectName, String fieldName) {
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType != null) {
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                Schema.SObjectField field = objDescribe.fields.getMap().get(fieldName);
                if (field != null) {
                    return field.getDescribe().getLabel();
                }
            }
            return fieldName;
        } catch (Exception e) {
            return fieldName;
        }
    }
    
    /**
     * @description Helper method to get tab label
     * @param tabName API name of the tab
     * @return Tab label
     */
    private static String getTabLabel(String tabName) {
        // This is a simplified implementation
        // In a real scenario, you might need to query tab metadata
        return tabName.replace('_', ' ');
    }
}
