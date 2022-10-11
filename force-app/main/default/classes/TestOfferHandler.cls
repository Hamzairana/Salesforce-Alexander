@isTest
public class TestOfferHandler {
    @testSetup static void createTestData() {
        Property__c property = new Property__c(Name='Testing Property', CountyAPN__c='Testing12345', Sold_Price__c = 1000, 
                                               Sell_Side_Total_Settlement_Charges__c = 200, Buy_Side_Soil_Evaluation__c = 200,
                                              Buy_Side_Survey_Cost__c = 200, 
                                              Buy_Side_Purchase_Price__c = 10, Buy_Side_Legal_Fees_Closing__c = 10, 
                                               Buy_Side_Legal_Fees_Due_Diligence__c = 10, Buy_Side_Title_Insurance__c = 10,
                                               Buy_Side_HOA_Fees__c = 10, Buy_Side_Commissions__c = 200, Buy_Side_Property_Taxes__c = 30,
                                               Buy_Side_Wire_Fee__c = 20
                                              );
        insert property;
        Campaign camp= new Campaign(Name='Testing Campaign');
        insert camp;
        Offer__c offer = new Offer__c(PropertyId__c = property.Id, CampaignId__c = camp.Id, Name = 'Testing Offer', 
                                      Offer_Status__c = 'Offer Accepted');
        insert offer;
    }
    @isTest static void testGetOffers(){
        List<Offer__c> offers = [Select Id, Name, propertyId__c, CampaignId__c, propertyId__r.Total_Cash_Margin__c, 
                                 CampaignId__r.Sum_Total_Cash_Margin__c from Offer__c];
        System.assertEquals(100,offers[0].campaignId__r.Sum_Total_Cash_Margin__c); 
    }    
}