public with sharing class OpportunityHelper {
    // public OpportunityHelper() {
    // }

    public static List<Task> createTaskForOpportunities(List <Opportunity> newOpportunities){
        List<Task> listOfTask = new List<Task>();
        for (Opportunity opp : newOpportunities){
        Task tsk = new Task();
        tsk.Subject = 'Call Primary Contact';
        tsk.WhatId = opp.Id;
        tsk.WhoId =  opp.Primary_Contact__c;
        tsk.OwnerId = opp.OwnerId;
        tsk.ActivityDate = Date.today().addDays(3);
        listOfTask.add(tsk);
        }
        return listOfTask;
    }

    public static List <Opportunity> makeChangeInOppDescription(List <Opportunity> oppList, Map <Id, Opportunity> oldOppMap){
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for(Opportunity opp : oppList){
        Opportunity oldOpp = oldOppMap.get(opp.Id);
        Opportunity updatedOpp = new Opportunity( Id = opp.Id, Description = (oldOpp.Description != null ? oldOpp.Description : '') + '\nStage Change:' +
        opp.StageName + ' : ' + DateTime.now().format() );
        opportunitiesToUpdate.add(updatedOpp);
        }
        return opportunitiesToUpdate;
    }

    

    /*
    notifyOwnersOpportunityDeleted:
    - Sends an email notification to the owner of the Opportunity when it gets deleted.
    - Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    */
    public static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id>ownersIds = new Set<Id>();
        for(Opportunity opp : opps){
             ownersIds.add(opp.OwnerId);
        }
        Map<Id, User> ownersEmailMap = new Map<Id, User>([Select Id, Email FROM User WHERE Id IN :ownersIds]);
        for (Opportunity opp : opps){
            User owner = ownersEmailMap.get(opp.OwnerId);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {owner.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    /*
    assignPrimaryContact:
    - Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities.
    - Only updates the Opportunities that don't already have a primary contact.
    */
    public static void assignPrimaryContact(Map<Id, Opportunity> oppNewMap) {
        // Collect Account IDs from Opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : oppNewMap.values()) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
    
        // Query Contacts with the title 'VP Sales' for the related Accounts
        Map<Id, Contact> accountToContactMap = new Map<Id, Contact>();
        for (Contact contact : [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales' AND AccountId IN :accountIds]) {
            accountToContactMap.put(contact.AccountId, contact);
        }
    
        // List to store Opportunities that need updates
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    
        // Assign Primary Contact to Opportunities
        for (Opportunity opp : oppNewMap.values()) {
            if (opp.Primary_Contact__c == null && opp.AccountId != null && accountToContactMap.containsKey(opp.AccountId)) {
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = accountToContactMap.get(opp.AccountId).Id;
                opportunitiesToUpdate.add(oppToUpdate);
            }
        }
    
        //Update the Opportunities with the new primary contacts
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }  
}