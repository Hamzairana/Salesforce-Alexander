public class PropertyHandler {
    public static void updateCalculationsOnCampaigns(Set<Id> propertyIDs) {
        List<Offer__c> offers = new List<Offer__c>();
        for (Offer__c offer : [SELECT 
                               Id,
                               Name, 
                               CampaignId__c
                               FROM Offer__c
                               WHERE propertyId__c in :propertyIDs]
            )
        {
            offers.add(offer);    
        } 
        if (offers.size()>0){
            OfferHandler.rollupCalculationsOnCampaigns(offers);
        }
    }
    public static void updateCalculationsOnCampaignsBeforeDelete(List<Property__c> properties, Set<Id> propertyIDs) {
        List<Offer__c> offers = new List<Offer__c>();
        Set<Id> uniqueCampaigns = new Set<Id>();
        List<Campaign> campaignsToUpdate;
        List <Offer__c> offersForCampaign = new List <Offer__c>();
        string accepted = '%Accepted%';
        double sumCashMargin = 0;
        double sumAdjustedGrossProfit = 0;
        double sumExpectedGrossProfit = 0;

        for (Offer__c offer : [SELECT 
                               Id,
                               Name, 
                               CampaignId__c
                               FROM Offer__c
                               WHERE propertyId__c in :propertyIDs and offer_status__c like :accepted]
        ){
            offers.add(offer);    
        }
        if (offers.size()>0){
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
            ){
                offersForCampaign.add(offer);
            }
            for (Campaign campaign : campaignsToUpdate){
                for(Offer__c offer : offersForCampaign){
                    if (offer.CampaignId__c == campaign.Id && !propertyIDs.contains(offer.PropertyId__c)){
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
    public static void updateCalculationsOnOpportunity(List<Property__c> properties) {
        Set<Id> uniqueOpportunities = new Set<Id>();
        List<Opportunity> opportunitiesToUpdate;
        double sumListPriceEstimatedPrice = 0;
        double sumExpectedRevenue = 0;
        double sumExpectedGrossProfit = 0;
        List <Property__c> propertiesRelatedToOpportunity = new List <Property__c>();
    
        for(Property__c property : properties){
            if (property.OpportunityId__c != null){
                uniqueOpportunities.add(property.OpportunityId__c);
            }
        }
        
        opportunitiesToUpdate = [SELECT
                                 Id,
                                 Sum_of_List_Price_Estimated_Price__c,
                                 Sum_of_Expected_Revenue__c,
                                 Sum_of_Expected_Gross_Profit__c
                                 FROM Opportunity
                                 WHERE Id in :uniqueOpportunities
                                ];
        
        for(Property__c property: [Select 
                                   Id, 
                                   Name, 
                                   OpportunityId__c, 
                                   List_Price_Estimated_Price__c, 
                                   Expected_Revenue__c, 
                                   Expected_Gross_Profit__c 
                                   FROM Property__c 
                                   WHERE OpportunityId__c IN :uniqueOpportunities
                                  ]
           )
        {
            propertiesRelatedToOpportunity.add(property);
        }
       
        for(Opportunity opportunity : opportunitiesToUpdate){
            for(Property__c property : propertiesRelatedToOpportunity){
                if(opportunity.Id == property.OpportunityId__c){
                    sumListPriceEstimatedPrice += property.List_Price_Estimated_Price__c != null? property.List_Price_Estimated_Price__c: 0 ;
                    sumExpectedRevenue += property.Expected_Revenue__c != null? property.Expected_Revenue__c: 0 ;
                    sumExpectedGrossProfit += property.Expected_Gross_Profit__c != null? property.Expected_Gross_Profit__c: 0 ;
                  
                }
            } 
            opportunity.Sum_of_List_Price_Estimated_Price__c = sumListPriceEstimatedPrice;
            opportunity.Sum_of_Expected_Revenue__c = sumExpectedRevenue;
            opportunity.Sum_of_Expected_Gross_Profit__c = sumExpectedGrossProfit;
            opportunity.Average_of_Expected_Gross_Margin__c =  sumExpectedRevenue !=0? (sumExpectedGrossProfit / sumExpectedRevenue)*100: 0;
    
            sumListPriceEstimatedPrice = 0;
            sumExpectedRevenue = 0;
            sumExpectedGrossProfit = 0;
        }                          
        try{
            update opportunitiesToUpdate;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }                    
    }
}