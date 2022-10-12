public class OpportunityHandler {
    public static void updateRollUpFieldsOnOpportunity(Set<Id> opportunityIDsFromTrigger){
        
    }
    public static void updateTopPropertyFromOpportunity(List <Opportunity> opportunities, Set<Id> opportunityIDsFromTrigger){
        Set<Id> opportunityIDs = new Set<Id>();
        set<Id> topPropertyIDs = new Set <Id>();
        List <Property__c> topPropertiesToUpdate;
        List<String> topPropertyFields;
        
        for (Id oppId: opportunityIDsFromTrigger){
            If(!preventRecursion.SetOfOppIDs.contains(oppId)){
                opportunityIDs.add(oppId);
                if (preventRecursion.propertiesUpdated == true){
                    preventRecursion.SetOfOppIDs.add(oppId);
                }
                system.debug('Doesnt contain');
            }
            else{
                system.debug('Does contain');
            }
        }
        
        system.debug('In side opp handler');
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get('Property__c').getDescribe().fields.getMap().keySet());
        String subQuery  = 'SELECT '+String.join(fields, ',')+' FROM Properties__r ORDER BY CREATEDDATE DESC LIMIT 1 ';
        String query = 'Select Id, Name, Funding__c, ('+subQuery+')'+'FROM OPPORTUNITY WHERE ID In :opportunityIDs';
        List <Opportunity> oppList = Database.query(query);
        If (oppList.size()>0){
            for(Integer i=0; i<oppList.size();i++){
                if(oppList[i].Properties__r.size() > 0){
                	if(oppList[i].Properties__r[0].Id != null){
                    	topPropertyIDs.add(oppList[i].Properties__r[0].Id);
                    	//preventRecursion.SetOfPropertyIDs.add(oppList[i].Properties__r[0].Id);
                	}   
                }                
            }
            topPropertyFields = new List<String>(Schema.getGlobalDescribe().get('Property__c').getDescribe().fields.getMap().keySet());
            String propertyQuery  = 'SELECT '+String.join(topPropertyFields, ',')+' FROM Property__c WHERE ID in :topPropertyIDs';
            topPropertiesToUpdate = Database.query(propertyQuery);
            for(Opportunity opp: opportunities){
                for(Property__c property: topPropertiesToUpdate){
                    if(opp.Id==property.OpportunityId__c){
                        /* Action Items Section Fields */                   
                        property.Notes_Open_Items__c=opp.Notes_Open_Items__c;
                        property.Scheduled_Close_Date__c=opp.Scheduled_Close_Date__c;
                        property.Escrow_Agent__c=opp.Escrow_Agent__c;
                        property.Realtor_Assessment__c=opp.Realtor_Assessment__c;
                        property.Realtor_Assessment_Notes__c=opp.Realtor_Assessment_Notes__c;
                        property.Soil_Evaluation_Action_Items__c=opp.Soil_Evaluation__c;
                        property.Soil_Evaluation_Notes__c=opp.Soil_Evaluation_Notes__c;
                        property.Purchase_Agreement_Status__c=opp.Purchase_Agreement_Status__c;
                        property.Funding__c=opp.Funding__c;
                        property.Funding_Notes__c=opp.Funding_Notes__c;
                        property.Drone_Photos_Status__c=opp.Drone_Photos_Status__c;
                        
                        /* Due Diligence Section Fields */
                        
                        property.Short_Legal_Description__c=opp.Short_Legal_Description__c;
                        property.Access_Due_Diligence__c=opp.Access_Due_Diligence__c;
                        property.Topography_Due_Diligence__c=opp.Topography_Due_Diligence__c;
                        property.Zoning__c=opp.Zoning__c;
                        property.of_Potential_Building_Lots__c=opp.Number_of_Potential_Building__c;
                        property.Power__c=opp.Power__c;
                        property.Sewer__c=opp.Sewer__c;
                        property.Sewer_Line_Startup_Cost__c=opp.Sewer_Line_Startup_Cost__c;
                        property.Water__c=opp.Water__c;
                        property.Water_Line_Startup_Cost__c=opp.Water_Line_Startup_Cost__c;
                        property.Septic_Exists__c=opp.Septic_Exists__c;
                        property.Power_Exists__c=opp.Power_Exists__c;
                        property.Flood_Zone__c=opp.Flood_Zone__c;
                        property.Elevation__c=opp.Elevation__c;
                        property.RVs_Allowed__c=opp.RV__c;
                        property.Mobile_Homes_Allowed__c=opp.Mobile_Homes_Allowed__c;
                        property.Road_Maintenance_Agreement__c=opp.Road_Maintenance_Agreement__c;
                        property.Cost_of_Road_Maintenance_Agreement__c=opp.Cost_of_Road_Maintenance__c;
                        property.Listing_Agent__c=opp.Listing_Agent__c;
                        property.Soil_Consultant__c=opp.Soil_Consultant__c;
                        property.Soil_Evaluation_Due_Diligence__c=opp.Soil_Evaluation_Due_Diligence__c;
                        property.HOA__c=opp.HOA__c;
                        property.HOA_Name__c=opp.HOA_Name__c;
                        property.HOA_Annual_Fees__c=opp.HOA_Annual_Fees__c;
                        property.HOA_Back_Fees_Due__c=opp.HOA_Back_Fees_Due__c;
                        property.Annual_Taxes__c=opp.Annual_Taxes__c;
                        property.Back_Taxes_Due__c=opp.Back_Taxes_Due__c;
                        property.Assessed_Value__c=opp.Assessed_Value__c;
                        property.Subdivision__c=opp.Subdivision__c;
                        property.Owner_Type__c=opp.Owner_Type__c;
                        property.Property_Address__c=opp.Property_Address__c;
                        property.Due_Diligence_Status__c=opp.Due_Diligence_Status__c;
                        
                        /* Pricing Section Fields */
                        
                        property.Original_Offer__c=opp.Original_Offer__c;
                        property.Seller_Asking__c=opp.Seller_Asking__c;
                        property.Buy_Side_Purchase_Price__c=opp.Buy_Side_Purchase_Price__c;
                        property.Hidden_Buy_Side_Total_Cost__c=opp.Buy_Side_Total_Cost__c;
                        property.Buy_Side_Soil_Evaluation__c=opp.Buy_Side_Soil_Evaluation__c;
                        property.Buy_Side_Legal_Fees_Due_Diligence__c=opp.Buy_Side_Legal_Fees_Due_Diligence__c;
                        property.Buy_Side_Survey_Cost__c=opp.Buy_Side_Survey_Cost__c;
                        property.Hidden__c=opp.Buy_Side_Total_Settlement_Charges__c;
                        property.Buy_Side_Commissions__c=opp.Buy_Side_Commissions__c;
                        property.Buy_Side_Legal_Fees_Closing__c=opp.Buy_Side_Legal_Fees_Closing__c;
                        property.Buy_Side_Title_Insurance__c=opp.Buy_Side__c;
                        property.Buy_Side_Property_Taxes__c=opp.Buy_Side_Property_Taxes__c;
                        property.Buy_Side_HOA_Fees__c=opp.Buy_Side_HOA_Fees__c;
                        property.Buy_Side_Wire_Fee__c=opp.Buy_Side_Wire_Fee__c;
                        property.List_Price_Estimated_Price__c=opp.List_Price_Estimated_Price__c;
                        property.Sold_Type__c=opp.Sold_Type__c;
                        property.Sold_Price__c=opp.Sold_Price__c;
                        property.Sell_Side_Total_Settlement_Charges__c=opp.Sell_Side_Total_Settlement_Charges__c;
                        property.Hidden_Net_Sale_Price__c=opp.Net_Sale_Price__c;
                        property.Sell_Side_Commissions__c=opp.Sell_Side_Commissions__c;
                        property.Sell_Side_Escrow_Costs__c=opp.Sell_Side_Escrow_Costs__c;
                        property.Sell_Side_HOA_Fees__c=opp.Sell_Side_HOA__c;
                        property.Sell_Side_Property_Taxes__c=opp.Sell_Side_Property_Taxes__c;
                        property.Sell_Side_Legal_Fees__c=opp.Sell_Side_Legal_Fees__c;
                        property.Sell_Side_Wire_Fee__c=opp.Sell_Side_Wire_Fee__c;
                        property.Held_By__c=opp.Held_By__c;
                        property.Hidden_Buy_Side_Cash_At_Closing__c=opp.Buy_Side_Cash_at_Closing__c;
                        
                        /* Pricing Metrics Section Fields */
                        
                        property.Days_on_Market__c=opp.Days_on_Market__c;
                        property.Date_Listed__c=opp.Date_Listed__c;
                        property.Date_Sold__c=opp.Date_Sold__c;
                        property.Hidden_Expected_Revenue__c=opp.Expected_Revenue__c;
                        property.Hidden_Expected_Gross_Profit__c=opp.Expected_Gross_Profit__c;
                        property.Hidden_Expected_Gross_Margin__c=opp.Expected_Gross_Margin__c;
                        property.Hidden_Adjusted_Revenue__c=opp.Adjusted_Revenue__c;
                        property.Hidden_Adjusted_Gross_Profit__c=opp.Adjusted_Gross_Profit__c;
                        property.Hidden_Adjusted_Total_Cost__c=opp.Adjusted_Total_Cost__c;
                        property.Hidden_Adjusted_Gross_Margin__c=opp.Adjusted_Gross_Margin__c;
                        //property.Total_Cash_Margin__c=opp.Total_Cash_Margin__c; 
                        
                        /* Top Section Fields */
                        
                        //property.CountyAPN__c=opp.CountyAPN__c;
                        property.County_Name__c=opp.County__c;
                        property.APN_Formatted__c=opp.APN_Formatted__c;
                        property.APN_Unformatted__c=opp.APN_Unformatted__c;
                        property.Property_legal_description__c=opp.Property_Legal_Description__c;
                        
                        property.Property_Number__c=opp.Property_Number__c;
                        property.Lot_Acreage__c=opp.Lot_Acreage__c;
                        //property.Total_Gross_Margin__c=opp.Total_Gross_Margin__c;
                        property.Acreage__c=opp.Acreage__c;
                        property.Zoning_Data_Tree_Export__c=opp.Zoning_Data_Tree_Export__c;
                        property.Situs_Street_Address__c=opp.Situs_Street_Address__c;
                        property.Situs_City__c=opp.Situs_City__c;
                        property.Situs_State__c=opp.Situs_State__c;
                        property.Situs_Zip_Code__c=opp.Situs_Zip_Code__c;
                        property.Situs_Street_Name__c=opp.Situs_Street__c;
                        property.Situs_Full_Address__c=opp.Situs_Full_Address__c;
                        property.Assessed_Land_Value__c=opp.Assessed_Land_Value__c;
                        property.Market_Land_Value__c=opp.Market_Land_Value__c;
                    }
                }
            }
            if (preventRecursion.propertiesUpdated == false){
                try{
                    update topPropertiesToUpdate;
                }catch (Exception e){
                    throw new AuraHandledException(e.getMessage());
                }
            } 
        }
        
    }
}