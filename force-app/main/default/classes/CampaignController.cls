public with sharing class CampaignController {
    public class CampaignWrapper{
        @AuraEnabled
        public String county;
        @AuraEnabled
        public Integer noOfAcceptedOffers;
        @AuraEnabled
        public Double sumCashMargin;
        @AuraEnabled
        public Double sumAdjustedGrossProfit;
        @AuraEnabled
        public Double totalCost;
    }
    @AuraEnabled
    public static List<CampaignWrapper> getCampaigns(Id campaignId) {
        system.debug('In get Campaigns Function');
        string accepted = '%Accepted%';
        List<Offer__c> offers;
        Set<String> uniqueCounties = new Set<String>();
        List<CampaignWrapper> campaigns = new List<CampaignWrapper>();
        CampaignWrapper campaign = new CampaignWrapper();
        Campaign selectedCampaign;
        double sumCashMargin = 0;
        double sumAdjustedGrossProfit = 0;
        integer noOfAcceptedOffers = 0;
        
        if (campaignId != null){
            selectedCampaign = [SELECT id, Campaign_Total_Cost__c FROM Campaign WHERE id = :campaignId limit 1];
            offers = [SELECT 
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
                     WHERE CampaignId__c = :campaignId AND offer_status__c like :accepted];
           
        }
        if (offers.size()>0){
            for(Offer__c offer : offers){
                if (offer.County__c != null){
                    uniqueCounties.add(offer.County__c);
                }
                else{
                    uniqueCounties.add('N/A');
                }
            }
            for(String county : uniqueCounties){
                campaign = new CampaignWrapper();
                noOfAcceptedOffers = 0;
                sumCashMargin = 0;
                sumAdjustedGrossProfit = 0;
                for(Offer__c offer : offers){
                   if(county == offer.County__c){
                        noOfAcceptedOffers++;
                        sumCashMargin += offer.propertyId__r.Total_Cash_Margin__c != null? offer.propertyId__r.Total_Cash_Margin__c: 0 ;
        				sumAdjustedGrossProfit += offer.propertyId__r.Adjusted_Gross_Profit__c != null? offer.propertyId__r.Adjusted_Gross_Profit__c: 0 ;
                    }
            	}
                campaign.county = county;
                campaign.noOfAcceptedOffers = noOfAcceptedOffers;
                campaign.totalCost = ((double)noOfAcceptedOffers/offers.size() * selectedCampaign.Campaign_Total_Cost__c).setScale(2);
                campaign.sumCashMargin = sumCashMargin;
                campaign.sumAdjustedGrossProfit = sumAdjustedGrossProfit;
                campaigns.add(campaign);
            }
        }
        return campaigns;
    }
}