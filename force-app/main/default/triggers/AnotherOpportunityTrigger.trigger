/*
AnotherOpportunityTrigger Overview

This trigger was initially created for handling various events on the Opportunity object. It was developed by a prior developer and has since been noted to cause some issues in our org.

IMPORTANT:
- This trigger does not adhere to Salesforce best practices.
- It is essential to review, understand, and refactor this trigger to ensure maintainability, performance, and prevent any inadvertent issues.

ISSUES:
Avoid nested for loop - 1 instance
Avoid DML inside for loop - 1 instance
Bulkify Your Code - 1 instance
Avoid SOQL Query inside for loop - 2 instances
Stop recursion - 1 instance

RESOURCES: 
https://www.salesforceben.com/12-salesforce-apex-best-practices/
https://developer.salesforce.com/blogs/developer-relations/2015/01/apex-best-practices-15-apex-commandments
*/
trigger AnotherOpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    // if (Trigger.isBefore){
    //     if (Trigger.isInsert){
    //         // Set default Type for new Opportunities
    //         for(Opportunity opp : Trigger.new) {
    //             if (opp.Type == null){
    //                 opp.Type = 'New Customer';
    //             }
    //         }        
    //     } else if (Trigger.isDelete){
    //         // Prevent deletion of closed Opportunities
    //         for (Opportunity oldOpp : Trigger.old){
    //             if (oldOpp.IsClosed){
    //                 oldOpp.addError('Cannot delete closed opportunity');
    //             }
    //         }
    //     }
    // }

    //tu
    // if (Trigger.isAfter){
    //     if (Trigger.isInsert){
    //         // Create a new Task for newly inserted Opportunities
    //         List<Task> listOfTask = new List<Task>();
    //         for (Opportunity opp : Trigger.new){
    //             Task tsk = new Task();
    //             tsk.Subject = 'Call Primary Contact';
    //             tsk.WhatId = opp.Id;
    //             tsk.WhoId = opp.Primary_Contact__c;
    //             tsk.OwnerId = opp.OwnerId;
    //             tsk.ActivityDate = Date.today().addDays(3);
    //             listOfTask.add(tsk);
    //         }
    //         insert listOfTask;
    //     } else if (Trigger.isUpdate){
    //         // Append Stage changes in Opportunity Description
    //         List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    //         for (Opportunity opp : Trigger.new){       
    //             Opportunity oldOpp = Trigger.oldMap.get(opp.Id); 
    //             if (opp.StageName != oldOpp.StageName && opp.StageName != null){ 
    //                 Opportunity updatedOpp = new Opportunity( Id = opp.Id, Description = (oldOpp.Description != null ? oldOpp.Description : '') + '\nStage Change:' +
    //                 opp.StageName + ' : ' + DateTime.now().format() );
    //                 opportunitiesToUpdate.add(updatedOpp);
    //             } 
    //         }
    //         if(!opportunitiesToUpdate.isEmpty()){
    //             update opportunitiesToUpdate;
    //         }
    //     }
        
        
    //     //Send email notifications when an Opportunity is deleted 
    //     else if (Trigger.isDelete){
    //         notifyOwnersOpportunityDeleted(Trigger.old);
    //     } 
        
        
    //     //Assign the primary contact to undeleted Opportunities
    //     else if (Trigger.isUndelete){
    //         assignPrimaryContact(Trigger.newMap);
    //     }
    // }

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
    
        // Update the Opportunities with the new primary contacts
    //     if (!opportunitiesToUpdate.isEmpty()) {
    //         update opportunitiesToUpdate;
    //     }
    // }
    
    }