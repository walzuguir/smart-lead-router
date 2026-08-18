public with sharing class LeadAssignmentService {

    public static void assignLeads(List<Lead> leads) {
        Id defaultOwnerId = getDefaultOwnerId();
        if (defaultOwnerId == null) {
            return;
        }
        for (Lead lead : leads) {
            lead.OwnerId = defaultOwnerId;
        }
    }

        private static Id getDefaultOwnerId() {
        return UserInfo.getUserId();
    }
}