public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    private List <Opportunity> newOpportunities;
    private Map <Id, Opportunity> newOpportunityMap;
    private List <opportunity> oldOpportunities;
    private Map <Id, Opportunity> oldOppottunityMap;

    public OpportunityTriggerHandler() {
        this.newOpportunities = (List<Opportunity>) Trigger.new;
        this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOpportunities = (List<Opportunity>) Trigger.old;
        this.oldOppottunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

}