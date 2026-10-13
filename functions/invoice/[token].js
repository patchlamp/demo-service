// /invoice/<token> — the page a customer opens from the invoice's link (or
// its QR code): the invoice as the PDF shows it, read-only.
//
//   GET   the business, the number, the issue and due dates, the lines, tax,
//         the total, how to pay (the owner's own words, as the invoice was
//         made), and the status: due on a day, or "Marked paid by <business>
//         on <day>" once the owner says it was paid. That is the owner's
//         declaration, never a payment this page took or saw, and it says so.
//
// There is nothing to post: no payment is taken here. The token is 32 random
// characters made by `invoice new`; there is no list of invoices anywhere
// public. Unknown token, a draft or a void invoice: the same "not found"
// page, so the page tells a stranger nothing.
import { esc } from "../_lib/core.js";

const TOKEN = /^[A-Za-z0-9_-]{24,64}$/;

const money = (c) => "$" + (Number(c || 0) / 100).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const day = (d) => {
  const t = new Date(String(d || "").slice(0, 10) + "T12:00:00Z");
  return isNaN(t) ? String(d || "") : new Intl.DateTimeFormat("en-US", { timeZone: "UTC", month: "long", day: "numeric", year: "numeric" }).format(t);
};

function shell(title, body, status = 200) {
  return new Response(`<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex">
<meta name="referrer" content="same-origin">
<title>${esc(title)}</title><link rel="stylesheet" href="/css/style.css">
<style>
.inv{max-width:42rem;margin:2rem auto;padding:0 1.25rem;font-family:var(--font-body,system-ui,sans-serif);color:var(--ink,#1d1d1f)}
.inv h1{font-family:var(--font-display,inherit);margin:.2rem 0 1rem;line-height:1.15}
.inv .kicker{color:var(--accent,#1d1d1f);text-transform:uppercase;letter-spacing:.12em;font-size:.8rem;font-weight:600}
.inv table{width:100%;border-collapse:collapse;margin:1rem 0}
.inv td{padding:.5rem 0;border-bottom:1px solid var(--bg-line,#ddd);vertical-align:top}
.inv td.amt{text-align:right;white-space:nowrap;padding-left:1rem}
.inv tr.total td{font-weight:700;border-bottom:none;font-size:1.1rem}
.inv .muted{color:var(--ink-dim,#6b6b70)}
.inv .payby{white-space:pre-line}
.inv .status{padding:1rem;border-radius:.6rem;border:1px solid var(--bg-line,#ddd)}
.inv .status.paid{background:#eef7ee;border-color:#eef7ee}
</style></head><body><main class="inv">${body}</main></body></html>`,
    { status, headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-store", "x-robots-tag": "noindex" } });
}

const notFound = () => shell("Invoice not found", `<h1>Invoice not found</h1>
<p class="muted">This link doesn't open an invoice. It may have been withdrawn; the business that sent it can send it again.</p>`, 404);

async function find(env, token) {
  if (!TOKEN.test(token || "")) return null;
  const row = await env.DB.prepare("SELECT * FROM invoices WHERE token = ?").bind(token).first();
  return row && ["sent", "paid"].includes(row.status) ? row : null;
}

function render(row) {
  let lines = [];
  try { lines = JSON.parse(row.lines || "[]"); } catch { lines = []; }
  const biz = row.business || "the business";
  const items = lines.map((l) => `<tr><td>${esc(l.what)}</td><td class="amt">${money(l.cents)}</td></tr>`).join("");
  const tax = row.tax_cents ? `<tr><td class="muted">Subtotal</td><td class="amt">${money(row.subtotal_cents)}</td></tr>
<tr><td class="muted">${esc(row.tax_label || "Tax")}</td><td class="amt">${money(row.tax_cents)}</td></tr>` : "";
  const note = row.note ? `<p>${esc(row.note)}</p>` : "";
  const status = row.status === "paid"
    ? `<p class="status paid"><strong>Marked paid by ${esc(biz)} on ${esc(day(row.paid_on || row.updated_at || ""))}.</strong></p>`
    : `<p class="status"><strong>Due ${esc(day(row.due_on))}.</strong></p>`;
  const payby = row.status !== "paid" && row.pay_by ? `<h2>How to pay</h2><p class="payby">${esc(row.pay_by)}</p>` : "";
  const body = `<p class="kicker">${esc(row.business)} · Invoice ${esc(row.number)}</p>
<h1>For ${esc(row.customer)}</h1>
<p class="muted">Issued ${esc(day(row.issued_on))} · Due ${esc(day(row.due_on))}</p>
${note}
<table>${items}${tax}<tr class="total"><td>Total</td><td class="amt">${money(row.total_cents)}</td></tr></table>
${status}${payby}`;
  return shell(`Invoice ${row.number} · ${row.business}`, body);
}

export async function onRequestGet({ params, env }) {
  const row = await find(env, params.token);
  return row ? render(row) : notFound();
}
