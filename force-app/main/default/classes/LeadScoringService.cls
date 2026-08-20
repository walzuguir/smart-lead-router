public with sharing class LeadScoringService {

    private static final Integer HOT_THRESHOLD = 70;
    private static final Integer WARM_THRESHOLD = 40;

    private static List<Lead_Scoring_Rule__mdt> rules {
        get {
            if (rules == null) {
                rules = [
                    SELECT Min_Employees__c, Max_Employees__c, Points__c
                    FROM Lead_Scoring_Rule__mdt
                ];
            }
            return rules;
        }
        set;
    }

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
            score += pointsForEmployees(lead.NumberOfEmployees);
        }

        if (String.isNotBlank(lead.Email)) {
            score += 20;
        }
        if (String.isNotBlank(lead.Phone)) {
            score += 20;
        }

        return score;
    }

        private static Integer pointsForEmployees(Integer employees) {
        for (Lead_Scoring_Rule__mdt rule : rules) {
            Boolean acimaDoMin = employees >= rule.Min_Employees__c;
            Boolean abaixoDoMax = rule.Max_Employees__c == null || employees <= rule.Max_Employees__c;
            if (acimaDoMin && abaixoDoMax) {
                return Integer.valueOf(rule.Points__c);
            }
        }
        return 0;
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