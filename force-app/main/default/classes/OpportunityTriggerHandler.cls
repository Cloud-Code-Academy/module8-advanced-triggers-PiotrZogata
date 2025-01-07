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
        //OpportunityHelper.updatePrimaryContactIfTitleCeo(this.newOpportunities);
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
        List <Task> listOfTask = OpportunityHelper.createTaskForOpportunities(this.newOpportunities);
        insert listOfTask;
    }

    public override void afterUpdate(){
        // Append Stage changes in Opportunity Description from AnotherOpportuiityTrigger
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            for (Opportunity opp : this.newOpportunities){       
                Opportunity oldOpp = this.oldOpportunityMap.get(opp.Id); 
                if (opp.StageName != oldOpp.StageName && opp.StageName != null){ 
                    opportunitiesToUpdate = OpportunityHelper.makeChangeInOppDescription(this.newOpportunities, this.oldOpportunityMap);
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
}
