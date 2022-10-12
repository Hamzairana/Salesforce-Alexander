trigger TriggerOnProperty on Property__c (after insert, after update, after delete, before delete, after undelete) {
    if (Trigger.isAfter){
        if(Trigger.isinsert || Trigger.isundelete){
            PropertyHandler.updateCalculationsOnCampaigns(Trigger.newMap.keySet());
            PropertyHandler.updateCalculationsOnOpportunity(Trigger.new, Trigger.new,'Insert');
    	}
        else if(trigger.isupdate){
            //PropertyHandler.updateCalculationsOnOpportunity(Trigger.old);
            
            PropertyHandler.updateCalculationsOnOpportunity(Trigger.new,Trigger.old,'Update');
        }
        else if(trigger.isdelete){
            PropertyHandler.updateCalculationsOnOpportunity(Trigger.old, Trigger.old,'Delete');
        }
    }
    else if (Trigger.isBefore){
        if(trigger.isdelete){
            PropertyHandler.updateCalculationsOnCampaignsBeforeDelete(Trigger.old, Trigger.OldMap.keyset());
            //PropertyHandler.updateCalculationsOnOpportunity(Trigger.old, Trigger.old,'Delete');
        }
    }
}