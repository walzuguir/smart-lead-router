public with sharing class LeadTriggerHandler {

    public static void handle(List<Lead> newLeads) {
        LeadScoringService.scoreLeads(newLeads);
        LeadAssignmentService.assignLeads(newLeads);
    }

}