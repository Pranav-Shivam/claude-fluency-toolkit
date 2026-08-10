# RFQ Email -> Quote Generator: Demo Dataset

Synthetic dataset for demoing a Claude Code agentic workflow that reads an
inbox, identifies RFQs, extracts line items, prices them, and drafts a quote.
All companies, domains, and people are fictional.

## Files

- `emails/email_00X.json` - 10 inbox messages. Each has:
  `id, from, to, subject, date, body, attachments, label`
  `label` is a demo-only ground-truth tag (not something the agent should read):
    - `rfq_inline`    - RFQ with line items in the email body
    - `rfq_attachment`- RFQ referencing an attached line sheet / spec sheet
    - `rfq_followup`  - amends a previous RFQ (tests thread/context handling)
    - `not_rfq`       - noise: invoice follow-up, newsletter, terms question
- `attachments/*.txt` - itemized line sheets / spec sheets referenced by some emails
- `pricing_catalog.json` - SKU, unit price, unit of measure, lead time, stock qty
- `customers.json` - account tier, discount %, payment terms, region, keyed by domain

## Suggested agent pipeline

1. **Classify** each email: RFQ vs not (use `label` only to check your agent's
   accuracy afterward, never as input to the agent).
2. **Extract line items** from body text and/or attachment (product name, qty, unit).
3. **Match customer**: sender domain -> `customers.json` -> account tier/discount/terms.
4. **Price**: match extracted product names to `pricing_catalog.json` SKUs
   (fuzzy match needed - emails use natural names, not SKU codes), apply
   account discount, sum lead times to the longest-lead item.
5. **Draft quote**: structured output (JSON or a formatted quote email) with
   line items, unit price, discount applied, total, and estimated delivery date.

## Things this dataset is designed to stress-test

- `email_007` is a follow-up to `email_001` - agent should recognize thread
  continuity (same customer/project, additive line item) rather than treat
  it as an unrelated new RFQ.
- `email_002` and `email_003` require reading the attachment, not just the body.
- `email_004`, `email_005`, `email_008` are deliberately NOT RFQs - a good
  classifier should skip these rather than trying to generate quotes from them.
- `email_010` is a Bronze-tier account with 0% discount - checks that the
  agent doesn't apply a discount by default.
- Product names in emails ("Clear glass", "Low-E glass") don't always match
  catalog names exactly - tests fuzzy SKU matching.
