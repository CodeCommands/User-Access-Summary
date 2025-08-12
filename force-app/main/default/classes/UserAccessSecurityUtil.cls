/**
 * @description Security utility class for User Access Summary operations
 * @author Salesforce Development Team
 * @date 2025
 */
public with sharing class UserAccessSecurityUtil {
    
    /**
     * @description Check if current user has permission to access user data
     * @return Boolean indicating if access is allowed
     */
    public static Boolean hasUserAccessPermission() {
        return Schema.sObjectType.User.isAccessible() && 
               Schema.sObjectType.User.fields.Name.isAccessible() &&
               Schema.sObjectType.User.fields.Username.isAccessible() &&
               Schema.sObjectType.User.fields.Email.isAccessible();
    }
    
    /**
     * @description Check if current user has permission to access profile data
     * @return Boolean indicating if access is allowed
     */
    public static Boolean hasProfileAccessPermission() {
        return Schema.sObjectType.Profile.isAccessible() && 
               Schema.sObjectType.Profile.fields.Name.isAccessible();
    }
    
    /**
     * @description Check if current user has permission to access permission set data
     * @return Boolean indicating if access is allowed
     */
    public static Boolean hasPermissionSetAccessPermission() {
        return Schema.sObjectType.PermissionSet.isAccessible() && 
               Schema.sObjectType.PermissionSetAssignment.isAccessible();
    }
    
    /**
     * @description Check if current user has permission to access object permission data
     * @return Boolean indicating if access is allowed
     */
    public static Boolean hasObjectPermissionAccessPermission() {
        return Schema.sObjectType.ObjectPermissions.isAccessible();
    }
    
    /**
     * @description Check if current user has permission to access field permission data
     * @return Boolean indicating if access is allowed
     */
    public static Boolean hasFieldPermissionAccessPermission() {
        return Schema.sObjectType.FieldPermissions.isAccessible();
    }
    
    /**
     * @description Check if current user has permission to access connected app data
     * @return Boolean indicating if access is allowed
     */
    public static Boolean hasConnectedAppAccessPermission() {
        return Schema.sObjectType.ConnectedApplication.isAccessible();
    }
}
