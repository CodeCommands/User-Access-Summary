/**
 * @description Filter criteria class for user queries
 * @author Salesforce Development Team
 * @date 2025
 */
public with sharing class UserAccessFilterCriteria {
    @AuraEnabled public String searchTerm;
    @AuraEnabled public List<String> profileIds;
    @AuraEnabled public Boolean includeInactive;
    @AuraEnabled public Integer limitSize;
    @AuraEnabled public Integer offset;
    
    /**
     * @description Constructor
     * @param searchTerm Search term for filtering
     * @param profileIds Profile IDs to filter by
     * @param includeInactive Include inactive users
     * @param limitSize Limit number of results
     * @param offset Offset for pagination
     */
    public UserAccessFilterCriteria(String searchTerm, List<String> profileIds, Boolean includeInactive, Integer limitSize, Integer offset) {
        this.searchTerm = searchTerm;
        this.profileIds = profileIds;
        this.includeInactive = includeInactive;
        this.limitSize = limitSize;
        this.offset = offset;
    }
    
    /**
     * @description Default constructor
     */
    public UserAccessFilterCriteria() {
        this.searchTerm = '';
        this.profileIds = new List<String>();
        this.includeInactive = true;
        this.limitSize = 50;
        this.offset = 0;
    }
}
