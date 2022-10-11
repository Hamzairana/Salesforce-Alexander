import { LightningElement, wire, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getActiveRelatedContacts from '@salesforce/apex/AccountController.getActiveRelatedContacts';
import getCountOfActiveContacts from '@salesforce/apex/AccountController.getCountOfActiveContacts';

export default class ActiveContactsRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @track deleteModal = false;
    @track error;
    activeContacts;
    areDetailsVisible;
    activeContactsCount;
    footerComponent = false;
    maxContactsToDisplay = false;
    selectedContactId;
    sfBaseURL;
    viewAllLink;

    openDeleteModal(event) {
        this.selectedContactId = event.target.dataset.id;
        this.deleteModal = true;
    }

    closeDeleteModal() {
        this.deleteModal = false;
    }

    deleteActiveContact() {
        deleteRecord(this.selectedContactId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                this.closeDeleteModal();
                refreshApex(this.connectedCallback());
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    getCountOfActiveContactsCallBack() {
        getCountOfActiveContacts({
            accountId: this.recordId
        }).then((count) => {
            this.activeContactsCount = count;
            this.maxContactsToDisplay = count > 6;
        }).catch((error) => {
            console.log("Error occurred: " + error);
        })
    }
    
    ActiveContactsCallback() {
        getActiveRelatedContacts({
            accountId: this.recordId
        }).then((contacts) => {
            this.areDetailsVisible = true;
            this.activeContacts = contacts.map(contactsTemp => ({
                href: `/${contactsTemp.Id}`, ...contactsTemp
            }));
            if (this.activeContacts.length == 0) {
                this.footerComponent = false;
            }
            else {
                this.footerComponent = true;
            }
        }).catch((error) => {
            console.log("Error occurred: " + error);
        });
    }

    viewAllFunction() {
        this.sfBaseURL = window.location.origin;
        this.viewAllLink = this.sfBaseURL + "/lightning/r/Account/" + this.recordId + "/related/Contacts/view";
    }

    connectedCallback() {
        this.getCountOfActiveContactsCallBack();
        this.ActiveContactsCallback();
        this.viewAllFunction();
    }

    refreshPage() {
        this.getCountOfActiveContactsCallBack();
        this.ActiveContactsCallback();
    }

    navigateToEditContactPage(event) {
        const selectedContactId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedContactId,
                objectApiName: 'Contact',
                actionName: 'edit'
            }
        });
    }
    navigateToNewRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
            state: {
                navigationLocation: "RELATED_LIST",
                defaultFieldValues: "AccountId=" + this.recordId
            }
        });
    }
}