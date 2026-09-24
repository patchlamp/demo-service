// Jobs: the records table, kind = job.
export default {
  table: "records",
  filter: { kind: "job" },
  title: "Jobs",
  singular: "job",
  list: [["title", "Job"], ["notes", "Notes"], ["status", "Status"], ["updated_at", "Changed"], ["created_at", "Added"]],
  json: "data",
  statuses: ["open", "done", "archived"],
  create: [
    { name: "title", label: "Job", required: true },
    { name: "notes", label: "Notes", type: "textarea" },
  ],
  edit: [
    { name: "title", label: "Job" },
    { name: "status", label: "Status", type: "select" },
    { name: "notes", label: "Notes", type: "textarea" },
  ],
  touch: "updated_at",
};
