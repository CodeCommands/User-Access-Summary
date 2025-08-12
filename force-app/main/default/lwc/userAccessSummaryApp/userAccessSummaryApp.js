import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUsers from '@salesforce/apex/UserAccessSummaryController.getUsers';
import getProfiles from '@salesforce/apex/UserAccessSummaryController.getProfiles';
import getUserDetails from '@salesforce/apex/UserAccessSummaryController.getUserDetails';
import getUserPermissionSets from '@salesforce/apex/UserAccessSummaryController.getUserPermissionSets';
import getUserObjectPermissions from '@salesforce/apex/UserAccessSummaryController.getUserObjectPermissions';
import getUserFieldPermissions from '@salesforce/apex/UserAccessSummaryController.getUserFieldPermissions';
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
        { label: 'Object', fieldName: 'objectLabel', type: 'text' },
        { label: 'Field', fieldName: 'fieldLabel', type: 'text' },
        { label: 'API Name', fieldName: 'fieldName', type: 'text' },
        { label: 'Read', fieldName: 'canRead', type: 'boolean' },
        { label: 'Edit', fieldName: 'canEdit', type: 'boolean' }
    ];
    
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
            
            const data = await getUsers({
                searchTerm: this.searchTerm,
                profileIds: profileIds,
                includeInactive: this.includeInactive,
                limitSize: this.pageSize,
                offset: offset
            });
            
            this.users = data.map(user => ({
                ...user,
                statusIcon: user.isActive ? 'utility:success' : 'utility:error',
                statusVariant: user.isActive ? 'success' : 'error'
            }));
            
        } catch (error) {
            this.showToast('Error', 'Error loading users: ' + error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.debounceSearch();
    }
    
    debounceSearch() {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
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
            // Load all user details and permissions
            await Promise.all([
                this.loadUserDetails(userId),
                this.loadPermissionSets(userId),
                this.loadObjectPermissions(userId),
                this.loadFieldPermissions(userId),
                this.loadTabs(userId),
                this.loadConnectedApps(userId)
            ]);
            
            this.showUserDetails = true;
        } catch (error) {
            this.showToast('Error', 'Error loading user details: ' + error.body.message, 'error');
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
    }
    
    async loadFieldPermissions(userId) {
        this.fieldPermissions = await getUserFieldPermissions({ userId });
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
            
            // Prepare data for export
            const exportData = {
                userDetails: this.userDetails,
                permissionSets: this.permissionSets,
                objectPermissions: this.objectPermissions,
                fieldPermissions: this.fieldPermissions,
                tabs: this.tabs,
                connectedApps: this.connectedApps
            };
            
            // Create and download Excel file
            await this.generateExcelFile(exportData);
            
            this.showToast('Success', 'Excel file exported successfully', 'success');
        } catch (error) {
            this.showToast('Error', 'Error exporting to Excel: ' + error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    async generateExcelFile(data) {
        // This is a simplified implementation
        // In a real scenario, you would use a library like SheetJS or similar
        const csvContent = this.convertToCSV(data);
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        const url = URL.createObjectURL(blob);
        
        link.setAttribute('href', url);
        link.setAttribute('download', `UserAccessSummary_${this.userDetails.username}_${new Date().toISOString().split('T')[0]}.csv`);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
    
    convertToCSV(data) {
        let csv = 'User Access Summary Report\n\n';
        
        // User Details
        csv += 'User Information\n';
        csv += `Name,${data.userDetails.name}\n`;
        csv += `Username,${data.userDetails.username}\n`;
        csv += `Email,${data.userDetails.email}\n`;
        csv += `Profile,${data.userDetails.profileName}\n`;
        csv += `Status,${data.userDetails.isActive ? 'Active' : 'Inactive'}\n`;
        csv += `Last Login,${data.userDetails.lastLoginDate || 'Never'}\n`;
        csv += '\n';
        
        // Permission Sets
        csv += 'Permission Sets\n';
        csv += 'Label,API Name,Description,Type,Source\n';
        data.permissionSets.forEach(ps => {
            csv += `"${ps.label}","${ps.name}","${ps.description || ''}","${ps.type}","${ps.source}"\n`;
        });
        csv += '\n';
        
        // Object Permissions
        csv += 'Object Permissions\n';
        csv += 'Object,API Name,Create,Read,Edit,Delete,View All,Modify All\n';
        data.objectPermissions.forEach(op => {
            csv += `"${op.objectLabel}","${op.objectName}",${op.canCreate},${op.canRead},${op.canEdit},${op.canDelete},${op.canViewAll},${op.canModifyAll}\n`;
        });
        
        return csv;
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
