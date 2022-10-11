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
/*
    public static Opportunity getTopPropertyRelatedToOpportunity(Id opportunityId) {

        Property__c property = []


        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id =:opportunityId];
        try{
          return opp;
         } catch(Exception ex)
         {
             throw new AuraHandledException(ex.getMessage());
         }
    }*/
}
