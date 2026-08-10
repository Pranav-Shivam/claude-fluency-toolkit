You are extending the RFQ viewer built from `prompt.md`. This is a **follow-on** task:
`index.html` in this directory already exists and already embeds all processed
emails, classifications, and quotes (Q1–Q6) from the 10-email demo dataset. Do **not**
re-run the extraction/classification/pricing pipeline and do **not** re-read
`./data` — reuse the data already embedded in `index.html` as-is. This prompt only
adds two features on top of that existing page.

Read `index.html` first to understand the current data model (`EMAILS`, `ATTACHMENT_TEXT`,
`CLASSIFICATION`, `QUOTES`, `renderList`, `renderRfqDetail`, `showDetail`/`showList`)
before making changes, so the additions match the existing structure and style
instead of introducing a parallel one.

Constraints carry over unchanged from `prompt.md`: single self-contained `index.html`,
inline CSS/JS only, no external requests, no CDNs, no build step, no new libraries.
Any charts must be hand-built (inline SVG or `<canvas>` with vanilla JS) — not a
charting library. The page must still work standalone by opening the file in a
browser, with `./data` absent.

## Feature 1 — Analytics dashboard

Add a "Dashboard" view, reachable from a nav link/button visible on the list view
(and from detail views), that summarizes the whole batch:

- **KPI tiles:** total emails processed; RFQ count vs skipped count (and the merged
  follow-up counted separately, not double-counted as its own RFQ); total pipeline
  value (sum of all quote totals); average discount % applied across quotes.
- **Quotes by tier:** bar or donut breakdown of quote value by account tier (Bronze/
  Silver/Gold/Platinum), built from the existing `QUOTES` data.
- **Quotes by region:** same breakdown by customer region (pull region from the
  customer data already implied in `QUOTES`/`CLASSIFICATION` — add region to each
  quote's embedded data if it isn't already there, sourced from `customers.json`'s
  known values, not invented).
- Reuse the existing color tokens/badge styles already defined in the page's `<style>`
  block rather than introducing a new palette.
- Add "← back to list" / nav links consistent with the existing list ⇄ detail pattern.

## Feature 2 — Printable quote view

From any RFQ detail view, add a "Print / Export Quote" button that produces a
clean, single-quote, print-friendly layout:

- Use a `@media print` stylesheet that hides site chrome (header, nav, back links,
  badges) and shows only: customer name, account tier, discount %, payment terms,
  the line-item table, subtotal/discount/total, estimated delivery date, and source
  email reference(s) — formatted like a quote a sales rep could hand to a customer.
- Clicking the button should trigger the browser's native print dialog
  (`window.print()`) — no separate export file, no PDF-generation library.
- Verify the normal on-screen detail view is unaffected by the print stylesheet
  (print rules must be scoped under `@media print`).

## Step 3 — Verify

Open the modified `index.html` and confirm:

1. List view still renders all 10 emails correctly (no regressions from Feature 1/2).
2. Dashboard view is reachable, shows correct totals against the 6 quotes (Q1–Q6),
   and the tier/region breakdowns sum to the same total pipeline value as the KPI tile.
3. Each RFQ detail view has a working print button; the print preview shows only
   the quote content, not app chrome.
4. No console errors, no external network calls.

## Step 4 — Report back

Confirm both features are wired up, and report the computed dashboard totals (total
pipeline value, RFQ/skipped/merged counts, avg discount %) so they can be sanity-checked
against the Step 4 summary table already produced from `prompt.md`.
