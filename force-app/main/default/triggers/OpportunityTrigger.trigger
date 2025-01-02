/*
OpportunityTrigger Overview

This class defines the trigger logic for the Opportunity object in Salesforce. It focuses on three main functionalities:
1. Ensuring that the Opportunity amount is greater than $5000 on update.
2. Preventing the deletion of a 'Closed Won' Opportunity if the related Account's industry is 'Banking'.
3. Setting the primary contact on an Opportunity to the Contact with the title 'CEO' when updating.

Usage Instructions:
For this lesson, students have two options:
1. Use the provided `OpportunityTrigger` class as is.
2. Use the `OpportunityTrigger` from you created in previous lessons. If opting for this, students should:
    a. Copy over the code from the previous lesson's `OpportunityTrigger` into this file.
    b. Save and deploy the updated file into their Salesforce org.

Remember, whichever option you choose, ensure that the trigger is activated and tested to validate its functionality.
*/
trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {



    switch on  Trigger.OperationType {
        when BEFORE_INSERT {
          
            // Set default Type for new Opportunities it's from anotherOpportunity trigger
            // for(Opportunity opp : Trigger.new) {
            //     if (opp.Type == null){
            //         opp.Type = 'New Customer';
            //     }
            // }        
        }

        when BEFORE_UPDATE {
            //When an opportunity is updated validate that the amount is greater than 5000.
            // for(Opportunity opp : Trigger.new){
            //              if(opp.Amount < 5000){
            //                  opp.addError('Opportunity amount must be greater than 5000');
            //              }
            // }
            
            // When an opportunity is updated set the primary contact on the opportunity to the contact with the title of 'CEO'.   
            // Set<Id> accountIds = new Set<Id>();
            // for(Opportunity opp : Trigger.new){
            // accountIds.add(opp.AccountId);
            // }
            // Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
            // Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

            // for (Contact cont : contacts.values()) {
            // if (!accountIdToContact.containsKey(cont.AccountId)) {
            //     accountIdToContact.put(cont.AccountId, cont);
            // }
            // }

            // for(Opportunity opp : Trigger.new){
            // if(opp.Primary_Contact__c == null){
            //     if (accountIdToContact.containsKey(opp.AccountId)){
            //         opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
            //     }
            // } 
            // }
        }

        
        when BEFORE_DELETE {
        //When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
        // Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :Trigger.old)]);
        //  for(Opportunity opp : Trigger.old){
        //      if(opp.StageName == 'Closed Won'){
        //          if(accounts.get(opp.AccountId).Industry == 'Banking'){
        //              opp.addError('Cannot delete closed opportunity');
        //          }
        //      }
        //  }

        // Prevent deletion of closed Opportunities it's from anotherOpportunity trigger
                    // for (Opportunity oldOpp : Trigger.old){
                    //     if (oldOpp.IsClosed){
                    //         oldOpp.addError('Cannot delete closed opportunity');
                    //     }
                    // }
    }

    
        //when AFTER_INSERT {
            //AnotherOpportunityTrigger 3
            // Create a new Task for newly inserted Opportunities
            // List<Task> listOfTask = new List<Task>();
            // for (Opportunity opp : Trigger.new){
            //     Task tsk = new Task();
            //     tsk.Subject = 'Call Primary Contact';
            //     tsk.WhatId = opp.Id;
            //     tsk.WhoId = opp.Primary_Contact__c;
            //     tsk.OwnerId = opp.OwnerId;
            //     tsk.ActivityDate = Date.today().addDays(3);
            //     listOfTask.add(tsk);
        //}

        
        //}
        when AFTER_UPDATE {
            //AnotherOpportunityTrigger 3
            // Append Stage changes in Opportunity Description
            // List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            // for (Opportunity opp : Trigger.new){       
            //     Opportunity oldOpp = Trigger.oldMap.get(opp.Id); 
            //     if (opp.StageName != oldOpp.StageName && opp.StageName != null){ 
            //         Opportunity updatedOpp = new Opportunity( Id = opp.Id, Description = (oldOpp.Description != null ? oldOpp.Description : '') + '\nStage Change:' +
            //         opp.StageName + ' : ' + DateTime.now().format() );
            //         opportunitiesToUpdate.add(updatedOpp);
            //     } 
            // }
            // if(!opportunitiesToUpdate.isEmpty()){
            //     update opportunitiesToUpdate;
            // }
        }
        when AFTER_DELETE {
            //AnotherOpportunityTrigger 3
            //notifyOwnersOpportunityDeleted(Trigger.old);
        }
        when AFTER_UNDELETE {
            //AnotherOpportunityTrigger 3
            //assignPrimaryContact(Trigger.newMap);
        }
    }
    

    /*
    notifyOwnersOpportunityDeleted:
    - Sends an email notification to the owner of the Opportunity when it gets deleted.
    - Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    */
    private static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Opportunity opp : opps){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {[SELECT Id, Email FROM User WHERE Id = :opp.OwnerId].Email};
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
    private static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for (Opportunity opp : oppNewMap.values()){            
            Contact primaryContact = [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales' AND AccountId = :opp.AccountId LIMIT 1];
            if (opp.Primary_Contact__c == null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = primaryContact.Id;
                oppMap.put(opp.Id, oppToUpdate);
            }
        }
        update oppMap.values();
    }

    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    handler.run();
}