/**
 * @description Test class for UserAccessExportHelper
 * @author Salesforce Development Team
 * @date 2025
 */
@IsTest
public with sharing class UserAccessExportHelperTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test profile
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create test user
        User testUser = new User(
            FirstName = 'Export',
            LastName = 'TestUser',
            Username = 'exporttest@useracccess.test',
            Email = 'exporttest@useracccess.test',
            Alias = 'etest',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            Department = 'IT',
            Title = 'Test Developer'
        );
        insert testUser;
        
        // Create test permission set
        PermissionSet testPermSet = new PermissionSet(
            Name = 'Export_Test_Permission_Set',
            Label = 'Export Test Permission Set',
            Description = 'Test permission set for export functionality'
        );
        insert testPermSet;
        
        // Assign permission set to user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = testPermSet.Id
        );
        insert psa;
    }
    
    @IsTest
    static void testGenerateExcelExport() {
        User testUser = [SELECT Id FROM User WHERE Username = 'exporttest@useracccess.test' LIMIT 1];
        
        Test.startTest();
        
        String exportContent = UserAccessExportHelper.generateExcelExport(testUser.Id);
        
        System.assertNotEquals(null, exportContent, 'Export content should not be null');
        System.assert(exportContent.length() > 0, 'Export content should not be empty');
        
        // Decode and verify content contains expected sections
        Blob decodedBlob = EncodingUtil.base64Decode(exportContent);
        String csvContent = decodedBlob.toString();
        
        System.assert(csvContent.contains('User Access Summary Report'), 'Should contain report title');
        System.assert(csvContent.contains('=== USER INFORMATION ==='), 'Should contain user info section');
        System.assert(csvContent.contains('=== PERMISSION SETS ==='), 'Should contain permission sets section');
        System.assert(csvContent.contains('Export TestUser'), 'Should contain test user name');
        System.assert(csvContent.contains('exporttest@useracccess.test'), 'Should contain test user email');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGenerateExportFilename() {
        Test.startTest();
        
        String filename = UserAccessExportHelper.generateExportFilename('test.user@example.com');
        
        System.assertNotEquals(null, filename, 'Filename should not be null');
        System.assert(filename.startsWith('UserAccessSummary_'), 'Filename should start with prefix');
        System.assert(filename.endsWith('.csv'), 'Filename should end with .csv');
        System.assert(filename.contains('test_user_example_com'), 'Should sanitize username');
        
        // Test with current date
        String dateString = DateTime.now().format('yyyy-MM-dd');
        System.assert(filename.contains(dateString), 'Filename should contain current date');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGenerateExportFilenameWithSpecialCharacters() {
        Test.startTest();
        
        String filename = UserAccessExportHelper.generateExportFilename('user@domain.com!@#$%^&*()');
        
        System.assertNotEquals(null, filename, 'Filename should not be null');
        System.assert(filename.contains('user_domain_com_'), 'Should replace special characters with underscores');
        System.assertNotEquals(true, filename.contains('@'), 'Should not contain @ character');
        System.assertNotEquals(true, filename.contains('!'), 'Should not contain ! character');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testErrorHandling() {
        Test.startTest();
        
        try {
            // Test with invalid user ID
            UserAccessExportHelper.generateExcelExport('invalid_user_id');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error generating export'), 
                         'Should throw proper error message');
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testExportWithCompleteData() {
        User testUser = [SELECT Id FROM User WHERE Username = 'exporttest@useracccess.test' LIMIT 1];
        
        Test.startTest();
        
        // Generate export and verify comprehensive data
        String exportContent = UserAccessExportHelper.generateExcelExport(testUser.Id);
        Blob decodedBlob = EncodingUtil.base64Decode(exportContent);
        String csvContent = decodedBlob.toString();
        
        // Verify all sections are present
        System.assert(csvContent.contains('=== USER INFORMATION ==='), 'Should contain user information');
        System.assert(csvContent.contains('=== PERMISSION SETS ==='), 'Should contain permission sets');
        System.assert(csvContent.contains('=== OBJECT PERMISSIONS ==='), 'Should contain object permissions');
        System.assert(csvContent.contains('=== FIELD PERMISSIONS ==='), 'Should contain field permissions');
        System.assert(csvContent.contains('=== TAB PERMISSIONS ==='), 'Should contain tab permissions');
        System.assert(csvContent.contains('=== CONNECTED APPS ==='), 'Should contain connected apps');
        System.assert(csvContent.contains('=== END OF REPORT ==='), 'Should contain report end marker');
        
        // Verify user data
        System.assert(csvContent.contains('Export TestUser'), 'Should contain user name');
        System.assert(csvContent.contains('IT'), 'Should contain department');
        System.assert(csvContent.contains('Test Developer'), 'Should contain title');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testCsvEscaping() {
        // This test would verify CSV escaping functionality
        // Since the escapeCsvValue method is private, we test it indirectly
        
        User testUser = [SELECT Id FROM User WHERE Username = 'exporttest@useracccess.test' LIMIT 1];
        
        // Update user with special characters
        testUser.Department = 'IT "Special" Department';
        update testUser;
        
        Test.startTest();
        
        String exportContent = UserAccessExportHelper.generateExcelExport(testUser.Id);
        Blob decodedBlob = EncodingUtil.base64Decode(exportContent);
        String csvContent = decodedBlob.toString();
        
        // Verify CSV escaping works correctly
        System.assert(csvContent.contains('IT ""Special"" Department'), 
                     'Should properly escape quotes in CSV');
        
        Test.stopTest();
    }
}
