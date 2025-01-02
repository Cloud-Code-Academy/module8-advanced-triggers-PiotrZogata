public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    private List <Opportunity> newOpportunities;
    private Map <Id, Opportunity> newOpportunityMap;
    private List <opportunity> oldOpportunities;
    private Map <Id, Opportunity> oldOpportunityMap;

    public OpportunityTriggerHandler() {
        this.newOpportunities = (List<Opportunity>) Trigger.new;
        this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOpportunities = (List<Opportunity>) Trigger.old;
        this.oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void beforeInsert(){
        for(Opportunity opp : this.newOpportunities) {
            if (opp.Type == null){
                opp.Type = 'New Customer';
            }
        }   
    }

    public override void beforeUpdate(){
        for(Opportunity opp : this.newOpportunities){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }

        // When an opportunity is updated set the primary contact on the opportunity to the contact with the title of 'CEO'.   
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity opp : this.newOpportunities){
            accountIds.add(opp.AccountId);
            }
            Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
            Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

            for (Contact cont : contacts.values()) {
            if (!accountIdToContact.containsKey(cont.AccountId)) {
                accountIdToContact.put(cont.AccountId, cont);
            }
            }

            for(Opportunity opp : this.newOpportunities){
            if(opp.Primary_Contact__c == null){
                if (accountIdToContact.containsKey(opp.AccountId)){
                    opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                }
            } 
            }
    }

     public override void beforeDelete(){
        //When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :this.oldOpportunities)]);
        for(Opportunity opp : this.oldOpportunities){
            if(opp.StageName == 'Closed Won'){
                if(accounts.get(opp.AccountId).Industry == 'Banking'){
                    opp.addError('Cannot delete closed opportunity');
                }
            }
        }

        // Prevent deletion of closed Opportunities it is from anotherOpportunity trigger
        for (Opportunity oldOpp : this.oldOpportunities){
                if (oldOpp.IsClosed){
                    oldOpp.addError('Cannot delete closed opportunity');
                }
            }
    }
    
    public override void afterInsert(){
                //Create a new Task for newly inserted Opportunities IT's from another Opportunity trigger
                List<Task> listOfTask = new List<Task>();
                for (Opportunity opp : this.newOpportunities){
                    Task tsk = new Task();
                    tsk.Subject = 'Call Primary Contact';
                    tsk.WhatId = opp.Id;
                    tsk.WhoId = opp.Primary_Contact__c;
                    tsk.OwnerId = opp.OwnerId;
                    tsk.ActivityDate = Date.today().addDays(3);
                    listOfTask.add(tsk);
                }
                insert listOfTask;
    }

    public override void afterUpdate(){
        // Append Stage changes in Opportunity Description from AnotherOpportuiityTrigger
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            for (Opportunity opp : this.newOpportunities){       
                Opportunity oldOpp = this.oldOpportunityMap.get(opp.Id); 
                if (opp.StageName != oldOpp.StageName && opp.StageName != null){ 
                    Opportunity updatedOpp = new Opportunity( Id = opp.Id, Description = (oldOpp.Description != null ? oldOpp.Description : '') + '\nStage Change:' +
                    opp.StageName + ' : ' + DateTime.now().format() );
                    opportunitiesToUpdate.add(updatedOpp);
                } 
            }
            if(!opportunitiesToUpdate.isEmpty()){
                update opportunitiesToUpdate;
            }
     }

    public override void afterDelete(){
            OpportunityHelper.notifyOwnersOpportunityDeleted(this.oldOpportunities);
        }

    public override void afterUndelete(){
            OpportunityHelper.assignPrimaryContact(this.newOpportunityMap);
        }


         /*
    notifyOwnersOpportunityDeleted:
    - Sends an email notification to the owner of the Opportunity when it gets deleted.
    - Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    */
    // private static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
    //     List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    //     Set<Id>ownersIds = new Set<Id>();
    //     for(Opportunity opp : opps){
    //          ownersIds.add(opp.OwnerId);
    //     }
    //     Map<Id, User> ownersEmailMap = new Map<Id, User>([Select Id, Email FROM User WHERE Id IN :ownersIds]);
    //     for (Opportunity opp : opps){
    //         User owner = ownersEmailMap.get(opp.OwnerId);
    //         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //         String[] toAddresses = new String[] {owner.Email};
    //         mail.setToAddresses(toAddresses);
    //         mail.setSubject('Opportunity Deleted : ' + opp.Name);
    //         mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
    //         mails.add(mail);
    //     }        
        
    //     try {
    //         Messaging.sendEmail(mails);
    //     } catch (Exception e){
    //         System.debug('Exception: ' + e.getMessage());
    //     }
    // }

    /*
    assignPrimaryContact:
    - Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities.
    - Only updates the Opportunities that don't already have a primary contact.
    */
    // private static void assignPrimaryContact(Map<Id, Opportunity> oppNewMap) {
    //     // Collect Account IDs from Opportunities
    //     Set<Id> accountIds = new Set<Id>();
    //     for (Opportunity opp : oppNewMap.values()) {
    //         if (opp.AccountId != null) {
    //             accountIds.add(opp.AccountId);
    //         }
    //     }
    
    //     // Query Contacts with the title 'VP Sales' for the related Accounts
    //     Map<Id, Contact> accountToContactMap = new Map<Id, Contact>();
    //     for (Contact contact : [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales' AND AccountId IN :accountIds]) {
    //         accountToContactMap.put(contact.AccountId, contact);
    //     }
    
    //     // List to store Opportunities that need updates
    //     List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    
    //     // Assign Primary Contact to Opportunities
    //     for (Opportunity opp : oppNewMap.values()) {
    //         if (opp.Primary_Contact__c == null && opp.AccountId != null && accountToContactMap.containsKey(opp.AccountId)) {
    //             Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
    //             oppToUpdate.Primary_Contact__c = accountToContactMap.get(opp.AccountId).Id;
    //             opportunitiesToUpdate.add(oppToUpdate);
    //         }
    //     }
    
    //     // Update the Opportunities with the new primary contacts
    //     if (!opportunitiesToUpdate.isEmpty()) {
    //         update opportunitiesToUpdate;
    //     }
    // }
}
