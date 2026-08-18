trigger LeadTrigger on Lead (before insert, before update) {
    LeadTriggerHandler.handle(Trigger.new);
}