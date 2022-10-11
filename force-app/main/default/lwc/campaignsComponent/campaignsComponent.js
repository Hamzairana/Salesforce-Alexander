import { LightningElement,api,track } from 'lwc';
import getCampaigns from '@salesforce/apex/CampaignController.getCampaigns';
export default class CampaignsComponent extends LightningElement {
    @api recordId;
    relatedCampaignsToOffer;
    @track areDetailsVisible=false;
    showLoading = false;
    relatedCampaignsCallback() {
        this.areDetailsVisible = true;
        this.showLoading = true;
        getCampaigns({
            campaignId: this.recordId
        }).then((campaigns) => {    
            this.showLoading = false;
            this.relatedCampaignsToOffer = campaigns;
            if(this.relatedCampaignsToOffer.length>0){
                this.areDetailsVisible = true;
                console.log('Details: ' + this.areDetailsVisible);
            }
            else{
                this.areDetailsVisible = false;
            }
            console.log('Related Campaigns To Offer: ' + JSON.stringify(this.relatedCampaignsToOffer));
        }).catch((error) => {
            console.log("Error occurred: " + error);
        });
    }
    connectedCallback(){
        this.relatedCampaignsCallback();
    }


}