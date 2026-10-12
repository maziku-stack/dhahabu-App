# Dhahabu privacy notice — operator review required

**Status:** Draft only. This is a product notice for review, not legal advice or a claim of compliance. Do not publish as final until the bracketed operator details, lawful purposes, retention schedule, authority disclosures, vendor list and rights contact have been completed and approved.

**App notice version:** `2026-10-draft-1`  
**Effective date:** Not set  
**Controller/legal entity:** [confirm registered legal name and address]  
**Privacy/DPO contact:** [confirm email, phone, postal address, and complaint route]

## Data handled by the current app

- Account: name, phone, email (where supplied), role, phone verification, region, mining site, language, account creation time and password hash. The app does not intentionally store a readable password or PIN.
- Dealer verification: business name, licence number and uploaded licence document.
- Listings: weight, karat, asking price, notes, region, photo, status and timestamps. Seller name is not included in listing responses. Seller phone is hidden unless that seller turns on “Share my phone on this listing”; the seller can turn it off later.
- Trades: participants, measured/agreed trade details, status, confirmation times, tax-assessment/payment reference fields when supplied, and audit events. A trade participant receives relevant counterparty identity/contact details.
- Support/privacy requests: feedback or grievance text and the type/details/status of a privacy request.
- Device/session: bearer access and refresh tokens are stored using platform secure storage. App preferences such as language/theme remain in local preferences. [Confirm any infrastructure, access, crash, network, or security logs and their fields.]

## Purposes and access

The app uses account data to authenticate users and provide account/profile features; listing data to display offers and start trade workflows; trade data to record and confirm transactions and support applicable accounting/compliance workflows; dealer documents to review dealer eligibility; and support/privacy request details to respond to users.

Other signed-in users can browse listing details and see seller phone only when the seller opts in for that listing. Trade participants can see the counterparty details needed for that trade. Authorized Dhahabu staff/admins can access information needed to operate, support, secure, or review the platform. The Mining Commission and TRA integrations are not connected in this build; any future sharing must identify the exact fields, recipient, legal basis, purpose, and user notice before activation.

**Legal basis for each purpose:** [operator and Tanzanian counsel to specify; do not label all processing as consent].  
**Hosting, SMS, storage, analytics, support and other processors:** [list vendor legal names, service, data fields, locations and safeguards].  
**Cross-border processing/transfers:** [confirm locations and required approvals/safeguards before production].

## Retention, security and rights

**Retention schedule:** [specify periods per data category, legal holds, and deletion/anonymization method]. Trade or tax records may need to be retained, so a deletion request must be reviewed against applicable requirements. The app records such requests for review; it does not automatically erase records.

Users can view/copy an export of account, listing and trade information and can submit requests for access/export, correction, deletion, restriction, objection, portability, or withdrawal of optional consent. Requests are visible to authorized operators in Django admin and start in `received` status. **Response time, verification steps, appeal/complaint route and public contact:** [operator to complete].

Controls implemented in this build include authenticated self-service endpoints, owner-scoped exports and privacy requests, no-store cache headers for exports, private-by-default listing phone numbers with an owner-controlled opt-in, and platform secure storage for app tokens. These controls do not replace production access reviews, backups, encryption-in-transit/at-rest configuration, staff procedures, incident response, vendor contracts, or security testing. **Security incident/breach contact and response procedure:** [operator to complete].

## Completion checklist before release

1. Confirm the operator/controller and privacy officer/contact; register the relevant controller/processor with the Tanzania Personal Data Protection Commission where required.
2. Approve purpose and lawful basis for each field and each recipient; ensure all optional processing has a separate, revocable choice.
3. Inventory hosting, SMS, analytics, logs, file storage, backups, locations and subprocessors; validate cross-border transfer requirements.
4. Approve statutory/operational retention periods and deletion/hold workflow; implement a user-visible request SLA and escalation route.
5. Confirm which trade/tax fields are required by the Mining Commission, TRA or other authority and enable no integration until its approved contract/API and security controls exist.
6. Replace this draft in the app with the approved notice, translate and review both language versions, set a new immutable notice version, and require acknowledgement of that version at signup.

## Reference

The Tanzania Personal Data Protection Commission describes data subject rights and registration information on its official [Data Subject Rights](https://pdpc.go.tz/data-subject-rights/) and [Registration](https://pdpc.go.tz/services/registration/) pages. The operator should verify current requirements with the Commission and qualified Tanzanian counsel.
