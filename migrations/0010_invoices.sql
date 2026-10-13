-- invoices: what the owner bills (`invoice new`, by text), a numbered
-- document independent of Stripe. Money is in cents. `lines` is JSON:
-- [{"what": "Pool opening", "cents": 35000}, …]. The token is the
-- unguessable part of the customer's link; the number (INV-0001) is what
-- people say. `invoice` allocates the number in the INSERT that writes the
-- row (one statement, the UNIQUE below backs it), and never deletes a row,
-- so a number is never used twice. A sent invoice is never edited: it is
-- voided, and the replacement (`invoice void N --reissue`) points back at it.
CREATE TABLE IF NOT EXISTS invoices (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  number         TEXT NOT NULL UNIQUE,
  token          TEXT NOT NULL UNIQUE,
  business       TEXT NOT NULL DEFAULT '',  -- the name on the invoice, as it was made
  customer       TEXT NOT NULL,
  email          TEXT,
  phone          TEXT,
  customer_id    INTEGER,                   -- the customer book's id, when the site has one (B122)
  lines          TEXT NOT NULL,             -- JSON [{what, cents}]
  subtotal_cents INTEGER NOT NULL,
  tax_rate       TEXT,                      -- "7.25", or NULL for none
  tax_label      TEXT,                      -- "Sales tax 7.25%", or NULL for none
  tax_cents      INTEGER NOT NULL DEFAULT 0,
  total_cents    INTEGER NOT NULL,
  issued_on      TEXT NOT NULL,             -- YYYY-MM-DD
  due_on         TEXT NOT NULL,             -- YYYY-MM-DD, never before issued_on
  pay_by         TEXT,                      -- how to pay, in the owner's words (facts.md § Payment), as it was made
  note           TEXT,                      -- a line from the owner to the customer
  estimate       TEXT,                      -- E-0003, when it was made from an accepted estimate
  status         TEXT NOT NULL DEFAULT 'draft',   -- draft, sent, paid, void
  sent_at        TEXT,
  paid_on        TEXT,                      -- YYYY-MM-DD: the owner's declaration, not a payment we saw
  paid_note      TEXT,                      -- the owner's words about it ("cash", "check 1042")
  voided_at      TEXT,
  voided_by      TEXT,                      -- on a void: who voided it (the owner, by text or on /admin)
  reissued_as    TEXT,                      -- on a void: the number of the invoice that replaced it
  reissue_of     TEXT,                      -- on the replacement: the number it replaced
  owner_notes    TEXT,
  created_at     TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
  updated_at     TEXT
);
CREATE INDEX IF NOT EXISTS invoices_status ON invoices (status, due_on);
