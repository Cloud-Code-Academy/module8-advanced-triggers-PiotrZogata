public with sharing class OpportunityHelper {
    // public OpportunityHelper() {
    // }

    // When an opportunity is updated set the primary contact on the opportunity to the contact with the title of 'CEO'.   
    //       Set<Id> accountIds = new Set<Id>();
    //     for(Opportunity opp : Trigger.new){
    //         accountIds.add(opp.AccountId);
    //     }
        
    //     Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
    //     Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

    //     for (Contact cont : contacts.values()) {
    //         if (!accountIdToContact.containsKey(cont.AccountId)) {
    //             accountIdToContact.put(cont.AccountId, cont);
    //         }
    //     }

    //     for(Opportunity opp : Trigger.new){
    //         if(opp.Primary_Contact__c == null){
    //             if (accountIdToContact.containsKey(opp.AccountId)){
    //                 opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
    //             }
    //         } 

    public static void updatePrimaryContact(List<Opportunity> opportunities) {
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity opp : opportunities){
                accountIds.add(opp.AccountId);
            }
        
            Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
            Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

            for (Contact cont : contacts.values()) {
                if (!accountIdToContact.containsKey(cont.AccountId)) {
                    accountIdToContact.put(cont.AccountId, cont);
                }
            }

            for(Opportunity opp : opportunities){
                if(opp.Primary_Contact__c == null){
                    if (accountIdToContact.containsKey(opp.AccountId)){
                        opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                }
            } 
        }
    }

    //two methods below from ANOTHEROPPORTUNITYTRIGGER
    /*
    notifyOwnersOpportunityDeleted:
    - Sends an email notification to the owner of the Opportunity when it gets deleted.
    - Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    */
    // public static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
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
    // public static void assignPrimaryContact(Map<Id, Opportunity> oppNewMap) {
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