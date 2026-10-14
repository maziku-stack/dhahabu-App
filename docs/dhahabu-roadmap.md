# Dhahabu: version roadmap and app lifecycle

**Product:** Dhahabu, a mobile gold-trade workflow for miners, licensed dealers, and government oversight.

**Status:** The repository contains an MVP/prototype. This roadmap describes the next steps toward a controlled pilot and later versions; it does not claim the app is production-ready.

## Product goal

Help miners and licensed dealers record and confirm gold-sale details, while giving authorized government users a clear compliance view. The app must distinguish user-agreed values from values verified by an authority or assay device.

## Version plan

### V1 — Current prototype

The root README describes the current flows: account registration and login, role-based screens, market-price screens, listings, two-party sale confirmation, tax summaries, receipts, feedback, dealer review, and government overview/audit screens.

The integration notes state that the official Commission price feed, assay device, statutory charge assessment, and government payment workflow are not active. With authority integrations unavailable, a completed sale can be recorded, but its charge assessment stays unavailable and no tax payment is collected by Dhahabu. Mock OTP is limited to development.

**V1 outcome:** users can review the core workflow with test data and identify where the process is unclear or incomplete.

### V1.1 — Controlled pilot readiness

Before inviting real miners or dealers, prepare the service for a limited, supervised pilot:

- Agree the pilot region, participants, support contact, and transaction rules with the relevant stakeholders.
- Replace development-only OTP with an approved delivery provider and document failed-delivery and account-recovery handling.
- Use production configuration: explicit secrets, restricted hosts and origins, HTTPS, a managed database, backups, and a tested restore procedure.
- Review permissions for miners, dealers, admins, and government users; check that each person sees only the information needed for their role.
- Finalize the privacy notice, retention schedule, operator contacts, and staff procedures. The current notice is a draft requiring operator review: [privacy notice draft](privacy-notice-draft.md).
- Make unavailable or unverified prices, assay results, and charges obvious in the app. Do not present estimates as official determinations.
- Run a small pilot with agreed test cases, a way to report problems, and a rollback plan.

**V1.1 exit decision:** proceed only when users can complete the agreed workflow, operators can support it, and stakeholders accept the remaining limitations.

### V2 — Verified authority workflows

Add authority-connected functions only after the responsible agencies and providers supply approved specifications, access, and sandbox cases:

- Import and verify official price records with source, reference, and effective time.
- Connect an approved assay device and preserve its signed result and transaction reference.
- Assess statutory charges from an approved rule set, with the correct rate, basis, payer, recipient, and authority reference.
- Start payment through an approved provider and accept status changes only through a verified provider callback.
- Make retries safe, prevent duplicate charges, and reconcile Dhahabu records against authority records.

These are conditional roadmap items. The current integration boundary and required authority information are documented in [backend/integrations/README.md](../backend/integrations/README.md). Do not fill gaps with guessed rates, pretend integrations, or manual payment claims.

### Later versions

Consider improvements such as additional partner workflows, more detailed operational reports, and wider rollout only after the pilot shows a need and support capacity exists. Record each proposed change with its user problem, owner, dependency, and release decision.

## App lifecycle

1. **Discover:** confirm transaction rules, users, authority responsibilities, and pilot boundaries.
2. **Design:** map each user’s steps and define transaction states, permissions, error handling, and audit evidence.
3. **Build:** implement a small, reviewable change in the Flutter app and Django API; keep integrations behind explicit provider interfaces.
4. **Verify:** check the flow against agreed examples, role access, provider sandbox cases, and failure cases. Do not treat a successful screen as proof that a government action occurred.
5. **Pilot:** release to a limited group, provide support, record issues, and review transaction outcomes with authorized stakeholders.
6. **Release:** publish a reviewed mobile build and deploy the matching API/database changes with a backup and rollback plan.
7. **Operate:** monitor availability, OTP delivery, transaction errors, price freshness, access events, support requests, and privacy requests.
8. **Improve or retire:** prioritize fixes from pilot evidence. If a workflow is retired, communicate the change and follow the approved retention and export process for existing records.

## Release checklist

- Product owner, pilot group, region, and support route are named.
- Production secrets and allowed hosts are explicit; development settings and mock OTP are disabled.
- Database backup and restore have been reviewed; migrations have a rollback plan.
- Privacy notice and retention rules are approved for the real operator and vendors.
- Each displayed price, assay, charge, and payment status has a clear source and verification state.
- Authority connections are enabled only after approved specifications and sandbox validation.
- Mobile release notes, user support instructions, and incident contacts are ready.

## Measures to review

Track whether eligible users can register, create and find listings, complete two-party confirmation, and understand each transaction status. Also review failed or abandoned transactions, stale or unavailable official data, support response time, privacy requests, and unresolved audit issues. Set pilot targets with the participating stakeholders before the pilot begins.
