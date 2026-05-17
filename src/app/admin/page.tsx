import { redirect } from "next/navigation";

// Redirect bare /admin to the active admin section.
// Expand this to a real dashboard when the admin nav/layout slice lands.
export default function AdminIndexPage() {
  redirect("/admin/imports/cronometer");
}
