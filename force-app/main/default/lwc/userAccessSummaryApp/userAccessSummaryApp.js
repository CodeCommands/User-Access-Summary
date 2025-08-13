import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import sheetjs from '@salesforce/resourceUrl/sheetjs';
import getUsers from '@salesforce/apex/UserAccessSummaryController.getUsers';
import getProfiles from '@salesforce/apex/UserAccessSummaryController.getProfiles';
import getUserDetails from '@salesforce/apex/UserAccessSummaryController.getUserDetails';
import getUserPermissionSets from '@salesforce/apex/UserAccessSummaryController.getUserPermissionSets';
import getUserObjectPermissions from '@salesforce/apex/UserAccessSummaryController.getUserObjectPermissions';
import getUserFieldPermissions from '@salesforce/apex/UserAccessSummaryController.getUserFieldPermissions';
import getUserFieldPermissionsLimited from '@salesforce/apex/UserAccessSummaryController.getUserFieldPermissionsLimited';
import getObjectFieldPermissions from '@salesforce/apex/UserAccessSummaryController.getObjectFieldPermissions';
import getAvailableObjects from '@salesforce/apex/UserAccessSummaryController.getAvailableObjects';
import getUserTabs from '@salesforce/apex/UserAccessSummaryController.getUserTabs';
import getUserConnectedApps from '@salesforce/apex/UserAccessSummaryController.getUserConnectedApps';

export default class UserAccessSummaryApp extends LightningElement {
    @track users = [];
    @track profiles = [];
    @track selectedUser = null;
    @track userDetails = null;
    @track permissionSets = [];
    @track objectPermissions = [];
    @track fieldPermissions = [];
    @track availableObjects = [];
    @track selectedObject = '';
    @track objectFieldPermissions = [];
    @track tabs = [];
    @track connectedApps = [];
    
    @track searchTerm = '';
    @track selectedProfiles = [];
    @track includeInactive = true;
    @track isLoading = false;
    @track showUserDetails = false;
    @track activeTab = 'userPermissions';
    
    // Pagination
    @track currentPage = 1;
    @track pageSize = 50;
    @track totalUsers = 0;
    
    // SheetJS library loaded flag
    xlsxLoaded = false;
    
    // Tab options
    tabOptions = [
        { label: 'User Permissions', value: 'userPermissions' },
        { label: 'Object Permissions', value: 'objectPermissions' },
        { label: 'Field Permissions', value: 'fieldPermissions' },
        { label: 'Tabs', value: 'tabs' },
        { label: 'Connected Apps', value: 'connectedApps' }
    ];
    
    // Columns for user datatable
    userColumns = [
        { 
            label: 'Name', 
            fieldName: 'name', 
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'name' },
                name: 'selectUser',
                variant: 'base'
            }
        },
        { label: 'Username', fieldName: 'username', type: 'text' },
        { label: 'Email', fieldName: 'email', type: 'email' },
        { label: 'Profile', fieldName: 'profileName', type: 'text' },
        { 
            label: 'Status', 
            fieldName: 'isActive', 
            type: 'boolean',
            cellAttributes: {
                iconName: { fieldName: 'statusIcon' },
                iconVariant: { fieldName: 'statusVariant' }
            }
        },
        { 
            label: 'Last Login', 
            fieldName: 'lastLoginDate', 
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            }
        }
    ];
    
    // Columns for permission sets datatable
    permissionSetColumns = [
        { label: 'Label', fieldName: 'label', type: 'text' },
        { label: 'API Name', fieldName: 'name', type: 'text' },
        { label: 'Description', fieldName: 'description', type: 'text' },
        { label: 'Type', fieldName: 'type', type: 'text' },
        { label: 'Source', fieldName: 'source', type: 'text' }
    ];
    
    // Columns for object permissions datatable
    objectPermissionColumns = [
        { label: 'Object', fieldName: 'objectLabel', type: 'text' },
        { label: 'API Name', fieldName: 'objectName', type: 'text' },
        { label: 'Create', fieldName: 'canCreate', type: 'boolean' },
        { label: 'Read', fieldName: 'canRead', type: 'boolean' },
        { label: 'Edit', fieldName: 'canEdit', type: 'boolean' },
        { label: 'Delete', fieldName: 'canDelete', type: 'boolean' },
        { label: 'View All', fieldName: 'canViewAll', type: 'boolean' },
        { label: 'Modify All', fieldName: 'canModifyAll', type: 'boolean' }
    ];
    
    // Columns for field permissions datatable
    fieldPermissionColumns = [
        { label: 'Field API Name', fieldName: 'fieldName', type: 'text', cellAttributes: { class: 'slds-text-body_small' } },
        { label: 'Read Access', fieldName: 'hasRead', type: 'boolean' },
        { label: 'Edit Access', fieldName: 'hasEdit', type: 'boolean' },
        { label: 'Permission Source', fieldName: 'permissionSetName', type: 'text', cellAttributes: { class: 'slds-text-body_small' } }
    ];

    // Columns for general field permissions that include object name
    generalFieldPermissionColumns = [
        { label: 'Object', fieldName: 'objectName', type: 'text' },
        { label: 'Field API Name', fieldName: 'fieldName', type: 'text', cellAttributes: { class: 'slds-text-body_small' } },
        { label: 'Read Access', fieldName: 'hasRead', type: 'boolean' },
        { label: 'Edit Access', fieldName: 'hasEdit', type: 'boolean' },
        { label: 'Permission Source', fieldName: 'permissionSetName', type: 'text', cellAttributes: { class: 'slds-text-body_small' } }
    ];
    
    get objectOptions() {
        const options = [];
        
        // Get unique objects from object permissions (these are the objects the user actually has access to)
        if (this.objectPermissions && this.objectPermissions.length > 0) {
            const uniqueObjects = new Set();
            this.objectPermissions.forEach(perm => {
                if (perm.objectName && !uniqueObjects.has(perm.objectName)) {
                    uniqueObjects.add(perm.objectName);
                    options.push({ 
                        label: perm.objectLabel || perm.objectName, 
                        value: perm.objectName 
                    });
                }
            });
            
            // Sort alphabetically by label
            options.sort((a, b) => a.label.localeCompare(b.label));
        }
        
        // Fallback to availableObjects if no object permissions found
        if (options.length === 0 && this.availableObjects) {
            this.availableObjects.forEach(obj => {
                options.push({ label: obj.label, value: obj.apiName });
            });
        }
        
        return options;
    }

    get hasObjectFieldPermissions() {
        return this.objectFieldPermissions && this.objectFieldPermissions.length > 0;
    }
    
    // Columns for tabs datatable
    tabColumns = [
        { label: 'Tab Label', fieldName: 'tabLabel', type: 'text' },
        { label: 'API Name', fieldName: 'tabName', type: 'text' },
        { label: 'Visibility', fieldName: 'visibility', type: 'text' },
        { label: 'Available', fieldName: 'isAvailable', type: 'boolean' },
        { label: 'Type', fieldName: 'tabType', type: 'text' }
    ];
    
    // Columns for connected apps datatable
    connectedAppColumns = [
        { label: 'App Name', fieldName: 'name', type: 'text' },
        { label: 'Description', fieldName: 'description', type: 'text' },
        { label: 'Access Type', fieldName: 'accessType', type: 'text' }
    ];
    
    connectedCallback() {
        this.loadProfiles();
        this.loadUsers();
        this.loadSheetJS();
    }
    
    async loadSheetJS() {
        try {
            // Load SheetJS from static resource following official documentation
            await loadScript(this, sheetjs);
            
            // Verify XLSX global is available
            if (typeof window.XLSX !== 'undefined') {
                this.xlsxLoaded = true;
                console.log('SheetJS library loaded successfully from static resource. Version:', window.XLSX.version);
                
                // Show info about Lightning Web Security performance if detected
                this.showToast('Info', 
                    `Excel export ready! SheetJS ${window.XLSX.version} loaded. ` +
                    'Note: Lightning Web Security may cause slower exports.', 'info');
            } else {
                throw new Error('XLSX global not available after loading script');
            }
        } catch (error) {
            console.error('Error loading SheetJS:', error);
            this.xlsxLoaded = false;
            
            this.showToast('Warning', 
                'Excel library could not be loaded. Export will use CSV format instead. ' +
                'Check static resource configuration.', 'warning');
        }
    }
    
    @wire(getProfiles)
    wiredProfiles({ error, data }) {
        if (data) {
            this.profiles = [
                { label: 'All Profiles', value: '' },
                ...data.map(profile => ({
                    label: profile.label,
                    value: profile.value
                }))
            ];
        } else if (error) {
            this.showToast('Error', 'Error loading profiles: ' + error.body.message, 'error');
        }
    }
    
    async loadProfiles() {
        try {
            const data = await getProfiles();
            this.profiles = [
                { label: 'All Profiles', value: '' },
                ...data.map(profile => ({
                    label: profile.label,
                    value: profile.value
                }))
            ];
        } catch (error) {
            this.showToast('Error', 'Error loading profiles: ' + error.body.message, 'error');
        }
    }
    
    async loadUsers() {
        this.isLoading = true;
        try {
            const offset = (this.currentPage - 1) * this.pageSize;
            const profileIds = this.selectedProfiles.length > 0 ? this.selectedProfiles : null;
            
            console.log('Loading users with params:', { // Debug log
                searchTerm: this.searchTerm,
                profileIds: profileIds,
                includeInactive: this.includeInactive,
                limitSize: this.pageSize,
                offset: offset
            });
            
            const data = await getUsers({
                searchTerm: this.searchTerm,
                profileIds: profileIds,
                includeInactive: this.includeInactive,
                limitSize: this.pageSize,
                offset: offset
            });
            
            console.log('Users loaded:', data.length); // Debug log
            
            this.users = data.map(user => ({
                ...user,
                statusIcon: user.isActive ? 'utility:success' : 'utility:error',
                statusVariant: user.isActive ? 'success' : 'error'
            }));
            
        } catch (error) {
            console.error('Error loading users:', error); // Debug log
            this.showToast('Error', 'Error loading users: ' + (error.body?.message || error.message), 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        console.log('Search term changed:', this.searchTerm); // Debug log
        this.debounceSearch();
    }
    
    debounceSearch() {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            console.log('Executing search with term:', this.searchTerm); // Debug log
            this.currentPage = 1;
            this.loadUsers();
        }, 500);
    }
    
    handleProfileChange(event) {
        this.selectedProfiles = event.detail.value;
        this.currentPage = 1;
        this.loadUsers();
    }
    
    handleIncludeInactiveChange(event) {
        this.includeInactive = event.target.checked;
        this.currentPage = 1;
        this.loadUsers();
    }
    
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'selectUser') {
            this.selectUser(row.id);
        }
    }
    
    async selectUser(userId) {
        this.isLoading = true;
        this.selectedUser = userId;
        
        try {
            // Load user details first
            await this.loadUserDetails(userId);
            
            // Load permissions sequentially to avoid CPU timeout
            await this.loadPermissionSets(userId);
            await this.loadObjectPermissions(userId);
            
            // Load field permissions last (most expensive) with a small delay
            setTimeout(async () => {
                try {
                    await this.loadFieldPermissions(userId);
                } catch (error) {
                    console.error('Error loading field permissions:', error);
                    
                    // Check if it's specifically a system limits error
                    const errorMessage = error.body?.message || error.message || '';
                    if (errorMessage.includes('system limits')) {
                        this.showToast('Warning', 
                            'Field permissions could not be loaded due to system limits. ' + 
                            'This user may have too many permission sets assigned. ' +
                            'Other data is still available for analysis.', 'warning');
                    } else {
                        this.showToast('Warning', 'Field permissions could not be loaded: ' + errorMessage, 'warning');
                    }
                }
            }, 200); // Increased delay to let other operations complete first
            
            // Load tabs and connected apps (lightweight)
            await this.loadTabs(userId);
            await this.loadConnectedApps(userId);
            
            // Load available objects for field permissions
            await this.loadAvailableObjects();
            
            this.showUserDetails = true;
        } catch (error) {
            this.showToast('Error', 'Error loading user details: ' + (error.body?.message || error.message), 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    async loadUserDetails(userId) {
        this.userDetails = await getUserDetails({ userId });
    }
    
    async loadPermissionSets(userId) {
        this.permissionSets = await getUserPermissionSets({ userId });
    }
    
    async loadObjectPermissions(userId) {
        this.objectPermissions = await getUserObjectPermissions({ userId });
        
        // Auto-select the first object for field permissions (alphabetically sorted)
        if (this.objectPermissions && this.objectPermissions.length > 0) {
            // Create the same sorted list as objectOptions getter
            const uniqueObjects = new Set();
            const objectList = [];
            
            this.objectPermissions.forEach(perm => {
                if (perm.objectName && !uniqueObjects.has(perm.objectName)) {
                    uniqueObjects.add(perm.objectName);
                    objectList.push({ 
                        label: perm.objectLabel || perm.objectName, 
                        value: perm.objectName 
                    });
                }
            });
            
            // Sort alphabetically by label (same as objectOptions)
            objectList.sort((a, b) => a.label.localeCompare(b.label));
            
            // Select the first object from sorted list
            if (objectList.length > 0 && !this.selectedObject) {
                const firstObject = objectList[0].value;
                console.log('Auto-selecting first object alphabetically:', firstObject, '(', objectList[0].label, ')');
                this.selectedObject = firstObject;
                // Load field permissions for the auto-selected object with the correct userId
                await this.loadObjectFieldPermissions(userId);
            }
        }
    }
    
    async loadFieldPermissions(userId) {
        try {
            // Use limited version for display to avoid system limits
            this.fieldPermissions = await getUserFieldPermissionsLimited({ userId });
            console.log('Loaded limited field permissions for display:', this.fieldPermissions.length);
            
            // Show info about what was loaded if it's a small number (indicating limits were hit)
            if (this.fieldPermissions.length > 0 && this.fieldPermissions.length < 50) {
                this.showToast('Info', 
                    `Loaded ${this.fieldPermissions.length} field permissions (limited due to system constraints). ` +
                    'Export may include more comprehensive data.', 'info');
            }
        } catch (error) {
            console.error('Field permissions loading error:', error);
            // Set empty array so UI doesn't break
            this.fieldPermissions = [];
            
            // Check if it's the specific system limits error
            const errorMessage = error.body?.message || error.message || '';
            if (errorMessage.includes('system limits') || 
                errorMessage.includes('CPU time limit') ||
                errorMessage.includes('Maximum CPU time')) {
                throw new Error('Field permissions could not be loaded due to system limits');
            } else {
                throw error;
            }
        }
    }

    async loadFullFieldPermissionsForExport(userId) {
        try {
            // Use full cursor-based version for export
            console.log('Loading full field permissions for export...');
            const fullFieldPermissions = await getUserFieldPermissions({ userId });
            console.log('Loaded full field permissions for export:', fullFieldPermissions.length);
            return fullFieldPermissions || [];
        } catch (error) {
            console.error('Full field permissions loading error:', error);
            // Return limited version as fallback
            console.log('Falling back to limited field permissions for export');
            const fallbackData = this.fieldPermissions || [];
            console.log('Fallback field permissions count:', fallbackData.length);
            return fallbackData;
        }
    }

    async loadFieldPermissionsForAllObjects() {
        try {
            console.log('Loading field permissions for all objects in object permissions...');
            
            // Get unique objects from object permissions
            const uniqueObjects = new Set();
            this.objectPermissions.forEach(perm => {
                if (perm.objectName) {
                    uniqueObjects.add(perm.objectName);
                }
            });
            
            console.log('Found objects to load field permissions for:', Array.from(uniqueObjects));
            
            // Load field permissions for each object
            const allFieldPermissions = [];
            for (const objectName of uniqueObjects) {
                try {
                    console.log(`Loading field permissions for object: ${objectName}`);
                    const objectFieldPerms = await getObjectFieldPermissions({ 
                        userId: this.selectedUser.id,
                        objectApiName: objectName 
                    });
                    
                    if (objectFieldPerms && objectFieldPerms.length > 0) {
                        allFieldPermissions.push(...objectFieldPerms);
                        console.log(`Loaded ${objectFieldPerms.length} field permissions for ${objectName}`);
                    } else {
                        console.log(`No field permissions found for ${objectName}`);
                    }
                } catch (error) {
                    console.error(`Error loading field permissions for ${objectName}:`, error);
                    // Continue with other objects even if one fails
                }
            }
            
            console.log(`Total field permissions loaded for all objects: ${allFieldPermissions.length}`);
            return allFieldPermissions;
            
        } catch (error) {
            console.error('Error loading field permissions for all objects:', error);
            // Fallback to general field permissions
            return this.fieldPermissions || [];
        }
    }
    
    async loadAvailableObjects() {
        try {
            this.availableObjects = await getAvailableObjects();
            console.log('Loaded available objects:', this.availableObjects.length);
        } catch (error) {
            console.error('Error loading available objects:', error);
            this.availableObjects = [];
        }
    }

    async handleObjectSelection(event) {
        this.selectedObject = event.detail.value;
        console.log('Object selected:', this.selectedObject);
        console.log('Selected user available:', !!this.selectedUser);
        console.log('Selected user details:', this.selectedUser);
        
        // Clear existing data first
        this.objectFieldPermissions = [];
        
        if (!this.selectedObject) {
            console.log('No object selected - cleared field permissions');
            return;
        }
        
        if (!this.selectedUser) {
            console.error('No user selected:', this.selectedUser);
            this.showToast('Error', 'No user selected for field permissions', 'error');
            return;
        }
        
        // Handle both cases: selectedUser as object with id property, or selectedUser as ID string
        let userId;
        if (typeof this.selectedUser === 'string') {
            // selectedUser is the ID string directly
            userId = this.selectedUser;
            console.log('Selected user is ID string:', userId);
        } else if (this.selectedUser && typeof this.selectedUser === 'object') {
            // selectedUser is an object, extract ID
            userId = this.selectedUser.id || this.selectedUser.userId || this.selectedUser.Id;
            console.log('Selected user is object, extracted ID:', userId);
        }
        
        if (!userId) {
            console.error('Could not resolve user ID from:', this.selectedUser);
            this.showToast('Error', 'Could not determine user ID', 'error');
            return;
        }
        
        // If we get here, we have both object and user ID
        console.log('Loading field permissions for object:', this.selectedObject, 'user ID:', userId);
        try {
            await this.loadObjectFieldPermissions(userId);
        } catch (error) {
            console.error('Error in handleObjectSelection:', error);
            this.showToast('Error', 'Failed to load field permissions: ' + error.message, 'error');
        }
    }

    async loadObjectFieldPermissions(userId = null) {
        try {
            this.isLoading = true;
            
            // Clear existing data immediately when starting to load new object
            this.objectFieldPermissions = [];
            
            console.log('Starting to load field permissions for:', this.selectedObject);
            
            // Use provided userId or fallback to selectedUser.id
            const userIdToUse = userId || (this.selectedUser && this.selectedUser.id);
            console.log('User ID to use:', userIdToUse);
            console.log('Provided userId:', userId);
            console.log('selectedUser.id:', this.selectedUser && this.selectedUser.id);
            
            if (!userIdToUse) {
                console.error('No user ID available for field permissions');
                this.showToast('Error', 'No user selected for field permissions', 'error');
                this.objectFieldPermissions = [];
                return;
            }
            
            if (!this.selectedObject) {
                console.error('No object selected for field permissions');
                this.showToast('Error', 'No object selected for field permissions', 'error');
                this.objectFieldPermissions = [];
                return;
            }
            
            console.log('Calling getObjectFieldPermissions with userId:', userIdToUse, 'objectApiName:', this.selectedObject);
            
            const fieldPermissionsResult = await getObjectFieldPermissions({ 
                userId: userIdToUse, 
                objectApiName: this.selectedObject 
            });
            
            // Always update the data, even if empty
            this.objectFieldPermissions = fieldPermissionsResult || [];
            
            console.log(`Loaded field permissions for ${this.selectedObject}:`, this.objectFieldPermissions.length);
            if (this.objectFieldPermissions.length > 0) {
                console.log('Sample field permission data:', this.objectFieldPermissions[0]);
                console.log('All field permissions data:', this.objectFieldPermissions);
                this.showToast('Success', `Loaded ${this.objectFieldPermissions.length} field permissions for ${this.selectedObject}`, 'success');
            } else {
                console.log('No field permissions returned from Apex method - this may be normal for objects with only profile access');
                // Don't show error toast for empty results - this is often normal
            }
            
        } catch (error) {
            console.error('Error loading object field permissions:', error);
            this.showToast('Error', 'Error loading field permissions for object: ' + error.message, 'error');
            this.objectFieldPermissions = [];
        } finally {
            this.isLoading = false;
        }
    }
    
    async loadTabs(userId) {
        this.tabs = await getUserTabs({ userId });
    }
    
    async loadConnectedApps(userId) {
        this.connectedApps = await getUserConnectedApps({ userId });
    }
    
    handleTabChange(event) {
        this.activeTab = event.target.value;
    }
    
    handleBackToUsers() {
        this.showUserDetails = false;
        this.selectedUser = null;
        this.userDetails = null;
        this.activeTab = 'userPermissions';
    }
    
    async handleExportToExcel() {
        if (!this.selectedUser) {
            this.showToast('Warning', 'Please select a user first', 'warning');
            return;
        }
        
        try {
            this.isLoading = true;
            
            if (this.xlsxLoaded && window.XLSX) {
                // Use SheetJS for true Excel export with multiple sheets
                this.generateExcelWithSheetJS();
            } else {
                // Fallback to CSV export
                this.showToast('Info', 'Excel library not loaded, exporting as CSV files...', 'info');
                this.generateMultiSheetExcelExport();
            }
            
        } catch (error) {
            this.showToast('Error', 'Error exporting file: ' + error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async generateExcelWithSheetJS() {
        try {
            this.showToast('Info', 'Preparing Excel export with comprehensive field permissions...', 'info');
            
            // Load field permissions for ALL objects in object permissions
            let exportFieldPermissions = [];
            
            if (this.objectPermissions && this.objectPermissions.length > 0) {
                console.log('Loading field permissions for all objects...');
                exportFieldPermissions = await this.loadFieldPermissionsForAllObjects();
                console.log('Loaded field permissions for all objects:', exportFieldPermissions.length);
            } 
            // Fallback to current UI data if no object permissions
            else if (this.fieldPermissions && this.fieldPermissions.length > 0) {
                exportFieldPermissions = [...this.fieldPermissions];
                console.log('Using general field permissions for export:', exportFieldPermissions.length);
            }
            // Last resort: try to load fresh data
            else {
                try {
                    exportFieldPermissions = await this.loadFullFieldPermissionsForExport(this.selectedUser.id);
                    console.log('Loaded fresh field permissions for export:', exportFieldPermissions.length);
                } catch (error) {
                    console.log('Fresh load failed, using empty array for export');
                    exportFieldPermissions = [];
                }
            }
            
            console.log('Final field permissions for export:', exportFieldPermissions.length);
            
            // Create a new workbook
            const workbook = window.XLSX.utils.book_new();
            
            // Generate all sheets data with the comprehensive field permissions
            const sheets = this.generateAllSheetsWithFullData(exportFieldPermissions);
            console.log('Generated sheets:', sheets.map(s => s.name));
            
            // Add each sheet to the workbook using SheetJS best practices
            sheets.forEach(sheet => {
                console.log(`Adding sheet "${sheet.name}" with ${sheet.data.length} rows`);
                // Use aoa_to_sheet as recommended by SheetJS for array-of-arrays
                const worksheet = window.XLSX.utils.aoa_to_sheet(sheet.data);
                window.XLSX.utils.book_append_sheet(workbook, worksheet, sheet.name);
            });
            
            // Use XLSX.writeFile as recommended by SheetJS documentation
            const filename = `User_Access_Summary_${this.selectedUser.name}_${new Date().toISOString().split('T')[0]}.xlsx`;
            window.XLSX.writeFile(workbook, filename);
            
            this.showToast('Success', 'Excel file exported successfully with comprehensive field permissions!', 'success');
            
        } catch (error) {
            console.error('Error generating Excel file:', error);
            
            // Check if it's a Lightning Web Security performance issue
            if (error.message && error.message.includes('performance')) {
                this.showToast('Warning', 
                    'Excel export may be slow due to Lightning Web Security. ' + 
                    'Consider disabling LWS in Session Settings for better performance.', 'warning');
            } else {
                this.showToast('Error', 'Error generating Excel file: ' + error.message, 'error');
            }
        }
    }
    
    generateCSVAsExcel() {
        // Create multiple CSV files as a ZIP (Excel-like experience)
        // For true Excel with multiple sheets, we'll create separate downloadable files
        this.generateMultiSheetExcelExport();
    }
    
    generateMultiSheetExcelExport() {
        try {
            // Generate all sheets as separate CSV files
            const sheets = this.generateAllSheets();
            
            // Create a more Excel-like experience by generating multiple files
            // In a real Excel implementation, these would be sheets in one workbook
            this.downloadMultipleFiles(sheets);
            
        } catch (error) {
            console.error('Error generating Excel export:', error);
            this.showToast('Error', 'Error generating Excel files: ' + error.message, 'error');
        }
    }
    
    generateAllSheets() {
        const baseFileName = `UserAccessSummary_${this.userDetails.username}_${new Date().toISOString().split('T')[0]}`;
        const sheets = [];
        
        // Sheet 1: User Summary
        sheets.push({
            name: 'User Summary',
            data: this.generateUserSummaryData(),
            content: this.generateUserSummarySheet(),
            fileName: `${baseFileName}_1_User_Summary.csv`
        });
        
        // Sheet 2: Permission Sets  
        if (this.permissionSets && this.permissionSets.length > 0) {
            sheets.push({
                name: 'Permission Sets',
                data: this.generatePermissionSetsData(),
                content: this.generatePermissionSetsSheet(),
                fileName: `${baseFileName}_2_Permission_Sets.csv`
            });
        }
        
        // Sheet 3: Object Permissions
        if (this.objectPermissions && this.objectPermissions.length > 0) {
            sheets.push({
                name: 'Object Permissions',
                data: this.generateObjectPermissionsData(),
                content: this.generateObjectPermissionsSheet(),
                fileName: `${baseFileName}_3_Object_Permissions.csv`
            });
        }
        
        // Sheet 4: Field Permissions (Limited for display)
        if (this.fieldPermissions && this.fieldPermissions.length > 0) {
            sheets.push({
                name: 'Field Permissions',
                data: this.generateFieldPermissionsData(this.fieldPermissions),
                content: this.generateFieldPermissionsSheet(),
                fileName: `${baseFileName}_4_Field_Permissions.csv`
            });
        }
        
        // Sheet 5: Tabs and Apps
        if ((this.tabs && this.tabs.length > 0) || (this.connectedApps && this.connectedApps.length > 0)) {
            sheets.push({
                name: 'Tabs and Apps',
                data: this.generateTabsAndAppsData(),
                content: this.generateTabsAndAppsSheet(),
                fileName: `${baseFileName}_5_Tabs_and_Apps.csv`
            });
        }
        
        return sheets;
    }

    generateAllSheetsWithFullData(fullFieldPermissions) {
        const sheets = [];
        
        // Sheet 1: User Summary
        sheets.push({
            name: 'User Summary',
            data: this.generateUserSummaryData()
        });
        
        // Sheet 2: Permission Sets  
        if (this.permissionSets && this.permissionSets.length > 0) {
            sheets.push({
                name: 'Permission Sets',
                data: this.generatePermissionSetsData()
            });
        }
        
        // Sheet 3: Object Permissions
        if (this.objectPermissions && this.objectPermissions.length > 0) {
            sheets.push({
                name: 'Object Permissions',
                data: this.generateObjectPermissionsData()
            });
        }
        
        // Sheet 4: Field Permissions (Always include, even if empty)
        sheets.push({
            name: 'Field Permissions',
            data: this.generateFieldPermissionsData(fullFieldPermissions)
        });
        
        // Sheet 5: Tabs and Apps
        if ((this.tabs && this.tabs.length > 0) || (this.connectedApps && this.connectedApps.length > 0)) {
            sheets.push({
                name: 'Tabs and Apps',
                data: this.generateTabsAndAppsData()
            });
        }
        
        return sheets;
    }
    
    generateUserSummaryData() {
        const data = [];
        
        // Header section
        data.push(['USER ACCESS SUMMARY REPORT']);
        data.push([`Generated on: ${new Date().toLocaleString()}`]);
        data.push(['']);
        
        // Basic Information
        data.push(['BASIC INFORMATION']);
        data.push(['Field', 'Value']);
        data.push(['Full Name', this.userDetails.name || '']);
        data.push(['Username', this.userDetails.username || '']);
        data.push(['Email', this.userDetails.email || '']);
        data.push(['Profile', this.userDetails.profileName || '']);
        data.push(['Role', this.userDetails.roleName || '']);
        data.push(['User Type', this.userDetails.userType || '']);
        data.push(['Is Active', this.userDetails.isActive ? 'Yes' : 'No']);
        data.push(['Last Login', this.userDetails.lastLoginDate || 'Never']);
        data.push(['Created Date', this.userDetails.createdDate || '']);
        data.push(['Department', this.userDetails.department || '']);
        data.push(['Division', this.userDetails.division || '']);
        data.push(['Manager', this.userDetails.managerName || '']);
        
        return data;
    }
    
    generatePermissionSetsData() {
        const data = [];
        
        // Header
        data.push(['PERMISSION SETS']);
        data.push(['Permission Set Name', 'Label', 'Description', 'Type']);
        
        // Permission sets data
        this.permissionSets.forEach(ps => {
            data.push([
                ps.name || '',
                ps.label || '',
                ps.description || '',
                ps.type || ''
            ]);
        });
        
        return data;
    }
    
    generateObjectPermissionsData() {
        const data = [];
        
        // Header
        data.push(['OBJECT PERMISSIONS']);
        data.push(['Object Name', 'Read', 'Create', 'Edit', 'Delete', 'View All', 'Modify All']);
        
        // Object permissions data
        this.objectPermissions.forEach(obj => {
            data.push([
                obj.objectName || '',
                obj.hasRead ? 'Yes' : 'No',
                obj.hasCreate ? 'Yes' : 'No',
                obj.hasEdit ? 'Yes' : 'No',
                obj.hasDelete ? 'Yes' : 'No',
                obj.hasViewAll ? 'Yes' : 'No',
                obj.hasModifyAll ? 'Yes' : 'No'
            ]);
        });
        
        return data;
    }
    
    generateFieldPermissionsData(fieldPermissionsArray = null) {
        const data = [];
        
        // Header
        data.push(['FIELD PERMISSIONS SUMMARY']);
        data.push(['Shows field-level access permissions for each object']);
        data.push(['']);
        data.push(['Object Name', 'Field Name', 'Read Access', 'Edit Access', 'Permission Source']);
        
        // Use the comprehensive field permissions loaded for all objects
        if (fieldPermissionsArray && fieldPermissionsArray.length > 0) {
            console.log('Exporting field permissions for all objects:', fieldPermissionsArray.length);
            
            // Group permissions by object
            const groupedByObject = {};
            fieldPermissionsArray.forEach(field => {
                const objectName = field.objectName || 'Unknown';
                if (!groupedByObject[objectName]) {
                    groupedByObject[objectName] = [];
                }
                groupedByObject[objectName].push(field);
            });
            
            // Sort objects alphabetically and add their field permissions
            Object.keys(groupedByObject).sort().forEach(objectName => {
                // Add object header
                data.push([`${objectName} Object`, '', '', '', '']);
                
                // Sort fields within object
                groupedByObject[objectName].sort((a, b) => 
                    (a.fieldName || '').localeCompare(b.fieldName || '')
                );
                
                // Add fields for this object
                groupedByObject[objectName].forEach(field => {
                    data.push([
                        objectName,
                        field.fieldName || '',
                        (field.hasRead !== undefined ? field.hasRead : field.canRead) ? 'Yes' : 'No',
                        (field.hasEdit !== undefined ? field.hasEdit : field.canEdit) ? 'Yes' : 'No',
                        field.permissionSetName || field.source || 'Profile Access'
                    ]);
                });
                
                // Add spacing between objects
                data.push(['', '', '', '', '']);
            });
        } else {
            // Fallback: show currently selected object if no comprehensive data
            if (this.objectFieldPermissions && this.objectFieldPermissions.length > 0) {
                data.push([`${this.selectedObject} Object (Current Selection)`, '', '', '', '']);
                
                const sortedFields = [...this.objectFieldPermissions].sort((a, b) => 
                    (a.fieldName || '').localeCompare(b.fieldName || '')
                );
                
                sortedFields.forEach(field => {
                    data.push([
                        field.objectName || this.selectedObject || '',
                        field.fieldName || '',
                        (field.hasRead !== undefined ? field.hasRead : field.canRead) ? 'Yes' : 'No',
                        (field.hasEdit !== undefined ? field.hasEdit : field.canEdit) ? 'Yes' : 'No',
                        field.permissionSetName || field.source || 'Profile Access'
                    ]);
                });
            } else {
                data.push(['No field permissions data available', '', '', '', '']);
                data.push(['This may indicate that field access comes from the user profile', '', '', '', '']);
                data.push(['rather than explicit permission set field permissions.', '', '', '', '']);
            }
        }
        
        return data;
    }
                
                // Sort fields within object
                groupedByObject[objectName].sort((a, b) => a.fieldName.localeCompare(b.fieldName));
                
                // Add fields for this object
                groupedByObject[objectName].forEach(field => {
                    data.push([
                        field.objectName,
                        field.fieldName,
                        field.hasRead ? 'Yes' : 'No',
                        field.hasEdit ? 'Yes' : 'No',
                        field.permissionSources.join(', ')
                    ]);
                });
                
                // Add spacing between objects
                data.push(['', '', '', '', '']);
            });
        }
        
        if (data.length <= 3) { // Only headers, no actual data
            data.push(['No field permissions data available due to system limits.']);
            data.push(['']);
            data.push(['Note: Field permissions are limited to prevent CPU timeouts.']);
            data.push(['For complete field access analysis, use Salesforce Setup > Field-Level Security.']);
            data.push(['Or select specific objects in the Field Permissions tab above.']);
        }
        
        return data;
    }
    
    generateTabsAndAppsData() {
        const data = [];
        
        // Header
        data.push(['TABS AND APPLICATIONS']);
        data.push(['']);
        
        // Tabs section
        if (this.tabs && this.tabs.length > 0) {
            data.push(['AVAILABLE TABS']);
            data.push(['Tab Name', 'Label', 'Is Standard']);
            
            this.tabs.forEach(tab => {
                data.push([
                    tab.name || '',
                    tab.label || '',
                    tab.isStandard ? 'Yes' : 'No'
                ]);
            });
            
            data.push(['']);
        }
        
        // Connected Apps section
        if (this.connectedApps && this.connectedApps.length > 0) {
            data.push(['CONNECTED APPLICATIONS']);
            data.push(['App Name', 'Description']);
            
            this.connectedApps.forEach(app => {
                data.push([
                    app.name || '',
                    app.description || ''
                ]);
            });
        }
        
        return data;
    }
    
    generateUserSummarySheet() {
        let content = '\uFEFF'; // UTF-8 BOM
        
        content += 'USER ACCESS SUMMARY REPORT\n';
        content += `Generated on: ${new Date().toLocaleString()}\n`;
        content += `Report for: ${this.userDetails.name} (${this.userDetails.username})\n\n`;
        
        content += 'USER INFORMATION\n';
        content += 'Field,Value\n';
        content += `Name,"${this.escapeCSV(this.userDetails.name)}"\n`;
        content += `Username,"${this.escapeCSV(this.userDetails.username)}"\n`;
        content += `Email,"${this.escapeCSV(this.userDetails.email)}"\n`;
        content += `Profile,"${this.escapeCSV(this.userDetails.profileName)}"\n`;
        content += `Status,"${this.userDetails.isActive ? 'Active' : 'Inactive'}"\n`;
        content += `Last Login,"${this.userDetails.lastLoginDate || 'Never'}"\n`;
        content += `Department,"${this.escapeCSV(this.userDetails.department || 'Not specified')}"\n`;
        content += `Title,"${this.escapeCSV(this.userDetails.title || 'Not specified')}"\n`;
        content += `Manager,"${this.escapeCSV(this.userDetails.managerName || 'Not specified')}"\n`;
        content += `Created Date,"${this.userDetails.createdDate || 'Not available'}"\n\n`;
        
        // Summary Statistics
        content += 'SUMMARY STATISTICS\n';
        content += 'Metric,Count\n';
        content += `Permission Sets,${this.permissionSets ? this.permissionSets.length : 0}\n`;
        content += `Object Permissions,${this.objectPermissions ? this.objectPermissions.length : 0}\n`;
        content += `Field Permissions,${this.fieldPermissions ? this.fieldPermissions.length : 0}\n`;
        content += `Available Tabs,${this.tabs ? this.tabs.length : 0}\n`;
        content += `Connected Apps,${this.connectedApps ? this.connectedApps.length : 0}\n`;
        
        return content;
    }
    
    generatePermissionSetsSheet() {
        let content = '\uFEFF'; // UTF-8 BOM
        
        content += 'PERMISSION SETS SUMMARY\n';
        content += `User: ${this.userDetails.name} (${this.userDetails.username})\n`;
        content += `Generated: ${new Date().toLocaleString()}\n\n`;
        
        content += 'Label,API Name,Description,Type,Is Profile,Assigned Via\n';
        
        this.permissionSets.forEach(ps => {
            content += `"${this.escapeCSV(ps.label || '')}",`;
            content += `"${this.escapeCSV(ps.name || '')}",`;
            content += `"${this.escapeCSV(ps.description || 'No description')}",`;
            content += `"${this.escapeCSV(ps.type || '')}",`;
            content += `"${ps.isOwnedByProfile ? 'Yes' : 'No'}",`;
            content += `"${this.escapeCSV(ps.source || 'Direct Assignment')}"\n`;
        });
        
        return content;
    }
    
    generateObjectPermissionsSheet() {
        let content = '\uFEFF'; // UTF-8 BOM
        
        content += 'OBJECT PERMISSIONS SUMMARY\n';
        content += `User: ${this.userDetails.name} (${this.userDetails.username})\n`;
        content += `Generated: ${new Date().toLocaleString()}\n\n`;
        
        content += 'Object Label,Object API Name,Create,Read,Edit,Delete,View All Records,Modify All Records,Permission Set\n';
        
        this.objectPermissions.forEach(op => {
            content += `"${this.escapeCSV(op.objectLabel || op.objectName)}",`;
            content += `"${this.escapeCSV(op.objectName || '')}",`;
            content += `${op.canCreate ? 'Yes' : 'No'},`;
            content += `${op.canRead ? 'Yes' : 'No'},`;
            content += `${op.canEdit ? 'Yes' : 'No'},`;
            content += `${op.canDelete ? 'Yes' : 'No'},`;
            content += `${op.canViewAll ? 'Yes' : 'No'},`;
            content += `${op.canModifyAll ? 'Yes' : 'No'},`;
            content += `"${this.escapeCSV(op.source || 'Unknown')}"\n`;
        });
        
        return content;
    }
    
    generateFieldPermissionsSheet() {
        let content = '\uFEFF'; // UTF-8 BOM
        
        content += 'FIELD PERMISSIONS SUMMARY (ALL FIELDS)\n';
        content += `User: ${this.userDetails.name} (${this.userDetails.username})\n`;
        content += `Generated: ${new Date().toLocaleString()}\n`;
        content += `Total Field Permissions: ${this.fieldPermissions.length}\n\n`;
        
        content += 'Object Name,Field Name,Read Access,Edit Access,Permission Set\n';
        
        // Export ALL field permissions, not just top 100
        this.fieldPermissions.forEach(fp => {
            content += `"${this.escapeCSV(fp.objectName || '')}",`;
            content += `"${this.escapeCSV(fp.fieldName || '')}",`;
            content += `${fp.canRead ? 'Yes' : 'No'},`;
            content += `${fp.canEdit ? 'Yes' : 'No'},`;
            content += `"${this.escapeCSV(fp.source || 'Unknown')}"\n`;
        });
        
        return content;
    }
    
    generateTabsAndAppsSheet() {
        let content = '\uFEFF'; // UTF-8 BOM
        
        content += 'TABS AND CONNECTED APPS SUMMARY\n';
        content += `User: ${this.userDetails.name} (${this.userDetails.username})\n`;
        content += `Generated: ${new Date().toLocaleString()}\n\n`;
        
        // Tabs section
        if (this.tabs && this.tabs.length > 0) {
            content += 'AVAILABLE TABS\n';
            content += 'Tab Label,Tab Name,Visibility\n';
            
            this.tabs.forEach(tab => {
                content += `"${this.escapeCSV(tab.label || tab.name)}",`;
                content += `"${this.escapeCSV(tab.name || '')}",`;
                content += `"${this.escapeCSV(tab.visibility || 'Available')}"\n`;
            });
            
            content += '\n';
        }
        
        // Connected Apps section
        if (this.connectedApps && this.connectedApps.length > 0) {
            content += 'CONNECTED APPLICATIONS\n';
            content += 'App Name,App ID,Access Level\n';
            
            this.connectedApps.forEach(app => {
                content += `"${this.escapeCSV(app.name || '')}",`;
                content += `"${this.escapeCSV(app.id || '')}",`;
                content += `"${this.escapeCSV(app.accessLevel || 'Standard')}"\n`;
            });
        }
        
        return content;
    }
    
    async downloadMultipleFiles(sheets) {
        // Show user-friendly message about multiple file download
        this.showToast('Info', `Generating ${sheets.length} Excel files. Please allow multiple downloads.`, 'info');
        
        // Download each sheet as a separate CSV file with a small delay
        for (let i = 0; i < sheets.length; i++) {
            setTimeout(() => {
                this.downloadFile(sheets[i].content, sheets[i].fileName, 'text/csv');
                
                // Show completion message for last file
                if (i === sheets.length - 1) {
                    setTimeout(() => {
                        this.showToast('Success', 
                            `Excel export complete! ${sheets.length} files downloaded. You can combine them into one Excel workbook.`, 
                            'success');
                    }, 500);
                }
            }, i * 1000); // 1 second delay between downloads
        }
    }
    
    escapeCSV(str) {
        if (str == null) return '';
        return String(str).replace(/"/g, '""');
    }
    
    downloadFile(content, fileName, mimeType) {
        const element = document.createElement('a');
        element.setAttribute('href', `data:${mimeType};charset=utf-8,${encodeURIComponent(content)}`);
        element.setAttribute('download', fileName);
        element.style.display = 'none';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
    }
    
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadUsers();
        }
    }
    
    handleNextPage() {
        this.currentPage++;
        this.loadUsers();
    }
    
    get hasUsers() {
        return this.users && this.users.length > 0;
    }
    
    get hasPermissionSets() {
        return this.permissionSets && this.permissionSets.length > 0;
    }
    
    get hasObjectPermissions() {
        return this.objectPermissions && this.objectPermissions.length > 0;
    }
    
    get hasFieldPermissions() {
        return this.fieldPermissions && this.fieldPermissions.length > 0;
    }
    
    get hasTabs() {
        return this.tabs && this.tabs.length > 0;
    }
    
    get hasConnectedApps() {
        return this.connectedApps && this.connectedApps.length > 0;
    }
    
    get showUserPermissions() {
        return this.activeTab === 'userPermissions';
    }
    
    get showObjectPermissions() {
        return this.activeTab === 'objectPermissions';
    }
    
    get showFieldPermissions() {
        return this.activeTab === 'fieldPermissions';
    }
    
    get showTabs() {
        return this.activeTab === 'tabs';
    }
    
    get showConnectedApps() {
        return this.activeTab === 'connectedApps';
    }
    
    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }
    
    get pageInfo() {
        const start = (this.currentPage - 1) * this.pageSize + 1;
        const end = Math.min(this.currentPage * this.pageSize, this.totalUsers);
        return `Showing ${start}-${end} of ${this.totalUsers}`;
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
