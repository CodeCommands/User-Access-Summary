import { LightningElement, api, track } from 'lwc';

export default class UserAccessCard extends LightningElement {
    @api user;
    @api showActions = false;
    
    @track isExpanded = false;
    
    get userStatusClass() {
        return this.user?.isActive ? 'status-active' : 'status-inactive';
    }
    
    get userStatusText() {
        return this.user?.isActive ? 'Active' : 'Inactive';
    }
    
    get userStatusVariant() {
        return this.user?.isActive ? 'success' : 'error';
    }
    
    get lastLoginFormatted() {
        if (!this.user?.lastLoginDate) {
            return 'Never';
        }
        return new Date(this.user.lastLoginDate).toLocaleDateString();
    }
    
    get userInitials() {
        if (!this.user?.name) return '';
        const names = this.user.name.split(' ');
        return names.map(name => name.charAt(0)).join('').substring(0, 2).toUpperCase();
    }
    
    handleSelectUser() {
        const selectEvent = new CustomEvent('selectuser', {
            detail: {
                userId: this.user.id,
                user: this.user
            }
        });
        this.dispatchEvent(selectEvent);
    }
    
    handleToggleExpand() {
        this.isExpanded = !this.isExpanded;
    }
    
    handleViewPermissions() {
        const viewEvent = new CustomEvent('viewpermissions', {
            detail: {
                userId: this.user.id,
                user: this.user
            }
        });
        this.dispatchEvent(viewEvent);
    }
}
