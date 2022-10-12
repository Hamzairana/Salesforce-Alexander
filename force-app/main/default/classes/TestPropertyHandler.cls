@isTest
public class TestPropertyHandler {
    @testSetup static void createTestData() {
        
        Account testingAccount = new Account(Name='Testing Account');
        insert testingAccount;
        
        Account testingAccount1 = new Account(Name='Testing Account 1');
        insert testingAccount1;
        
        Opportunity testingOpportunity = new Opportunity(AccountId=testingAccount.Id, External_Id__c ='Ext1', 
                                                         Name='Testing Opportunity', StageName = 'Prospects', CloseDate = date.parse('9/19/2022'));
        insert testingOpportunity;
        
        Opportunity testingOpportunity1 = new Opportunity(AccountId=testingAccount1.Id, External_Id__c ='Ext2', Name='Testing Opportunity 1', 
                                                          StageName = 'Prospects', CloseDate = date.parse('9/26/2022'));
        insert testingOpportunity1;
        
        List<Property__c> properties = new List<Property__c>();
        
        for (Integer i=0; i<3;i++){
            properties.add(new Property__c(OpportunityId__c=testingOpportunity.Id, 
                                           Name='Testing Properties'+i,    
                                           CountyAPN__c='Pender' + i, 
                                           Sold_Price__c = 1000, 
                                           Sell_Side_Total_Settlement_Charges__c = 200, 
                                           Buy_Side_Soil_Evaluation__c = 200,
                                           Buy_Side_Survey_Cost__c = 200, 
                                           Buy_Side_Purchase_Price__c = 10, 
                                           Buy_Side_Legal_Fees_Closing__c = 10, 
                                           Buy_Side_Legal_Fees_Due_Diligence__c = 10, 
                                           Buy_Side_Title_Insurance__c = 10,
                                           Buy_Side_HOA_Fees__c = 10, 
                                           Buy_Side_Commissions__c = 200, 
                                           Buy_Side_Property_Taxes__c = 30,
                                           Buy_Side_Wire_Fee__c = 20,
                                           List_Price_Estimated_Price__c = 1000));
        }
        
        insert properties;
        
        Property__c prop = [Select id, opportunityId__c from Property__c where Name='Testing Properties2' limit 1];
        prop.opportunityId__c = testingOpportunity1.Id;
        update prop;
        
        Campaign camp= new Campaign(Name='Testing Campaign');
        insert camp;
        
        Offer__c offer = new Offer__c(PropertyId__c = properties[0].Id, CampaignId__c = camp.Id, Name = 'Testing Offer', 
                                      Offer_Status__c = 'Offer Accepted');
        insert offer;
        
        
    }
    @isTest static void testGetProperties(){
        List <Property__c> properties;  
        properties = [Select Id, OpportunityId__c, Name, CountyAPN__c, Total_Cash_Margin__c, 
                      List_Price_Estimated_Price__c, 
                      Expected_Revenue__c, Expected_Gross_Profit__c, 
                      Expected_Gross_Margin__c, OpportunityId__r.Sum_of_List_Price_Estimated_Price__c, 
                      OpportunityId__r.Sum_of_Expected_Gross_Profit__c,
                      OpportunityId__r.Sum_of_Expected_Revenue__c,
                      OpportunityId__r.Average_of_Expected_Gross_Margin__c
                      FROM Property__c LIMIT 1];
        
        Test.startTest();
        PropertyHandler.updateCalculationsOnCampaigns(new Set<Id> {properties[0].Id});
        Test.stopTest();
        
        system.assertEquals(100, properties[0].Total_Cash_Margin__c);
        system.assertEquals(800, properties[0].Expected_Revenue__c);
        system.assertEquals('Pender0', properties[0].CountyAPN__c);
        system.assertEquals(3000, properties[0].OpportunityId__r.Sum_of_List_Price_Estimated_Price__c);
        system.assertEquals(300, properties[0].OpportunityId__r.Sum_of_Expected_Gross_Profit__c);
        system.assertEquals(2400, properties[0].OpportunityId__r.Sum_of_Expected_Revenue__c);
        system.assertEquals(12.5, properties[0].OpportunityId__r.Average_of_Expected_Gross_Margin__c);
        delete properties;
    }    
}