// Customers: the records table, kind = customer.
export default {
  table: "records",
  filter: { kind: "customer" },
  title: "Customers",
  singular: "customer",
  list: [["title", "Name"], ["notes", "Notes"], ["status", "Status"], ["updated_at", "Changed"], ["created_at", "Added"]],
  json: "data",
  statuses: ["open", "done", "archived"],
  create: [
    { name: "title", label: "Name", required: true },
    { name: "notes", label: "Notes (address, pool size, gate code…)", type: "textarea" },
  ],
  edit: [
    { name: "title", label: "Name" },
    { name: "status", label: "Status", type: "select" },
    { name: "notes", label: "Notes", type: "textarea" },
  ],
  touch: "updated_at",
};
