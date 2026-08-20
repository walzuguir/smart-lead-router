trigger LeadTrigger on Lead (before insert, before update, after insert) {
    if (Trigger.isBefore) {
        LeadTriggerHandler.handle(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        LeadTriggerHandler.enqueueEnrichment(Trigger.new);
    }
}