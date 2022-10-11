public class OfferHandler {
    public static void rollupCalculationsOnCampaigns(List<Offer__c> offers){
        string accepted = '%Accepted%';
        Set<Id> uniqueCampaigns = new Set<Id>();
        List <Offer__c> offersForCampaign = new List <Offer__c>();
        List<Campaign> campaignsToUpdate;
        double sumCashMargin = 0;
        double sumAdjustedGrossProfit = 0;
        double sumExpectedGrossProfit = 0;
        
        for(Offer__c offer : offers){
            if (offer.CampaignId__c != null){
                uniqueCampaigns.add(offer.CampaignId__c);
            }
        }
        campaignsToUpdate = [SELECT
                             Id,
                             Sum_Total_Cash_Margin__c,
                             Sum_Total_Adjusted_Gross_Profit__c,
                             Sum_Total_Expected_Gross_Profit__c
                             FROM Campaign
                             WHERE Id in :uniqueCampaigns
                            ];
		for (Offer__c offer : [SELECT 
                       		   Id, 
                               Name, 
                       		   County__c, 
                       		   CampaignId__c, 
                       		   PropertyId__c, 
                       		   offer_status__c,
                               propertyId__r.Total_Cash_Margin__c,
                               propertyId__r.Adjusted_Gross_Profit__c,
                               propertyId__r.Expected_Gross_Profit__c
                       		   FROM Offer__c
                       		   WHERE CampaignId__c in :uniqueCampaigns AND offer_status__c like :accepted]
    	)
        {
        	offersForCampaign.add(offer);
		}
        for (Campaign campaign : campaignsToUpdate){
            for(Offer__c offer : offersForCampaign){
                if (offer.CampaignId__c == campaign.Id){
                    sumCashMargin += offer.propertyId__r.Total_Cash_Margin__c != null? offer.propertyId__r.Total_Cash_Margin__c: 0 ;
        			sumAdjustedGrossProfit += offer.propertyId__r.Adjusted_Gross_Profit__c != null? offer.propertyId__r.Adjusted_Gross_Profit__c: 0 ;
        			sumExpectedGrossProfit += offer.propertyId__r.Expected_Gross_Profit__c != null? offer.propertyId__r.Expected_Gross_Profit__c: 0 ;
                }
            }
            campaign.Sum_Total_Cash_Margin__c = sumCashMargin;
            campaign.Sum_Total_Adjusted_Gross_Profit__c = sumAdjustedGrossProfit;
            campaign.Sum_Total_Expected_Gross_Profit__c = sumExpectedGrossProfit;
            sumCashMargin = 0;
        	sumAdjustedGrossProfit = 0;
        	sumExpectedGrossProfit = 0;
        }
        try{
            update campaignsToUpdate;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}