/**
 * @description Test class for UserAccessSummaryController
 * @author Salesforce Development Team
 * @date 2025
 */
@IsTest
public with sharing class UserAccessSummaryControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test profiles
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create test users
        List<User> testUsers = new List<User>();
        
        User activeUser = new User(
            FirstName = 'Active',
            LastName = 'TestUser',
            Username = 'activetest@useracccess.test',
            Email = 'activetest@useracccess.test',
            Alias = 'atest',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            Department = 'IT',
            Title = 'Developer'
        );
        testUsers.add(activeUser);
        
        User inactiveUser = new User(
            FirstName = 'Inactive',
            LastName = 'TestUser',
            Username = 'inactivetest@useracccess.test',
            Email = 'inactivetest@useracccess.test',
            Alias = 'itest',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = false,
            Department = 'Sales',
            Title = 'Manager'
        );
        testUsers.add(inactiveUser);
        
        insert testUsers;
        
        // Create test permission set
        PermissionSet testPermSet = new PermissionSet(
            Name = 'Test_Permission_Set',
            Label = 'Test Permission Set',
            Description = 'Test permission set for unit tests'
        );
        insert testPermSet;
        
        // Assign permission set to active user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = activeUser.Id,
            PermissionSetId = testPermSet.Id
        );
        insert psa;
    }
    
    @IsTest
    static void testGetUsers() {
        Test.startTest();
        
        // Test with no filters
        List<UserAccessSummaryController.UserInfo> users = UserAccessSummaryController.getUsers(
            null, null, true, 50, 0
        );
        
        System.assertNotEquals(null, users, 'Users list should not be null');
        System.assert(users.size() >= 2, 'Should return at least 2 test users');
        
        // Test with search term
        List<UserAccessSummaryController.UserInfo> searchedUsers = UserAccessSummaryController.getUsers(
            'Active', null, true, 50, 0
        );
        
        System.assertNotEquals(null, searchedUsers, 'Searched users list should not be null');
        
        // Test excluding inactive users
        List<UserAccessSummaryController.UserInfo> activeUsers = UserAccessSummaryController.getUsers(
            null, null, false, 50, 0
        );
        
        System.assertNotEquals(null, activeUsers, 'Active users list should not be null');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetProfiles() {
        Test.startTest();
        
        List<Map<String, String>> profiles = UserAccessSummaryController.getProfiles();
        
        System.assertNotEquals(null, profiles, 'Profiles list should not be null');
        System.assert(profiles.size() > 0, 'Should return at least one profile');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetUserDetails() {
        User testUser = [SELECT Id FROM User WHERE Username = 'activetest@useracccess.test' LIMIT 1];
        
        Test.startTest();
        
        UserAccessSummaryController.UserInfo userDetails = UserAccessSummaryController.getUserDetails(testUser.Id);
        
        System.assertNotEquals(null, userDetails, 'User details should not be null');
        System.assertEquals('Active TestUser', userDetails.name, 'User name should match');
        System.assertEquals('activetest@useracccess.test', userDetails.username, 'Username should match');
        System.assertEquals('activetest@useracccess.test', userDetails.email, 'Email should match');
        System.assertEquals(true, userDetails.isActive, 'User should be active');
        System.assertEquals('IT', userDetails.department, 'Department should match');
        System.assertEquals('Developer', userDetails.title, 'Title should match');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetUserPermissionSets() {
        User testUser = [SELECT Id FROM User WHERE Username = 'activetest@useracccess.test' LIMIT 1];
        
        Test.startTest();
        
        List<UserAccessSummaryController.PermissionSetInfo> permissionSets = 
            UserAccessSummaryController.getUserPermissionSets(testUser.Id);
        
        System.assertNotEquals(null, permissionSets, 'Permission sets list should not be null');
        System.assert(permissionSets.size() >= 1, 'Should return at least one permission set');
        
        // Check if our test permission set is included
        Boolean foundTestPermSet = false;
        for (UserAccessSummaryController.PermissionSetInfo ps : permissionSets) {
            if (ps.name == 'Test_Permission_Set') {
                foundTestPermSet = true;
                System.assertEquals('Test Permission Set', ps.label, 'Permission set label should match');
                break;
            }
        }
        System.assert(foundTestPermSet, 'Test permission set should be found');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetUserObjectPermissions() {
        User testUser = [SELECT Id FROM User WHERE Username = 'activetest@useracccess.test' LIMIT 1];
        
        Test.startTest();
        
        List<UserAccessSummaryController.ObjectPermissionInfo> objectPermissions = 
            UserAccessSummaryController.getUserObjectPermissions(testUser.Id);
        
        System.assertNotEquals(null, objectPermissions, 'Object permissions list should not be null');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetUserFieldPermissions() {
        User testUser = [SELECT Id FROM User WHERE Username = 'activetest@useracccess.test' LIMIT 1];
        
        Test.startTest();
        
        List<UserAccessSummaryController.FieldPermissionInfo> fieldPermissions = 
            UserAccessSummaryController.getUserFieldPermissions(testUser.Id);
        
        System.assertNotEquals(null, fieldPermissions, 'Field permissions list should not be null');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetUserTabs() {
        User testUser = [SELECT Id FROM User WHERE Username = 'activetest@useracccess.test' LIMIT 1];
        
        Test.startTest();
        
        List<UserAccessSummaryController.TabInfo> tabs = 
            UserAccessSummaryController.getUserTabs(testUser.Id);
        
        System.assertNotEquals(null, tabs, 'Tabs list should not be null');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetUserConnectedApps() {
        User testUser = [SELECT Id FROM User WHERE Username = 'activetest@useracccess.test' LIMIT 1];
        
        Test.startTest();
        
        List<UserAccessSummaryController.ConnectedAppInfo> connectedApps = 
            UserAccessSummaryController.getUserConnectedApps(testUser.Id);
        
        System.assertNotEquals(null, connectedApps, 'Connected apps list should not be null');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testErrorHandling() {
        Test.startTest();
        
        try {
            // Test with invalid user ID
            UserAccessSummaryController.getUserDetails('invalid_id');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error retrieving user details'), 
                         'Should throw proper error message');
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testPagination() {
        Test.startTest();
        
        // Test with limit and offset
        List<UserAccessSummaryController.UserInfo> page1 = UserAccessSummaryController.getUsers(
            null, null, true, 1, 0
        );
        
        List<UserAccessSummaryController.UserInfo> page2 = UserAccessSummaryController.getUsers(
            null, null, true, 1, 1
        );
        
        System.assertNotEquals(null, page1, 'Page 1 should not be null');
        System.assertNotEquals(null, page2, 'Page 2 should not be null');
        System.assertEquals(1, page1.size(), 'Page 1 should have 1 user');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testProfileFilter() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        Test.startTest();
        
        List<String> profileIds = new List<String>{ standardProfile.Id };
        List<UserAccessSummaryController.UserInfo> filteredUsers = UserAccessSummaryController.getUsers(
            null, profileIds, true, 50, 0
        );
        
        System.assertNotEquals(null, filteredUsers, 'Filtered users should not be null');
        
        // Verify all returned users have the specified profile
        for (UserAccessSummaryController.UserInfo user : filteredUsers) {
            System.assertEquals(standardProfile.Id, user.profileId, 'User should have correct profile');
        }
        
        Test.stopTest();
    }
}
