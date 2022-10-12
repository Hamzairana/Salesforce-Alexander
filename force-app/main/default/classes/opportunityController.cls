public with sharing class opportunityController {
    @AuraEnabled
    public static Opportunity getOpportunityRelatedAccount(Id opportunityId) {
        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id =:opportunityId];
        try{
          return opp;
         } catch(Exception ex)
         {
             throw new AuraHandledException(ex.getMessage());
         }
    }
}
