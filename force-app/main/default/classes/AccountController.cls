/**
 * @author Hamza Rana
 * @since 2022
 */

public with sharing class AccountController {

    /**
     * @param accountId gets related accountId on the Contact Object
     * @return returns list of contacts that are active
     */
   @AuraEnabled
    public static List<Contact> getActiveRelatedContacts(Id accountId) {
        try{
            return [
                SELECT Contact.Account.Name, Name, Title, Email, Phone, Direct__c
                FROM Contact
                WHERE isActive__c = True AND AccountId=:accountId 
                order by createdDate desc 
                LIMIT 6
           ];
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 
     * @param accountId gets related accountId on the contact object
     * @return  returns count of active contacts.
     *
     */
    @AuraEnabled
    public static Integer getCountOfActiveContacts(Id accountId){
        try {
            return [
                SELECT count()
                FROM Contact
                WHERE isActive__c = True AND AccountId = :accountId  
           ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
