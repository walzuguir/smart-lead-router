import { LightningElement, wire } from 'lwc';
import getScoredLeads from '@salesforce/apex/LeadDashboardController.getScoredLeads';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Company', fieldName: 'Company', type: 'text' },
    { label: 'Score', fieldName: 'Lead_Score__c', type: 'number' },
    { label: 'Temperature', fieldName: 'Lead_Temperature__c', type: 'text' }
];

export default class LeadScoreDashboard extends LightningElement {
    columns = COLUMNS;

    @wire(getScoredLeads)
    leads;
}