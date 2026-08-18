@isTest
private class LeadScoringServiceTest {

    @isTest
    static void testHotLead() {
        // Arrange: empresa grande, com email e telefone → deve dar 100 (Hot)
        Lead hot = new Lead(
            LastName = 'Hot Lead',
            Company = 'Big Corp',
            NumberOfEmployees = 600,
            Email = 'hot@example.com',
            Phone = '11999999999'
        );
        List<Lead> leads = new List<Lead>{ hot };

        // Act
        Test.startTest();
        LeadScoringService.scoreLeads(leads);
        Test.stopTest();

        // Assert
        System.assertEquals(100, leads[0].Lead_Score__c, 'Score deveria ser 100');
        System.assertEquals('Hot', leads[0].Lead_Temperature__c, 'Deveria ser Hot');
    }

    @isTest
    static void testWarmLead() {
        // Arrange: empresa média, sem contato → deve dar 40 (Warm)
        Lead warm = new Lead(
            LastName = 'Warm Lead',
            Company = 'Mid Corp',
            NumberOfEmployees = 150
        );
        List<Lead> leads = new List<Lead>{ warm };

        // Act
        Test.startTest();
        LeadScoringService.scoreLeads(leads);
        Test.stopTest();

        // Assert
        System.assertEquals(40, leads[0].Lead_Score__c, 'Score deveria ser 40');
        System.assertEquals('Warm', leads[0].Lead_Temperature__c, 'Deveria ser Warm');
    }

    @isTest
    static void testColdLead() {
        // Arrange: empresa pequena, só email → deve dar 20 (Cold)
        Lead cold = new Lead(
            LastName = 'Cold Lead',
            Company = 'Tiny Corp',
            NumberOfEmployees = 10,
            Email = 'cold@example.com'
        );
        List<Lead> leads = new List<Lead>{ cold };

        // Act
        Test.startTest();
        LeadScoringService.scoreLeads(leads);
        Test.stopTest();

        // Assert
        System.assertEquals(20, leads[0].Lead_Score__c, 'Score deveria ser 20');
        System.assertEquals('Cold', leads[0].Lead_Temperature__c, 'Deveria ser Cold');
    }
}