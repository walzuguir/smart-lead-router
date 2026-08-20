@isTest
private class LeadEnrichmentServiceTest {

    @isTest
    static void testEnrichmentUpdatesLeadAndRescores() {
        Lead lead = new Lead(LastName = 'Enrich Me', Company = 'Enrich Corp');
        insert lead;

        Test.setMock(HttpCalloutMock.class, new LeadEnrichmentMock(
            200,
            '{"args": {"employees": "850"}}'
        ));

        Test.startTest();
        System.enqueueJob(new LeadEnrichmentService(new List<Id>{ lead.Id }));
        Test.stopTest();

        Lead enriched = [
            SELECT NumberOfEmployees, Lead_Score__c, Lead_Temperature__c
            FROM Lead
            WHERE Id = :lead.Id
        ];
        System.assertEquals(850, enriched.NumberOfEmployees, 'Deveria ter enriquecido com 850 funcionários');
        System.assertEquals(60, enriched.Lead_Score__c, 'Score deveria recalcular para 60 (apenas tamanho)');
        System.assertEquals('Warm', enriched.Lead_Temperature__c, 'Deveria virar Warm após o enriquecimento');
    }

    @isTest
    static void testEnrichmentFailureDoesNotBreakLead() {
        Lead lead = new Lead(LastName = 'Enrich Fail', Company = 'Fail Corp');
        insert lead;

        Test.setMock(HttpCalloutMock.class, new LeadEnrichmentMock(
            503,
            'Service Unavailable'
        ));

        Test.startTest();
        System.enqueueJob(new LeadEnrichmentService(new List<Id>{ lead.Id }));
        Test.stopTest();

        Lead unchanged = [SELECT NumberOfEmployees FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(null, unchanged.NumberOfEmployees, 'Falha na API não deveria alterar o lead');
    }
}