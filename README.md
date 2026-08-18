# Smart Lead Router

Automated lead scoring and assignment for Salesforce. When a Lead is created or updated, it's scored, classified as **Hot / Warm / Cold**, and routed to an owner — automatically, with no manual step. A Lightning Web Component surfaces the scored leads, hottest first.

> Built on Salesforce Developer Edition with Apex + LWC, following the trigger handler pattern with full test coverage including bulk (200-record) scenarios.

![Demo](docs/demo.gif)

---

## What it does?

- **Scores every lead** on creation and update, based on company size and contact completeness.
- **Classifies** each lead into Hot / Warm / Cold from its score.
- **Assigns** an owner automatically (single-owner rule today, designed to evolve into round-robin / territory rules).
- **Displays** scored leads in a Lightning dashboard, sorted by score.

All of this runs inside the platform via an Apex trigger — the user just saves a lead.

## Scoring rules

The score is the sum of two signals (max 100):

| Signal | Condition | Points |
|---|---|---|
| Company size | > 500 employees | 60 |
| | 100–500 employees | 40 |
| | 20–100 employees | 20 |
| Contact info | Email present | +20 |
| | Phone present | +20 |

Classification thresholds:

| Temperature | Score |
|---|---|
| Hot | ≥ 70 |
| Warm | ≥ 40 |
| Cold | < 40 |

The scoring logic lives in one isolated method (`LeadScoringService.calculateScore`) so the rules can change without touching anything else.

## Architecture

The project follows the **trigger handler pattern**: the trigger stays thin and delegates all logic to testable service classes.

```
LeadTrigger (before insert, before update)
   └─ LeadTriggerHandler.handle(Trigger.new)
        ├─ LeadScoringService.scoreLeads()      → sets Lead_Score__c + Lead_Temperature__c
        └─ LeadAssignmentService.assignLeads()  → sets OwnerId
```

Front-end:

```
leadScoreDashboard (LWC)
   └─ @wire → LeadDashboardController.getScoredLeads()  (@AuraEnabled cacheable)
```

### Key design decisions

- **Thin trigger, logic in services.** The trigger only detects the event and delegates. Business logic sits in classes that can be unit-tested in isolation.
- **`before` context.** Scoring and assignment write to fields on the lead itself, so they run *before* save — the values persist in the same DML, no extra update.
- **Bulkified.** Services operate on `List<Lead>`, never one record at a time. No SOQL or DML inside loops. Proven by a 200-record bulk insert test.
- **No hardcoded IDs.** Owner assignment resolves the target user at runtime (`UserInfo.getUserId()`), so the code works on any org, not just the one it was built in.
- **Field-Level Security as code.** A permission set (`Lead_Scoring_Admin`) versions the field access, so the custom fields are readable after a fresh deploy instead of silently invisible.

## Testing

| Test class | Covers |
|---|---|
| `LeadScoringServiceTest` | Hot / Warm / Cold scoring, unit-level |
| `LeadTriggerTest` | Full trigger flow on single insert + 200-record bulk insert |

The bulk test is crucial because it proves the trigger chain handles a full batch without hitting governor limits...

Run the tests:

```bash
sf apex run test --class-names LeadScoringServiceTest --class-names LeadTriggerTest --result-format human --wait 10
```

## Project structure

```
force-app/main/default/
├── objects/Lead/fields/          # Lead_Score__c, Lead_Temperature__c
├── classes/
│   ├── LeadScoringService.cls        # scoring logic (pure, no DML)
│   ├── LeadAssignmentService.cls     # owner assignment (portable)
│   ├── LeadTriggerHandler.cls        # orchestrates the services
│   ├── LeadDashboardController.cls    # @AuraEnabled data for the LWC
│   ├── TestDataFactory.cls           # test data helper
│   ├── LeadScoringServiceTest.cls
│   └── LeadTriggerTest.cls
├── triggers/LeadTrigger.trigger
├── lwc/leadScoreDashboard/           # dashboard component
└── permissionsets/Lead_Scoring_Admin.permissionset-meta.xml
```

## Setup

1. Authorize a Developer org:
   ```bash
   sf org login web --alias LeadRouter --set-default
   ```
2. Deploy the metadata:
   ```bash
   sf project deploy start --source-dir force-app/main/default
   ```
3. Assign the permission set so the scoring fields are visible:
   ```bash
   sf org assign permset --name Lead_Scoring_Admin
   ```
4. Add the `leadScoreDashboard` component to a Lightning page (App Builder), then create a Lead and watch it get scored.

## Roadmap

- Round-robin / territory-based assignment instead of single owner.
- REST callout to enrich leads with external firmographic data (`HttpCalloutMock` in tests).
- Configurable scoring weights via Custom Metadata instead of hardcoded values.

---

Built by Wilson Alzuguir as a portfolio project to demonstrate Apex architecture, trigger design, test coverage, and LWC — the core skills of a Salesforce developer.