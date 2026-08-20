public with sharing class LeadEnrichmentService implements Queueable, Database.AllowsCallouts {

    private List<Id> leadIds;

    public LeadEnrichmentService(List<Id> leadIds) {
        this.leadIds = leadIds;
    }

    public void execute(QueueableContext context) {
        List<Lead> leadsToUpdate = new List<Lead>();

        for (Id leadId : leadIds) {
            Integer employeeCount = fetchEmployeeCount(leadId);
            if (employeeCount != null) {
                leadsToUpdate.add(new Lead(
                    Id = leadId,
                    NumberOfEmployees = employeeCount
                ));
            }
        }

        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
    private Integer fetchEmployeeCount(Id leadId) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Company_Enrichment_API/get?employees=850');
            req.setMethod('GET');
            req.setTimeout(5000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> args = (Map<String, Object>) body.get('args');
                if (args != null && args.get('employees') != null) {
                    return Integer.valueOf((String) args.get('employees'));
                }
            }
        } catch (Exception e) {
            System.debug('Enrichment failed for lead ' + leadId + ': ' + e.getMessage());
        }
        return null;
    }
}