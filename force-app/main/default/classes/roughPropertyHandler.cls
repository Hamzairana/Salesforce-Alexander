public class roughPropertyHandler {
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
    
    public static void updateCalculationsOnOpportunity(List<Property__c> properties) {
        Set<Id> uniqueOpportunities = new Set<Id>();
        List<Opportunity> opportunitiesToUpdate;
        
        List<Double> eachPropertyPercentageList = new List<Double>();
        List<Double> profitPerTotalRevenue = new List<Double>();

        double sumListPriceEstimatedPrice = 0;
        double sumExpectedRevenue = 0;
        double sumExpectedGrossProfit = 0;
        double ProfitPercentageForEachProperty = 0;
        
        List <Property__c> propertiesRelatedToOpportunity = new List <Property__c>();
        
        for(Property__c property : properties){
            uniqueOpportunities.add(property.OpportunityId__c);
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
        
        double getRevenueOfPropertyPerTotalRevenue = 0;

        for(Opportunity opportunity : opportunitiesToUpdate){
            for(Property__c property : propertiesRelatedToOpportunity){

        }
            for(Property__c property : propertiesRelatedToOpportunity){
                if(opportunity.Id == property.OpportunityId__c){
                    sumListPriceEstimatedPrice += property.List_Price_Estimated_Price__c != null? property.List_Price_Estimated_Price__c: 0 ;
                    sumExpectedRevenue += property.Expected_Revenue__c != null? property.Expected_Revenue__c: 0 ;
                    sumExpectedGrossProfit += property.Expected_Gross_Profit__c != null? property.Expected_Gross_Profit__c: 0 ;
                    ProfitPercentageForEachProperty = property.Expected_Gross_Profit__c != null? (property.Expected_Gross_Profit__c/property.Expected_Revenue__c): 0 ;
                    eachPropertyPercentageList.add(ProfitPercentageForEachProperty);
                    system.debug('Profit Expected Revenue: ' + property.Expected_Revenue__c);
                    system.debug('Profit Percentage: ' + eachPropertyPercentageList);
                  
                    
                }
            } 
            opportunity.Sum_of_List_Price_Estimated_Price__c = sumListPriceEstimatedPrice;
            opportunity.Sum_of_Expected_Revenue__c = sumExpectedRevenue;
            opportunity.Sum_of_Expected_Gross_Profit__c = sumExpectedGrossProfit;
            
            system.debug('Sum Expected Revenue: ' + sumExpectedRevenue);

            for(Property__c property : propertiesRelatedToOpportunity){
                getRevenueOfPropertyPerTotalRevenue = property.Expected_Revenue__c != null? (property.Expected_Revenue__c/sumExpectedRevenue):0 ;
                profitPerTotalRevenue.add(getRevenueOfPropertyPerTotalRevenue);
                system.debug('Profit Per Total Revenue: ' + profitPerTotalRevenue);
            }

            double checkSum = 0;
            for(Integer i=0;i<propertiesRelatedToOpportunity.size();i++){
                checkSum+=eachPropertyPercentageList[i]*profitPerTotalRevenue[i];
            }
            system.debug('CheckSum: '+ checkSum);
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