# Checklist: privacy and compliance

Personal, health or financial data. This is engineering guidance, not legal advice: ask the owner which laws apply and confirm details with a qualified professional. Rules: SR-02, SR-03. Facts checked 2026-11-10; recheck before relying on them.

## Always (any personal data)
- [ ] The owner has confirmed which laws apply (where users live, what data, which sector). Logged in `DECISIONS.md`.
- [ ] Collect only what a feature needs (data minimisation). Each personal field has a purpose written down.
- [ ] A clear privacy notice exists and matches what the code actually does.
- [ ] Consent captured where required, recorded with time and version, and as easy to withdraw as to give.
- [ ] Users can see, export, correct and delete their data, or the exceptions are documented.
- [ ] Every third party that receives personal data (hosting, email, analytics, LLM providers) is listed, with a data processing agreement and its region.
- [ ] Privacy by design: new features that touch personal data get a short review using the threat model template.
- [ ] Cross-border transfers known and lawful for the regimes that apply.

## GDPR (EU and UK users)
- [ ] Lawful basis recorded for each processing purpose.
- [ ] Breach: notify the supervisory authority within 72 hours of becoming aware (Art. 33); notify affected people without undue delay when the risk to them is high (Art. 34).
- [ ] Records of processing; a DPIA for high-risk processing.

## India: DPDP Act 2023 and DPDP Rules 2025
- [ ] Rules notified November 2025 with a phased start; most obligations apply about 18 months later (around May 2027). Check whether the timeline has since been shortened.
- [ ] Notice and consent in clear language; consent managers recognised.
- [ ] Breach: inform the Data Protection Board and affected people without undue delay, with a detailed report to the Board within 72 hours.
- [ ] Children's data needs verifiable parental consent; no tracking or targeted ads to children.

## HIPAA (US protected health information)
- [ ] A Business Associate Agreement with every vendor that stores or processes PHI, including hosting and any LLM provider.
- [ ] Access controls, audit logs, encryption and minimum-necessary access for PHI.
- [ ] Breach: notify affected individuals within 60 days of discovery; breaches affecting 500 or more people also go to HHS and the media.
- [ ] The current Security Rule still applies; the proposed 2025 overhaul was not final when checked.

## Payments
- [ ] Card data never touches your servers: use the provider's hosted fields or checkout (Stripe, Razorpay, etc.) to stay in the smallest PCI DSS scope.
- [ ] Webhooks from the payment provider are verified (see `api-input.md`).

## Health and other sensitive apps
- [ ] Sensitive categories (health, biometric, financial, children's, location) get field-level encryption, stricter access, audit logging and shorter retention.
- [ ] Clinical or medical content shown by AI features carries a clear disclaimer and is reviewed by a qualified person where required.

## Verify
For one test user, export all their data and then delete it. Show what's left and why.
