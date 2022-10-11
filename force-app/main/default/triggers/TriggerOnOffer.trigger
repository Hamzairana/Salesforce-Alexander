trigger TriggerOnOffer on Offer__c (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter){
        if(Trigger.isinsert || Trigger.isupdate || Trigger.isundelete){
            OfferHandler.rollupCalculationsOnCampaigns(Trigger.new);
    	}
        else if(trigger.isdelete){
            OfferHandler.rollupCalculationsOnCampaigns(Trigger.old);
        }
    }
}