@isTest
private class LeadTriggerTest {

    @isTest
    static void testSingleLeadIsScoredAndAssignedOnInsert() {
        // Arrange
        Lead lead = TestDataFactory.buildHotLeads(1)[0];

        // Act — insert dispara o trigger de verdade
        Test.startTest();
        insert lead;
        Test.stopTest();

        // Assert — relê do banco para confirmar o que foi gravado
        Lead saved = [
            SELECT Lead_Score__c, Lead_Temperature__c, OwnerId
            FROM Lead
            WHERE Id = :lead.Id
        ];
        System.assertEquals(100, saved.Lead_Score__c, 'Deveria pontuar 100');
        System.assertEquals('Hot', saved.Lead_Temperature__c, 'Deveria ser Hot');
        System.assertEquals(UserInfo.getUserId(), saved.OwnerId, 'Dono deveria ser o usuário atual');
    }

    @isTest
    static void testBulkInsertOf200Leads() {
        // Arrange — 200 de uma vez, o cenário que quebra trigger mal feito
        List<Lead> leads = TestDataFactory.buildHotLeads(200);

        // Act
        Test.startTest();
        insert leads;
        Test.stopTest();

        // Assert — todos pontuados corretamente
        List<Lead> saved = [
            SELECT Lead_Score__c, Lead_Temperature__c
            FROM Lead
            WHERE Company LIKE 'Bulk Corp%'
        ];
        System.assertEquals(200, saved.size(), 'Deveria ter 200 leads');
        for (Lead l : saved) {
            System.assertEquals(100, l.Lead_Score__c, 'Cada lead deveria pontuar 100');
            System.assertEquals('Hot', l.Lead_Temperature__c, 'Cada lead deveria ser Hot');
        }
    }
}