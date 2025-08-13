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
        @AuraEnabled public Boolean hasRead;
        @AuraEnabled public Boolean hasEdit;
        @AuraEnabled public String permissionSetName;
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
            // Create filter criteria object
            UserAccessFilterCriteria filterCriteria = new UserAccessFilterCriteria();
            filterCriteria.searchTerm = searchTerm;
            filterCriteria.profileIds = profileIds;
            filterCriteria.includeInactive = includeInactive;
            filterCriteria.limitSize = limitSize;
            filterCriteria.offset = offset;
            
            List<User> users = UserAccessQueryHelper.getUsersWithFilters(filterCriteria);
            return convertUsersToUserInfo(users);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving users: ' + e.getMessage());
        }
    }
    
    /**
     * @description Convert User records to UserInfo objects
     * @param users List of User records
     * @return List of UserInfo objects
     */
    private static List<UserInfo> convertUsersToUserInfo(List<User> users) {
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
    }
    
    /**
     * @description Get all profiles for filter dropdown
     * @return List of profile options
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getProfiles() {
        try {
            if (!UserAccessSecurityUtil.hasProfileAccessPermission()) {
                throw new AuraHandledException('Insufficient permissions to access profile data');
            }
            
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
            User user = UserAccessQueryHelper.getUserById(userId);
            return convertUserToUserInfo(user);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving user details: ' + e.getMessage());
        }
    }
    
    /**
     * @description Convert single User record to UserInfo object
     * @param user User record
     * @return UserInfo object
     */
    private static UserInfo convertUserToUserInfo(User user) {
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
    }
    
    /**
     * @description Get permission sets assigned to a user
     * @param userId The user ID to get permission sets for
     * @return List of PermissionSetInfo objects
     */
    @AuraEnabled
    public static List<PermissionSetInfo> getUserPermissionSets(String userId) {
        try {
            List<PermissionSetAssignment> assignments = UserAccessQueryHelper.getPermissionSetAssignments(userId);
            return convertToPermissionSetInfo(assignments);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving permission sets: ' + e.getMessage());
        }
    }
    
    /**
     * @description Convert PermissionSetAssignment records to PermissionSetInfo objects
     * @param assignments List of PermissionSetAssignment records
     * @return List of PermissionSetInfo objects
     */
    private static List<PermissionSetInfo> convertToPermissionSetInfo(List<PermissionSetAssignment> assignments) {
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
    }
    
    /**
     * @description Get object permissions for a user
     * @param userId The user ID to get object permissions for
     * @return List of ObjectPermissionInfo objects
     */
    @AuraEnabled
    public static List<ObjectPermissionInfo> getUserObjectPermissions(String userId) {
        try {
            List<PermissionSetAssignment> assignments = UserAccessQueryHelper.getPermissionSetAssignments(userId);
            Set<Id> permissionSetIds = extractPermissionSetIds(assignments);
            
            if (permissionSetIds.isEmpty()) {
                return new List<ObjectPermissionInfo>();
            }
            
            List<ObjectPermissions> objectPerms = UserAccessQueryHelper.getObjectPermissions(permissionSetIds);
            return processObjectPermissions(objectPerms);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving object permissions: ' + e.getMessage());
        }
    }
    
    /**
     * @description Extract permission set IDs from assignments
     * @param assignments List of PermissionSetAssignment records
     * @return Set of permission set IDs
     */
    private static Set<Id> extractPermissionSetIds(List<PermissionSetAssignment> assignments) {
        Set<Id> permissionSetIds = new Set<Id>();
        for (PermissionSetAssignment psa : assignments) {
            permissionSetIds.add(psa.PermissionSet.Id);
        }
        return permissionSetIds;
    }
    
    /**
     * @description Process object permissions and merge duplicates
     * @param objectPerms List of ObjectPermissions records
     * @return List of ObjectPermissionInfo objects
     */
    private static List<ObjectPermissionInfo> processObjectPermissions(List<ObjectPermissions> objectPerms) {
        Map<String, ObjectPermissionInfo> objectPermMap = new Map<String, ObjectPermissionInfo>();
        
        for (ObjectPermissions op : objectPerms) {
            String objName = op.SobjectType;
            ObjectPermissionInfo objPermInfo = objectPermMap.get(objName);
            
            if (objPermInfo == null) {
                objPermInfo = createObjectPermissionInfo(op);
                objectPermMap.put(objName, objPermInfo);
            } else {
                mergeObjectPermissions(objPermInfo, op);
            }
        }
        
        return objectPermMap.values();
    }
    
    /**
     * @description Create ObjectPermissionInfo from ObjectPermissions record
     * @param op ObjectPermissions record
     * @return ObjectPermissionInfo object
     */
    private static ObjectPermissionInfo createObjectPermissionInfo(ObjectPermissions op) {
        ObjectPermissionInfo objPermInfo = new ObjectPermissionInfo();
        objPermInfo.objectName = op.SobjectType;
        objPermInfo.objectLabel = getObjectLabel(op.SobjectType);
        objPermInfo.canCreate = op.PermissionsCreate;
        objPermInfo.canRead = op.PermissionsRead;
        objPermInfo.canEdit = op.PermissionsEdit;
        objPermInfo.canDelete = op.PermissionsDelete;
        objPermInfo.canViewAll = op.PermissionsViewAllRecords;
        objPermInfo.canModifyAll = op.PermissionsModifyAllRecords;
        objPermInfo.source = op.Parent.Label;
        return objPermInfo;
    }
    
    /**
     * @description Merge object permissions using OR logic
     * @param objPermInfo Existing ObjectPermissionInfo
     * @param op New ObjectPermissions record
     */
    private static void mergeObjectPermissions(ObjectPermissionInfo objPermInfo, ObjectPermissions op) {
        objPermInfo.canCreate = objPermInfo.canCreate || op.PermissionsCreate;
        objPermInfo.canRead = objPermInfo.canRead || op.PermissionsRead;
        objPermInfo.canEdit = objPermInfo.canEdit || op.PermissionsEdit;
        objPermInfo.canDelete = objPermInfo.canDelete || op.PermissionsDelete;
        objPermInfo.canViewAll = objPermInfo.canViewAll || op.PermissionsViewAllRecords;
        objPermInfo.canModifyAll = objPermInfo.canModifyAll || op.PermissionsModifyAllRecords;
    }
    
    /**
     * @description Get field permissions for a user using ultra-conservative approach
     * @param userId The user ID to get field permissions for
     * @return List of FieldPermissionInfo objects
     */
    @AuraEnabled
    public static List<FieldPermissionInfo> getUserFieldPermissions(String userId) {
        try {
            List<PermissionSetAssignment> assignments = UserAccessQueryHelper.getPermissionSetAssignments(userId);
            Set<Id> permissionSetIds = extractPermissionSetIds(assignments);
            
            if (permissionSetIds.isEmpty()) {
                return new List<FieldPermissionInfo>();
            }

            // Try the optimized approach first
            try {
                return processFieldPermissionsWithCursor(permissionSetIds);
            } catch (Exception e) {
                System.debug('Main field permissions method failed, trying minimal approach: ' + e.getMessage());
                // Fallback to minimal approach
                return getMinimalFieldPermissions(permissionSetIds);
            }
        } catch (Exception e) {
            // If we hit system limits, return empty list with a specific error message
            if (e.getMessage().contains('CPU time limit exceeded') || 
                e.getMessage().contains('Apex CPU time limit exceeded') ||
                e.getMessage().contains('Maximum CPU time exceeded')) {
                throw new AuraHandledException('Field permissions could not be loaded due to system limits');
            }
            throw new AuraHandledException('Error retrieving field permissions: ' + e.getMessage());
        }
    }

    /**
     * @description Get minimal field permissions as last resort
     * @param permissionSetIds Set of permission set IDs
     * @return List of FieldPermissionInfo objects
     */
    private static List<FieldPermissionInfo> getMinimalFieldPermissions(Set<Id> permissionSetIds) {
        Map<String, FieldPermissionInfo> fieldPermMap = new Map<String, FieldPermissionInfo>();
        
        // Just get the first permission set and only 50 records
        List<Id> permSetIdList = new List<Id>(permissionSetIds);
        if (permSetIdList.isEmpty()) {
            return new List<FieldPermissionInfo>();
        }
        
        try {
            List<FieldPermissions> minimalFields = [
                SELECT Field, PermissionsRead, PermissionsEdit, Parent.Label
                FROM FieldPermissions 
                WHERE ParentId = :permSetIdList[0]
                AND (PermissionsRead = true OR PermissionsEdit = true)
                ORDER BY Field ASC
                LIMIT 50
            ];
            
            for (FieldPermissions fp : minimalFields) {
                // Add null safety checks
                if (fp == null || String.isBlank(fp.Field)) {
                    continue;
                }
                
                String fieldKey = fp.Field;
                FieldPermissionInfo fieldPermInfo = createFieldPermissionInfoOptimized(fp, fieldKey);
                
                if (fieldPermInfo != null && String.isNotBlank(fieldKey)) {
                    fieldPermMap.put(fieldKey, fieldPermInfo);
                }
            }
            
            List<FieldPermissionInfo> result = fieldPermMap.values();
            
            // Safe sorting with null checks
            try {
                result.sort(new FieldPermissionComparator());
            } catch (Exception e) {
                System.debug('Error sorting minimal field permissions: ' + e.getMessage());
                // Continue with unsorted results
            }
            
            System.debug('Minimal field permissions: returning ' + result.size() + ' fields');
            return result;
            
        } catch (Exception e) {
            System.debug('Even minimal field permissions failed: ' + e.getMessage());
            return new List<FieldPermissionInfo>();
        }
    }

    /**
     * @description Process field permissions using ultra-conservative batching approach
     * @param permissionSetIds Set of permission set IDs
     * @return List of FieldPermissionInfo objects
     */
    private static List<FieldPermissionInfo> processFieldPermissionsWithCursor(Set<Id> permissionSetIds) {
        Map<String, FieldPermissionInfo> fieldPermMap = new Map<String, FieldPermissionInfo>();
        Integer processedCount = 0;
        Integer maxRecords = 500; // Very conservative limit
        Integer maxCpuPercent = 50; // Stop at 50% CPU usage
        
        // Check permissions first
        if (!UserAccessSecurityUtil.hasFieldPermissionAccessPermission() || 
            !Schema.sObjectType.FieldPermissions.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access field permission data');
        }
        
        // Convert Set to List for processing
        List<Id> permSetIdList = new List<Id>(permissionSetIds);
        
        // Process only the first few permission sets to avoid timeouts
        Integer maxPermSetsToProcess = Math.min(3, permSetIdList.size());
        
        for (Integer i = 0; i < maxPermSetsToProcess && processedCount < maxRecords; i++) {
            Id currentPermSetId = permSetIdList[i];
            
            // Check CPU before each permission set
            if (Limits.getCpuTime() > (Limits.getLimitCpuTime() * maxCpuPercent / 100)) {
                System.debug('Stopping early due to CPU usage: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
                break;
            }
            
            try {
                // Query field permissions for just this one permission set with a small limit
                List<FieldPermissions> singlePermSetFields = [
                    SELECT Field, PermissionsRead, PermissionsEdit, Parent.Label
                    FROM FieldPermissions 
                    WHERE ParentId = :currentPermSetId
                    AND (PermissionsRead = true OR PermissionsEdit = true)
                    ORDER BY Field ASC
                    LIMIT 100
                ];
                
                // Process this small batch
                for (FieldPermissions fp : singlePermSetFields) {
                    if (processedCount >= maxRecords) break;
                    
                    // Null safety checks
                    if (fp == null || String.isBlank(fp.Field)) {
                        continue; // Skip invalid records
                    }
                    
                    String fieldKey = fp.Field;
                    FieldPermissionInfo fieldPermInfo = fieldPermMap.get(fieldKey);
                    
                    if (fieldPermInfo == null) {
                        fieldPermInfo = createFieldPermissionInfoOptimized(fp, fieldKey);
                        if (fieldPermInfo != null && String.isNotBlank(fieldKey)) {
                            fieldPermMap.put(fieldKey, fieldPermInfo);
                        }
                    } else {
                        mergeFieldPermissions(fieldPermInfo, fp);
                    }
                    
                    processedCount++;
                }
                
            } catch (Exception e) {
                System.debug('Error processing permission set ' + currentPermSetId + ': ' + e.getMessage());
                // Continue with next permission set
                continue;
            }
        }
        
        List<FieldPermissionInfo> result = fieldPermMap.values();
        
        // Sort by object name then field name for better organization (with null safety)
        try {
            result.sort(new FieldPermissionComparator());
        } catch (Exception e) {
            System.debug('Error sorting field permissions, returning unsorted: ' + e.getMessage());
            // Continue with unsorted results rather than failing
        }
        
        System.debug('Ultra-conservative processing: ' + processedCount + ' field permissions from ' + 
                    maxPermSetsToProcess + ' permission sets, returning ' + result.size() + ' unique fields');
        return result;
    }
    
    /**
     * @description Get limited field permissions for quick preview (to avoid system limits)
     * @param userId The user ID to get field permissions for
     * @return List of FieldPermissionInfo objects (limited to 200 for performance)
     */
    @AuraEnabled
    public static List<FieldPermissionInfo> getUserFieldPermissionsLimited(String userId) {
        try {
            List<PermissionSetAssignment> assignments = UserAccessQueryHelper.getPermissionSetAssignments(userId);
            Set<Id> permissionSetIds = extractPermissionSetIds(assignments);
            
            if (permissionSetIds.isEmpty()) {
                return new List<FieldPermissionInfo>();
            }

            // Get limited field permissions for quick display
            List<FieldPermissions> fieldPerms = UserAccessQueryHelper.getFieldPermissionsLimited(permissionSetIds, 200);
            return processFieldPermissionsSimple(fieldPerms);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving field permissions: ' + e.getMessage());
        }
    }

    /**
     * @description Simple processing for limited field permissions
     * @param fieldPerms List of FieldPermissions records
     * @return List of FieldPermissionInfo objects
     */
    private static List<FieldPermissionInfo> processFieldPermissionsSimple(List<FieldPermissions> fieldPerms) {
        Map<String, FieldPermissionInfo> fieldPermMap = new Map<String, FieldPermissionInfo>();
        
        for (FieldPermissions fp : fieldPerms) {
            String fieldKey = fp.Field;
            FieldPermissionInfo fieldPermInfo = fieldPermMap.get(fieldKey);
            
            if (fieldPermInfo == null) {
                fieldPermInfo = createFieldPermissionInfoOptimized(fp, fieldKey);
                fieldPermMap.put(fieldKey, fieldPermInfo);
            } else {
                mergeFieldPermissions(fieldPermInfo, fp);
            }
        }
        
        List<FieldPermissionInfo> result = fieldPermMap.values();
        result.sort(new FieldPermissionComparator());
        
        return result;
    }

    /**
     * @description Get field permissions by object name (like Salesforce setup)
     * @param userId The user ID to get field permissions for
     * @param objectApiName The object API name to get field permissions for
     * @return List of FieldPermissionInfo objects
     */
    @AuraEnabled
    public static List<FieldPermissionInfo> getObjectFieldPermissions(String userId, String objectApiName) {
        try {
            List<PermissionSetAssignment> assignments = UserAccessQueryHelper.getPermissionSetAssignments(userId);
            Set<Id> permissionSetIds = extractPermissionSetIds(assignments);
            
            System.debug('Found permission set assignments: ' + assignments.size());
            System.debug('Permission set IDs: ' + permissionSetIds.size());

            // Get all fields for the specified object
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
                .get(objectApiName)?.getDescribe()?.fields?.getMap();
            
            if (fieldMap == null) {
                System.debug('Object not found: ' + objectApiName);
                return new List<FieldPermissionInfo>();
            }

            System.debug('Found ' + fieldMap.size() + ' fields for object: ' + objectApiName);

            // Get field permissions for this object (only if user has permission sets)
            List<FieldPermissions> fieldPerms = new List<FieldPermissions>();
            if (!permissionSetIds.isEmpty()) {
                String fieldPrefix = objectApiName + '.';
                fieldPerms = [
                    SELECT Field, PermissionsRead, PermissionsEdit, Parent.Label
                    FROM FieldPermissions 
                    WHERE ParentId IN :permissionSetIds
                    ORDER BY Field ASC
                    LIMIT 1000
                ];

                System.debug('Found ' + fieldPerms.size() + ' field permissions in permission sets');
            } else {
                System.debug('No permission sets found - user access likely comes from profile');
            }

            // Filter for the specific object after query (only if we have permission sets)
            String fieldPrefix = objectApiName + '.';
            List<FieldPermissions> objectFieldPerms = new List<FieldPermissions>();
            if (!permissionSetIds.isEmpty()) {
                for (FieldPermissions fp : fieldPerms) {
                    if (fp.Field != null && fp.Field.startsWith(fieldPrefix)) {
                        objectFieldPerms.add(fp);
                    }
                }
                System.debug('Found ' + objectFieldPerms.size() + ' field permissions for ' + objectApiName);
            }

            // Create a map of existing permissions
            Map<String, FieldPermissions> existingPerms = new Map<String, FieldPermissions>();
            for (FieldPermissions fp : objectFieldPerms) {
                existingPerms.put(fp.Field, fp);
            }

            // Build comprehensive field list - ALWAYS include all fields
            List<FieldPermissionInfo> result = new List<FieldPermissionInfo>();
            
            for (String fieldName : fieldMap.keySet()) {
                String fullFieldName = objectApiName + '.' + fieldName;
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                
                // Skip system fields that are not relevant for permissions
                if (isSystemField(fieldName)) {
                    continue;
                }

                FieldPermissionInfo fieldInfo = new FieldPermissionInfo();
                fieldInfo.objectName = objectApiName;
                
                // Use a cleaner field name format - just the API name for now
                fieldInfo.fieldName = fieldName;
                
                // Check if there's an explicit permission
                FieldPermissions fp = existingPerms.get(fullFieldName);
                if (fp != null) {
                    fieldInfo.hasRead = fp.PermissionsRead;
                    fieldInfo.hasEdit = fp.PermissionsEdit;
                    fieldInfo.permissionSetName = fp.Parent.Label;
                } else {
                    // Default permissions based on field accessibility
                    // For most users, if no explicit permission is set, they have default access
                    fieldInfo.hasRead = fieldDescribe.isAccessible();
                    fieldInfo.hasEdit = fieldDescribe.isUpdateable() && !fieldDescribe.isCalculated();
                    fieldInfo.permissionSetName = 'Default (Profile)';
                }
                
                // Also populate the legacy fields for backward compatibility
                fieldInfo.canRead = fieldInfo.hasRead;
                fieldInfo.canEdit = fieldInfo.hasEdit;
                fieldInfo.source = fieldInfo.permissionSetName;
                fieldInfo.fieldLabel = fieldDescribe.getLabel();
                fieldInfo.objectLabel = objectApiName;
                
                result.add(fieldInfo);
            }
            
            System.debug('Generated field permissions for ' + objectApiName + ': ' + result.size() + ' fields');
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving object field permissions: ' + e.getMessage());
        }
    }

    /**
     * @description Check if a field is a system field that should be excluded
     * @param fieldName The field name to check
     * @return Boolean indicating if it's a system field
     */
    private static Boolean isSystemField(String fieldName) {
        Set<String> systemFields = new Set<String>{
            'id', 'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 
            'lastmodifiedbyid', 'systemmodstamp', 'lastactivitydate', 'lastreferenceddate',
            'lastvieweddate', 'connectionreceivedid', 'connectionsentid'
        };
        return systemFields.contains(fieldName.toLowerCase());
    }

    /**
     * @description Get available objects for field permissions analysis
     * @return List of object API names and labels
     */
    @AuraEnabled
    public static List<Map<String, String>> getAvailableObjects() {
        try {
            List<Map<String, String>> objects = new List<Map<String, String>>();
            
            // Common objects that users typically need field permissions for
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            Set<String> commonObjects = new Set<String>{
                'Account', 'Contact', 'Lead', 'Opportunity', 'Case', 'Task', 'Event',
                'User', 'Campaign', 'Product2', 'Quote', 'Contract', 'Asset',
                'AppointmentInvitation', 'ApprovalSubmission', 'ApprovalWorkItem',
                'ContentDocument', 'ContentVersion', 'Document', 'Folder',
                'Order', 'OrderItem', 'Pricebook2', 'PricebookEntry',
                'Solution', 'Idea', 'Note', 'Attachment',
                'EmailMessage', 'EmailTemplate', 'Report', 'Dashboard',
                'WorkOrder', 'WorkOrderLineItem', 'ServiceAppointment',
                'Knowledge__kav', 'FAQ__kav'
            };
            
            // Also add any custom objects that are accessible
            for (String objName : globalDescribe.keySet()) {
                if (objName.endsWith('__c')) {
                    Schema.DescribeSObjectResult objDescribe = globalDescribe.get(objName).getDescribe();
                    if (objDescribe.isAccessible() && objDescribe.isCustom()) {
                        commonObjects.add(objName);
                    }
                }
            }
            
            for (String objName : commonObjects) {
                if (globalDescribe.containsKey(objName)) {
                    Schema.DescribeSObjectResult objDescribe = globalDescribe.get(objName).getDescribe();
                    if (objDescribe.isAccessible()) {
                        Map<String, String> objInfo = new Map<String, String>();
                        objInfo.put('apiName', objName);
                        objInfo.put('label', objDescribe.getLabel());
                        objects.add(objInfo);
                    }
                }
            }
            
            return objects;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving available objects: ' + e.getMessage());
        }
    }
    
    /**
     * @description Comparator class for sorting field permissions
     */
    public class FieldPermissionComparator implements Comparator<FieldPermissionInfo> {
        public Integer compare(FieldPermissionInfo a, FieldPermissionInfo b) {
            // Safe comparison with null checks
            String aObjectName = (a != null && a.objectName != null) ? a.objectName : '';
            String bObjectName = (b != null && b.objectName != null) ? b.objectName : '';
            String aFieldName = (a != null && a.fieldName != null) ? a.fieldName : '';
            String bFieldName = (b != null && b.fieldName != null) ? b.fieldName : '';
            
            if (!aObjectName.equals(bObjectName)) {
                return aObjectName.compareTo(bObjectName);
            }
            return aFieldName.compareTo(bFieldName);
        }
    }
    
    /**
     * @description Create FieldPermissionInfo from FieldPermissions record (optimized)
     * @param fp FieldPermissions record
     * @param fieldKey Field key (Object.Field format)
     * @return FieldPermissionInfo object
     */
    private static FieldPermissionInfo createFieldPermissionInfoOptimized(FieldPermissions fp, String fieldKey) {
        FieldPermissionInfo fieldPermInfo = new FieldPermissionInfo();
        
        // Safe field key parsing with null checks
        if (String.isNotBlank(fieldKey)) {
            String[] fieldParts = fieldKey.split('\\.');
            if (fieldParts != null && fieldParts.size() >= 2) {
                fieldPermInfo.objectName = fieldParts[0];
                fieldPermInfo.fieldName = fieldParts[1];
                // Use API names instead of labels to avoid expensive Schema calls
                fieldPermInfo.objectLabel = fieldParts[0]; // Use API name instead of label
                fieldPermInfo.fieldLabel = fieldParts[1]; // Use API name instead of label
            } else {
                // Fallback if field key is malformed
                fieldPermInfo.objectName = 'Unknown';
                fieldPermInfo.fieldName = fieldKey != null ? fieldKey : 'Unknown';
                fieldPermInfo.objectLabel = fieldPermInfo.objectName;
                fieldPermInfo.fieldLabel = fieldPermInfo.fieldName;
            }
        } else {
            fieldPermInfo.objectName = 'Unknown';
            fieldPermInfo.fieldName = 'Unknown';
            fieldPermInfo.objectLabel = 'Unknown';
            fieldPermInfo.fieldLabel = 'Unknown';
        }
        
        // Safe permission assignment with null checks
        if (fp != null) {
            fieldPermInfo.canRead = fp.PermissionsRead != null ? fp.PermissionsRead : false;
            fieldPermInfo.canEdit = fp.PermissionsEdit != null ? fp.PermissionsEdit : false;
            
            // Safe parent label access
            if (fp.Parent != null && String.isNotBlank(fp.Parent.Label)) {
                fieldPermInfo.source = fp.Parent.Label;
            } else {
                fieldPermInfo.source = 'Unknown Permission Set';
            }
        } else {
            fieldPermInfo.canRead = false;
            fieldPermInfo.canEdit = false;
            fieldPermInfo.source = 'Unknown Permission Set';
        }
        
        return fieldPermInfo;
    }
    
    /**
     * @description Merge field permissions using OR logic
     * @param fieldPermInfo Existing FieldPermissionInfo
     * @param fp New FieldPermissions record
     */
    private static void mergeFieldPermissions(FieldPermissionInfo fieldPermInfo, FieldPermissions fp) {
        if (fieldPermInfo != null && fp != null) {
            fieldPermInfo.canRead = fieldPermInfo.canRead || (fp.PermissionsRead != null ? fp.PermissionsRead : false);
            fieldPermInfo.canEdit = fieldPermInfo.canEdit || (fp.PermissionsEdit != null ? fp.PermissionsEdit : false);
        }
    }
    
    /**
     * @description Get tab information for a user (simplified implementation)
     * @param userId The user ID to get tab information for
     * @return List of TabInfo objects
     */
    @AuraEnabled
    public static List<TabInfo> getUserTabs(String userId) {
        try {
            // Simplified implementation - returns empty list
            // Tab visibility is complex and varies by org configuration
            return new List<TabInfo>();
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving tab information: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get connected apps information for a user (simplified implementation)
     * @param userId The user ID to get connected apps for
     * @return List of ConnectedAppInfo objects
     */
    @AuraEnabled
    public static List<ConnectedAppInfo> getUserConnectedApps(String userId) {
        try {
            List<ConnectedApplication> connectedApps = UserAccessQueryHelper.getConnectedApplications();
            List<ConnectedAppInfo> result = new List<ConnectedAppInfo>();
            
            for (ConnectedApplication app : connectedApps) {
                ConnectedAppInfo appInfo = new ConnectedAppInfo();
                appInfo.id = app.Id;
                appInfo.name = app.Name;
                appInfo.label = app.Name;
                appInfo.description = ''; // Description field not available
                appInfo.permissions = new List<String>();
                appInfo.accessType = 'Available';
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
            // Cache the describe call to avoid timeout
            if (String.isBlank(objectName)) {
                return objectName;
            }
            
            // Use a more efficient approach for common objects
            if (objectName.equalsIgnoreCase('Account')) return 'Account';
            if (objectName.equalsIgnoreCase('Contact')) return 'Contact';
            if (objectName.equalsIgnoreCase('Opportunity')) return 'Opportunity';
            if (objectName.equalsIgnoreCase('Lead')) return 'Lead';
            if (objectName.equalsIgnoreCase('Case')) return 'Case';
            if (objectName.equalsIgnoreCase('User')) return 'User';
            
            // For other objects, return the API name to avoid performance issues
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
    
    /**
     * @description Export user access data as CSV
     * @param userId User ID to export data for
     * @return CSV string content
     */
    @AuraEnabled
    public static String exportUserAccessData(String userId) {
        try {
            if (!UserAccessSecurityUtil.hasUserAccessPermission()) {
                throw new AuraHandledException('Insufficient permissions to export user data');
            }
            
            // Get user details
            UserInfo userInfo = getUserDetails(userId);
            if (userInfo == null) {
                throw new AuraHandledException('User not found');
            }
            
            // Get permission sets
            List<PermissionSetInfo> permissionSets = getUserPermissionSets(userId);
            
            // Get object permissions  
            List<ObjectPermissionInfo> objectPermissions = getUserObjectPermissions(userId);
            
            // Get field permissions
            List<FieldPermissionInfo> fieldPermissions = getUserFieldPermissions(userId);
            
            // Build CSV content
            String csvContent = buildCSVContent(userInfo, permissionSets, objectPermissions, fieldPermissions);
            
            return csvContent;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error exporting user access data: ' + e.getMessage());
        }
    }
    
    /**
     * @description Build CSV content from user access data
     * @param userInfo User information
     * @param permissionSets List of permission sets
     * @param objectPermissions List of object permissions
     * @param fieldPermissions List of field permissions
     * @return CSV content string
     */
    private static String buildCSVContent(UserInfo userInfo, List<PermissionSetInfo> permissionSets, 
                                         List<ObjectPermissionInfo> objectPermissions, 
                                         List<FieldPermissionInfo> fieldPermissions) {
        List<String> csvLines = new List<String>();
        
        // Header
        csvLines.add('User Access Summary Report');
        csvLines.add('Generated on: ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss'));
        csvLines.add('');
        
        // User Information
        csvLines.add('User Information');
        csvLines.add('Field,Value');
        csvLines.add('"Name","' + escapeCSV(userInfo.name) + '"');
        csvLines.add('"Username","' + escapeCSV(userInfo.username) + '"');
        csvLines.add('"Email","' + escapeCSV(userInfo.email) + '"');
        csvLines.add('"Profile","' + escapeCSV(userInfo.profileName) + '"');
        csvLines.add('"Status","' + (userInfo.isActive ? 'Active' : 'Inactive') + '"');
        csvLines.add('"Last Login","' + (userInfo.lastLoginDate != null ? String.valueOf(userInfo.lastLoginDate) : 'Never') + '"');
        csvLines.add('"Department","' + escapeCSV(userInfo.department) + '"');
        csvLines.add('"Title","' + escapeCSV(userInfo.title) + '"');
        csvLines.add('');
        
        // Permission Sets
        csvLines.add('Permission Sets');
        csvLines.add('Label,API Name,Description,Type');
        for (PermissionSetInfo ps : permissionSets) {
            csvLines.add('"' + escapeCSV(ps.label) + '",' +
                        '"' + escapeCSV(ps.name) + '",' +
                        '"' + escapeCSV(ps.description) + '",' +
                        '"' + escapeCSV(ps.type) + '"');
        }
        csvLines.add('');
        
        // Object Permissions
        csvLines.add('Object Permissions');
        csvLines.add('Object Label,Object API Name,Create,Read,Edit,Delete,View All,Modify All');
        for (ObjectPermissionInfo op : objectPermissions) {
            csvLines.add('"' + escapeCSV(op.objectLabel) + '",' +
                        '"' + escapeCSV(op.objectName) + '",' +
                        op.canCreate + ',' +
                        op.canRead + ',' +
                        op.canEdit + ',' +
                        op.canDelete + ',' +
                        op.canViewAll + ',' +
                        op.canModifyAll);
        }
        csvLines.add('');
        
        // Field Permissions (limited to avoid huge files)
        csvLines.add('Field Permissions (Top 100)');
        csvLines.add('Object,Field,Read,Edit');
        Integer fieldCount = 0;
        for (FieldPermissionInfo fp : fieldPermissions) {
            if (fieldCount >= 100) break;
            csvLines.add('"' + escapeCSV(fp.objectName) + '",' +
                        '"' + escapeCSV(fp.fieldName) + '",' +
                        fp.canRead + ',' +
                        fp.canEdit);
            fieldCount++;
        }
        
        return String.join(csvLines, '\n');
    }
    
    /**
     * @description Escape CSV values to handle quotes and commas
     * @param value Value to escape
     * @return Escaped value
     */
    private static String escapeCSV(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        return value.replace('"', '""');
    }
}
