({
    handleSelect: function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        if (stepName == 'Open ITC') {
            let action = component.get("c.getOpportunityRelatedAccount");
            action.setParams({
                "opportunityId": component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                console.log('State: ' + state);
                if (state === "SUCCESS") {
                    var accountId = response.getReturnValue().AccountId;
                    if (accountId) {
                        var sfBaseURL = window.location.origin;
                        window.open(sfBaseURL + "/lightning/r/Account/" + accountId + "/view");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Toast from " + stepName
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})