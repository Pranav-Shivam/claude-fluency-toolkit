You are an RFQ processing agent. `rfq_demo_dataset.zip` in this same directory contains:

- `emails/*.json` — 10 inbox messages (each has `from, to, subject, date, body, attachments, label`)
- `attachments/*.txt` — line sheets / spec sheets referenced by some emails
- `pricing_catalog.json` — SKU, unit price, unit, lead time, stock
- `customers.json` — account tier, discount %, payment terms, keyed by sender domain

See `README.md` (also in this directory) for full dataset context — what each email is designed to test (thread follow-ups, attachment-only line items, non-RFQ noise, zero-discount tier, fuzzy SKU matching).

Do NOT read the `label` field in the emails — that's demo ground-truth only, not agent input.

## Step 1 — Unpack

Unzip `rfq_demo_dataset.zip` into a `./data` folder here.

## Step 2 — Process every email

For every email in `./data/emails`, in filename order:

1. Classify it as RFQ or not-RFQ based on subject/body content.
2. If not an RFQ, skip it and note why in one line.
3. If it is an RFQ, extract line items (product name, quantity, unit) from the body and any referenced attachment.
4. If this email is a follow-up to an earlier one (same sender/project, references "yesterday's request" etc.) and does NOT explicitly ask to be quoted standalone, merge its line items into that earlier RFQ instead of treating it as new.
5. Match the sender's domain to `customers.json` to get account tier, discount %, and payment terms.
6. Match each extracted product name to the closest SKU in `pricing_catalog.json` (names won't always match exactly — use judgment), price it, apply the account discount, and use the longest `lead_time_days` among line items as the estimated delivery.
7. Build a structured quote: customer, account tier, line items with unit price/qty/subtotal, discount applied, total, estimated delivery date, payment terms.

## Step 3 — Build `index.html`

Produce a single self-contained `index.html` (inline CSS/JS, no external requests) in this directory that presents the results as a small RFQ viewer:

- **List view (default):** every processed email in filename order, one row each, showing subject, sender, classification (RFQ / skipped), and — for RFQs — customer name and quote total. Skipped emails show their one-line skip reason instead.
- **Detail view:** clicking any RFQ row shows that quote in full — customer, account tier, discount %, payment terms, the line-item table (product, matched SKU, qty, unit, unit price, subtotal), subtotal/discount/total, estimated delivery date, and which source email(s) it came from (call out merged follow-ups explicitly, e.g. "email_001 + email_007"). Also render any attachment text the RFQ referenced, so the reviewer can see the original line sheet/spec sheet alongside the extracted items.
- Clicking a skipped (not-RFQ) row can just show the raw email body and the skip reason — no quote data.
- Keep navigation simple: list ⇄ detail, e.g. a "← back to list" link/button from detail view. Plain HTML/CSS/JS is fine, no build step, no external libraries/CDNs.

Embed all extracted/derived data (quotes, classifications, skip reasons, attachment text) directly in the HTML/JS — the page must work standalone by opening the file in a browser, without needing `./data` to still be present.

## Step 4 — Report back

After processing, give a summary table: how many emails were classified as RFQ vs skipped, and list the final quotes (customer, total, estimated delivery).
