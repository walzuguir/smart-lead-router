public with sharing class LeadDashboardController {
    @AuraEnabled(cacheable=true)
    public static List<Lead> getScoredLeads() {
        return [
            SELECT Id, Name, Company, Lead_Score__c, Lead_Temperature__c
            FROM Lead
            WHERE Lead_Score__c != null
            ORDER BY Lead_Score__c DESC
            LIMIT 50
        ];
    }
}