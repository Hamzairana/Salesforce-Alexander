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
    public static void updateCalculationsOnOpportunity(List<Property__c> properties, List<Property__c> propertiesOld, String operation) {
        Set<Id> uniqueOpportunities = new Set<Id>();
        List<Opportunity> opportunitiesToUpdate;
        double sumListPriceEstimatedPrice = 0;
        double sumExpectedRevenue = 0;
        double sumExpectedGrossProfit = 0;
        List <Property__c> propertiesRelatedToOpportunity = new List <Property__c>();
        preventRecursion.propertiesUpdated = true;
        for(Property__c property : properties){
            if (property.OpportunityId__c != null){
                If(!preventRecursion.SetOfOppIDs.contains(property.OpportunityId__c)){
                    if(property.OpportunityId__c != null){
                        uniqueOpportunities.add(property.OpportunityId__c);
                        system.debug('Doesnt contain Opp');
                    }
                }
                else{
                    system.debug('Does contain Opp');
                }
            }
        }
        for(Property__c property : propertiesOld){
            if (property.OpportunityId__c != null){
                If(!preventRecursion.SetOfOppIDs.contains(property.OpportunityId__c)){
                    if(property.OpportunityId__c != null){
                        uniqueOpportunities.add(property.OpportunityId__c);
                        system.debug('Doesnt contain Opp');
                    }
                }
                else{
                    system.debug('Does contain Opp');
                }
            }
        }
        system.debug('uniqueOpportunities : ' + uniqueOpportunities);
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().keySet());
        List<String> propertyFields = new List<String>(Schema.getGlobalDescribe().get('Property__c').getDescribe().fields.getMap().keySet());
        String subQuery  = 'SELECT '+String.join(propertyFields, ',')+ ' FROM Properties__r ORDER BY CREATEDDATE DESC LIMIT 1 ';
        String query = 'Select '+String.join(fields, ',')+',('+subQuery+')'+'FROM OPPORTUNITY WHERE ID In :uniqueOpportunities';
        opportunitiesToUpdate = Database.query(query);
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
            if (opportunity.properties__r.size()==0){
                System.debug('Size Zero case');
                opportunity.Sum_of_List_Price_Estimated_Price__c = 0;
                opportunity.Sum_of_Expected_Revenue__c = 0;
                opportunity.Sum_of_Expected_Gross_Profit__c = 0;
                opportunity.Average_of_Expected_Gross_Margin__c = 0;
            }
            else{
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
            }
            
            sumListPriceEstimatedPrice = 0;
            sumExpectedRevenue = 0;
            sumExpectedGrossProfit = 0;
        }
        for(Opportunity opportunity : opportunitiesToUpdate){
            if(opportunity.Properties__r.size() == 0){
                system.debug('handle zero case here as well');
                
                //Property Name link fields
                opportunity.Top_Property_name__c=null;
                opportunity.Property_Id__c=null;
                /* Action Items Section Fields */ 
                opportunity.Notes_Open_Items__c=null;
                opportunity.Scheduled_Close_Date__c=null;
                opportunity.Escrow_Agent__c=null;
                opportunity.Realtor_Assessment__c=null;
                opportunity.Realtor_Assessment_Notes__c=null;
                opportunity.Soil_Evaluation__c=null;
                opportunity.Soil_Evaluation_Notes__c=null;
                opportunity.Purchase_Agreement_Status__c=null;
                opportunity.Funding__c=null;
                opportunity.Funding_Notes__c=null;
                opportunity.Drone_Photos_Status__c=null;
                
                /* Due Diligence Section Fields */
                
                opportunity.Short_Legal_Description__c=null;
                opportunity.Access_Due_Diligence__c=null;
                opportunity.Topography_Due_Diligence__c=null;
                opportunity.Zoning__c=null;
                opportunity.Number_of_Potential_Building__c=null;
                opportunity.Power__c=null;
                opportunity.Sewer__c=null;
                opportunity.Sewer_Line_Startup_Cost__c=null;
                opportunity.Water__c=null;
                opportunity.Water_Line_Startup_Cost__c=null;
                opportunity.Septic_Exists__c=false;
                opportunity.Power_Exists__c=false;
                opportunity.Flood_Zone__c=null;
                opportunity.Elevation__c=null;
                opportunity.RV__c=null;
                opportunity.Mobile_Homes_Allowed__c=null;
                opportunity.Road_Maintenance_Agreement__c=null;
                opportunity.Cost_of_Road_Maintenance__c=null;
                opportunity.Listing_Agent__c=null;
                opportunity.Soil_Consultant__c=null;
                opportunity.Soil_Evaluation_Due_Diligence__c=null;
                opportunity.HOA__c=null;
                opportunity.HOA_Name__c=null;
                opportunity.HOA_Annual_Fees__c=null;
                opportunity.HOA_Back_Fees_Due__c=null;
                opportunity.Annual_Taxes__c=null;
                opportunity.Back_Taxes_Due__c=null;
                opportunity.Assessed_Value__c=null;
                opportunity.Subdivision__c=null;
                opportunity.Owner_Type__c=null;
                opportunity.Property_Address__c=null;
                opportunity.Due_Diligence_Status__c=null;
                
                /* Pricing Section Fields */
                
                opportunity.Original_Offer__c=null;
                opportunity.Seller_Asking__c=null;
                opportunity.Buy_Side_Purchase_Price__c=null;
                opportunity.Buy_Side_Total_Cost__c=null;
                opportunity.Buy_Side_Soil_Evaluation__c=null;
                opportunity.Buy_Side_Legal_Fees_Due_Diligence__c=null;
                opportunity.Buy_Side_Survey_Cost__c=null;
                opportunity.Buy_Side_Total_Settlement_Charges__c=null;
                opportunity.Buy_Side_Commissions__c=null;
                opportunity.Buy_Side_Legal_Fees_Closing__c=null;
                opportunity.Buy_Side__c=null;
                opportunity.Buy_Side_Property_Taxes__c=null;
                opportunity.Buy_Side_HOA_Fees__c=null;
                opportunity.Buy_Side_Wire_Fee__c=null;
                opportunity.List_Price_Estimated_Price__c=null;
                opportunity.Sold_Type__c=null;
                opportunity.Sold_Price__c=null;
                opportunity.Sell_Side_Total_Settlement_Charges__c=null;
                opportunity.Net_Sale_Price__c=null;
                opportunity.Sell_Side_Commissions__c=null;
                opportunity.Sell_Side_Escrow_Costs__c=null;
                opportunity.Sell_Side_HOA__c=null;
                opportunity.Sell_Side_Property_Taxes__c=null;
                opportunity.Sell_Side_Legal_Fees__c=null;
                opportunity.Sell_Side_Wire_Fee__c=null;
                opportunity.Held_By__c=null;
                opportunity.Buy_Side_Cash_at_Closing__c=null;
                
                /* Pricing Metrics Section Fields */
                
                opportunity.Days_on_Market__c=null;
                opportunity.Date_Listed__c=null;
                opportunity.Date_Sold__c=null;
                opportunity.Expected_Revenue__c=null;
                opportunity.Expected_Gross_Profit__c=null;
                opportunity.Expected_Gross_Margin__c=null;
                opportunity.Adjusted_Revenue__c=null;
                opportunity.Adjusted_Gross_Profit__c=null;
                opportunity.Adjusted_Total_Cost__c=null;
                opportunity.Adjusted_Gross_Margin__c=null;
                //opportunity.Total_Cash_Margin__c=null;//
                
                /* Top Section Fields */
                
                //opportunity.CountyAPN__c=null;//
                opportunity.County__c=null;
                opportunity.APN_Formatted__c=null;
                opportunity.APN_Unformatted__c=null;
                opportunity.Property_legal_description__c=null;
                
                opportunity.Property_Number__c=null;
                opportunity.Lot_Acreage__c=null;
                //opportunity.Total_Gross_Margin__c=null;
                opportunity.Acreage__c=null;
                opportunity.Zoning_Data_Tree_Export__c=null;
                opportunity.Situs_Street_Address__c=null;
                opportunity.Situs_City__c=null;
                opportunity.Situs_State__c=null;
                opportunity.Situs_Zip_Code__c=null;
                opportunity.Situs_Street__c=null;
                opportunity.Situs_Full_Address__c=null;
                opportunity.Assessed_Land_Value__c=null;
                opportunity.Market_Land_Value__c=null;
            }
            else{
                		//Property Name link fields
                		opportunity.Top_Property_name__c=opportunity.Properties__r[0].Name;
                		opportunity.Property_Id__c=opportunity.Properties__r[0].Id;
                		/* Action Items Section Fields */                   
                        opportunity.Notes_Open_Items__c=opportunity.Properties__r[0].Notes_Open_Items__c;
                        opportunity.Scheduled_Close_Date__c=opportunity.Properties__r[0].Scheduled_Close_Date__c;
                        opportunity.Escrow_Agent__c=opportunity.Properties__r[0].Escrow_Agent__c;
                        opportunity.Realtor_Assessment__c=opportunity.Properties__r[0].Realtor_Assessment__c;
                        opportunity.Realtor_Assessment_Notes__c=opportunity.Properties__r[0].Realtor_Assessment_Notes__c;
                        opportunity.Soil_Evaluation__c=opportunity.Properties__r[0].Soil_Evaluation_Action_Items__c;
                        opportunity.Soil_Evaluation_Notes__c=opportunity.Properties__r[0].Soil_Evaluation_Notes__c;
                        opportunity.Purchase_Agreement_Status__c=opportunity.Properties__r[0].Purchase_Agreement_Status__c;
                        opportunity.Funding__c=opportunity.Properties__r[0].Funding__c;
                        opportunity.Funding_Notes__c=opportunity.Properties__r[0].Funding_Notes__c;
                        opportunity.Drone_Photos_Status__c=opportunity.Properties__r[0].Drone_Photos_Status__c;
                        
                        /* Due Diligence Section Fields */
                        
                        opportunity.Short_Legal_Description__c=opportunity.Properties__r[0].Short_Legal_Description__c;
                        opportunity.Access_Due_Diligence__c=opportunity.Properties__r[0].Access_Due_Diligence__c;
                        opportunity.Topography_Due_Diligence__c=opportunity.Properties__r[0].Topography_Due_Diligence__c;
                        opportunity.Zoning__c=opportunity.Properties__r[0].Zoning__c;
                        opportunity.Number_of_Potential_Building__c=opportunity.Properties__r[0].of_Potential_Building_Lots__c;
                        opportunity.Power__c=opportunity.Properties__r[0].Power__c;
                        opportunity.Sewer__c=opportunity.Properties__r[0].Sewer__c;
                        opportunity.Sewer_Line_Startup_Cost__c=opportunity.Properties__r[0].Sewer_Line_Startup_Cost__c;
                        opportunity.Water__c=opportunity.Properties__r[0].Water__c;
                        opportunity.Water_Line_Startup_Cost__c=opportunity.Properties__r[0].Water_Line_Startup_Cost__c;
                        opportunity.Septic_Exists__c=opportunity.Properties__r[0].Septic_Exists__c;
                        opportunity.Power_Exists__c=opportunity.Properties__r[0].Power_Exists__c;
                        opportunity.Flood_Zone__c=opportunity.Properties__r[0].Flood_Zone__c;
                        opportunity.Elevation__c=opportunity.Properties__r[0].Elevation__c;
                        opportunity.RV__c=opportunity.Properties__r[0].RVs_Allowed__c;
                        opportunity.Mobile_Homes_Allowed__c=opportunity.Properties__r[0].Mobile_Homes_Allowed__c;
                        opportunity.Road_Maintenance_Agreement__c=opportunity.Properties__r[0].Road_Maintenance_Agreement__c;
                        opportunity.Cost_of_Road_Maintenance__c=opportunity.Properties__r[0].Cost_of_Road_Maintenance_Agreement__c;
                        opportunity.Listing_Agent__c=opportunity.Properties__r[0].Listing_Agent__c;
                        opportunity.Soil_Consultant__c=opportunity.Properties__r[0].Soil_Consultant__c;
                        opportunity.Soil_Evaluation_Due_Diligence__c=opportunity.Properties__r[0].Soil_Evaluation_Due_Diligence__c;
                        opportunity.HOA__c=opportunity.Properties__r[0].HOA__c;
                        opportunity.HOA_Name__c=opportunity.Properties__r[0].HOA_Name__c;
                        opportunity.HOA_Annual_Fees__c=opportunity.Properties__r[0].HOA_Annual_Fees__c;
                        opportunity.HOA_Back_Fees_Due__c=opportunity.Properties__r[0].HOA_Back_Fees_Due__c;
                        opportunity.Annual_Taxes__c=opportunity.Properties__r[0].Annual_Taxes__c;
                        opportunity.Back_Taxes_Due__c=opportunity.Properties__r[0].Back_Taxes_Due__c;
                        opportunity.Assessed_Value__c=opportunity.Properties__r[0].Assessed_Value__c;
                        opportunity.Subdivision__c=opportunity.Properties__r[0].Subdivision__c;
                        opportunity.Owner_Type__c=opportunity.Properties__r[0].Owner_Type__c;
                        opportunity.Property_Address__c=opportunity.Properties__r[0].Property_Address__c;
                        opportunity.Due_Diligence_Status__c=opportunity.Properties__r[0].Due_Diligence_Status__c;
                        
                        /* Pricing Section Fields */
                        
                        opportunity.Original_Offer__c=opportunity.Properties__r[0].Original_Offer__c;
                        opportunity.Seller_Asking__c=opportunity.Properties__r[0].Seller_Asking__c;
                        opportunity.Buy_Side_Purchase_Price__c=opportunity.Properties__r[0].Buy_Side_Purchase_Price__c;
                        opportunity.Buy_Side_Total_Cost__c=opportunity.Properties__r[0].Buy_Side_Total_Cost__c;
                        opportunity.Buy_Side_Soil_Evaluation__c=opportunity.Properties__r[0].Buy_Side_Soil_Evaluation__c;
                        opportunity.Buy_Side_Legal_Fees_Due_Diligence__c=opportunity.Properties__r[0].Buy_Side_Legal_Fees_Due_Diligence__c;
                        opportunity.Buy_Side_Survey_Cost__c=opportunity.Properties__r[0].Buy_Side_Survey_Cost__c;
                        opportunity.Buy_Side_Total_Settlement_Charges__c=opportunity.Properties__r[0].Buy_Side_Total_Settlement_Charges__c;
                        opportunity.Buy_Side_Commissions__c=opportunity.Properties__r[0].Buy_Side_Commissions__c;
                        opportunity.Buy_Side_Legal_Fees_Closing__c=opportunity.Properties__r[0].Buy_Side_Legal_Fees_Closing__c;
                        opportunity.Buy_Side__c=opportunity.Properties__r[0].Buy_Side_Title_Insurance__c;
                        opportunity.Buy_Side_Property_Taxes__c=opportunity.Properties__r[0].Buy_Side_Property_Taxes__c;
                        opportunity.Buy_Side_HOA_Fees__c=opportunity.Properties__r[0].Buy_Side_HOA_Fees__c;
                        opportunity.Buy_Side_Wire_Fee__c=opportunity.Properties__r[0].Buy_Side_Wire_Fee__c;
                        opportunity.List_Price_Estimated_Price__c=opportunity.Properties__r[0].List_Price_Estimated_Price__c;
                        opportunity.Sold_Type__c=opportunity.Properties__r[0].Sold_Type__c;
                        opportunity.Sold_Price__c=opportunity.Properties__r[0].Sold_Price__c;
                        opportunity.Sell_Side_Total_Settlement_Charges__c=opportunity.Properties__r[0].Sell_Side_Total_Settlement_Charges__c;
                        opportunity.Net_Sale_Price__c=opportunity.Properties__r[0].Net_Sale_Price__c;
                        opportunity.Sell_Side_Commissions__c=opportunity.Properties__r[0].Sell_Side_Commissions__c;
                        opportunity.Sell_Side_Escrow_Costs__c=opportunity.Properties__r[0].Sell_Side_Escrow_Costs__c;
                        opportunity.Sell_Side_HOA__c=opportunity.Properties__r[0].Sell_Side_HOA_Fees__c;
                        opportunity.Sell_Side_Property_Taxes__c=opportunity.Properties__r[0].Sell_Side_Property_Taxes__c;
                        opportunity.Sell_Side_Legal_Fees__c=opportunity.Properties__r[0].Sell_Side_Legal_Fees__c;
                        opportunity.Sell_Side_Wire_Fee__c=opportunity.Properties__r[0].Sell_Side_Wire_Fee__c;
                        opportunity.Held_By__c=opportunity.Properties__r[0].Held_By__c;
                        opportunity.Buy_Side_Cash_at_Closing__c=opportunity.Properties__r[0].Buy_Side_Cash_At_Closing__c;
                        
                        /* Pricing Metrics Section Fields */
                        
                        opportunity.Days_on_Market__c=opportunity.Properties__r[0].Days_on_Market__c;
                        opportunity.Date_Listed__c=opportunity.Properties__r[0].Date_Listed__c;
                        opportunity.Date_Sold__c=opportunity.Properties__r[0].Date_Sold__c;
                        opportunity.Expected_Revenue__c=opportunity.Properties__r[0].Expected_Revenue__c;
                        opportunity.Expected_Gross_Profit__c=opportunity.Properties__r[0].Expected_Gross_Profit__c;
                        opportunity.Expected_Gross_Margin__c=opportunity.Properties__r[0].Expected_Gross_Margin__c;
                        opportunity.Adjusted_Revenue__c=opportunity.Properties__r[0].Adjusted_Revenue__c;
                        opportunity.Adjusted_Gross_Profit__c=opportunity.Properties__r[0].Adjusted_Gross_Profit__c;
                        opportunity.Adjusted_Total_Cost__c=opportunity.Properties__r[0].Adjusted_Total_Cost__c;
                        opportunity.Adjusted_Gross_Margin__c=opportunity.Properties__r[0].Adjusted_Gross_Margin__c;
                        //opportunity.Total_Cash_Margin__c=opportunity.Properties__r[0].Total_Cash_Margin__c;//
                        
                        /* Top Section Fields */
                        
                        //opportunity.CountyAPN__c=opportunity.Properties__r[0].CountyAPN__c;//
                        opportunity.County__c=opportunity.Properties__r[0].County_Name__c;
                        opportunity.APN_Formatted__c=opportunity.Properties__r[0].APN_Formatted__c;
                        opportunity.APN_Unformatted__c=opportunity.Properties__r[0].APN_Unformatted__c;
                        opportunity.Property_legal_description__c=opportunity.Properties__r[0].Property_Legal_Description__c;
                        
                        opportunity.Property_Number__c=opportunity.Properties__r[0].Property_Number__c;
                        opportunity.Lot_Acreage__c=opportunity.Properties__r[0].Lot_Acreage__c;
                        //opportunity.Total_Gross_Margin__c=opportunity.Properties__r[0].Total_Gross_Margin__c;
                        opportunity.Acreage__c=opportunity.Properties__r[0].Acreage__c;
                        opportunity.Zoning_Data_Tree_Export__c=opportunity.Properties__r[0].Zoning_Data_Tree_Export__c;
                        opportunity.Situs_Street_Address__c=opportunity.Properties__r[0].Situs_Street_Address__c;
                        opportunity.Situs_City__c=opportunity.Properties__r[0].Situs_City__c;
                        opportunity.Situs_State__c=opportunity.Properties__r[0].Situs_State__c;
                        opportunity.Situs_Zip_Code__c=opportunity.Properties__r[0].Situs_Zip_Code__c;
                        opportunity.Situs_Street__c=opportunity.Properties__r[0].Situs_Street_Name__c;
                        opportunity.Situs_Full_Address__c=opportunity.Properties__r[0].Situs_Full_Address__c;
                        opportunity.Assessed_Land_Value__c=opportunity.Properties__r[0].Assessed_Land_Value__c;
                        opportunity.Market_Land_Value__c=opportunity.Properties__r[0].Market_Land_Value__c;
            }
        }
        try{
            update opportunitiesToUpdate;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }                    
    }
}