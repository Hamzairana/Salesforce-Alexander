trigger TriggerOnOpportunity on Opportunity (before insert, after update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            for (Opportunity opp: Trigger.new){
                opp.external_id__c = opp.external_id__c == null? 'CONVERTED' + string.valueOf(Datetime.now()): opp.external_id__c;
            }
        }
    }    
    if(trigger.isAfter){
        if(trigger.isUpdate){
            system.debug('Inside Opp Trigger');
            OpportunityHandler.updateTopPropertyFromOpportunity(Trigger.new, Trigger.newMap.keySet());
        }
    }
    
}