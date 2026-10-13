// How /admin shows the invoices. The lines, the numbers and the dates come
// from `invoice` (by text); here the owner reads them, marks one paid or
// void, and keeps notes. A sent invoice's lines are never edited here or
// anywhere: a wrong one is voided and reissued (`invoice void N --reissue`).
// Rename the title to the owner's word ("Bills"); `db add` doesn't rewrite
// this file.
export default {
  table: "invoices",
  title: "Invoices",
  singular: "invoice",
  list: [["number", "No."], ["customer", "Customer"], ["total_cents", "Total"], ["status", "Status"],
         ["due_on", "Due"], ["paid_on", "Paid on"]],
  json: "lines",
  sum: ["total_cents"],
  statuses: ["draft", "sent", "paid", "void"],
  // Only these two by hand: sent is written by `invoice send` (the page opens then). "paid" is the
  // owner's own declaration, and the customer's page says so in those words; void closes the page.
  quick: ["paid", "void"],
  edit: [
    { name: "paid_on", label: "Paid on (the day you were paid)", type: "date" },
    { name: "paid_note", label: "How it was paid (cash, check 1042…)", type: "text" },
    { name: "owner_notes", label: "Notes (only you see these)", type: "textarea" },
  ],
  touch: "updated_at",
};
