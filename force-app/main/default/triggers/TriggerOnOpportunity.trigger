trigger TriggerOnOpportunity on Opportunity (before insert) {
    for (Opportunity opp: Trigger.new){
        opp.external_id__c = opp.external_id__c == null? 'CONVERTED' + string.valueOf(Datetime.now()): opp.external_id__c;
    }
}