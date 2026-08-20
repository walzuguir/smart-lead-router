public with sharing class LeadTriggerHandler {

    public static void handle(List<Lead> newLeads) {
        LeadScoringService.scoreLeads(newLeads);
        LeadAssignmentService.assignLeads(newLeads);
    }

    public static void enqueueEnrichment(List<Lead> insertedLeads) {
        List<Id> leadIds = new List<Id>();
        for (Lead lead : insertedLeads) {
            leadIds.add(lead.Id);
        }
        System.enqueueJob(new LeadEnrichmentService(leadIds));
    }

}