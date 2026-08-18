public with sharing class LeadScoringService {

    private static final Integer HOT_THRESHOLD = 70;
    private static final Integer WARM_THRESHOLD = 40;

    public static void scoreLeads(List<Lead> leads) {
        for (Lead lead : leads) {
            Integer score = calculateScore(lead);
            lead.Lead_Score__c = score;
            lead.Lead_Temperature__c = temperatureFor(score);
        }
    }

    private static Integer calculateScore(Lead lead) {
        Integer score = 0;

        if (lead.NumberOfEmployees != null) {
            if (lead.NumberOfEmployees > 500) {
                score += 60;
            } else if (lead.NumberOfEmployees >= 100) {
                score += 40;
            } else if (lead.NumberOfEmployees >= 20) {
                score += 20;
            }
        }

        if (String.isNotBlank(lead.Email)) {
            score += 20;
        }

        if (String.isNotBlank(lead.Phone)) {
            score += 20;
        }

        return score;
    }

    private static String temperatureFor(Integer score) {
        if (score >= HOT_THRESHOLD) {
            return 'Hot';
        } else if (score >= WARM_THRESHOLD) {
            return 'Warm';
        }
        return 'Cold';
    }
}