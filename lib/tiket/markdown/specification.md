# Ticket module (web) visual + UX spec

Color tokens (from Django templates):
- Primary red button: `#e11d2a` (hover `#b91c1c`), text white.
- Card/container background: `#ffffff` with border `#e5e7eb` (Tailwind `border-gray-200`).
- Text: headings `#111827` (`text-gray-900`), body `#4b5563` (`text-gray-600/700`), muted `#6b7280`.
- Accents: links `#dc2626/#b91c1c` (Tailwind red-600/700), subtle backgrounds `#f8fafc` on hover.

Tickets main page (`tickets_main.html`):
- Header: title “Browsing Dan Pembelian Tiket”.
- Sort dropdown: button with border-bottom red (`border-b-2 border-red-700`), options list in white popup. Sort modes: Date newest/oldest, ID asc/desc, UUID asc/desc.
- Create Ticket button: only for admin/superuser; red pill button.
- States: loading card (“Loading tickets…”), error card (red text), empty card (“No tickets yet.”).
- Grid: 1/2/3 columns responsive. Each card shows:
  - Match title row: team1 avatar + name, “vs”, team2 name + avatar; click opens detail.
  - Date text; optional cup image badge (top-right).
  - Admin buttons (if allowed): Edit Match, Add Link, Delete.
  - Links list: each link shows vendor name + price, red link text; admin-only delete per link.
  - Quick links row (text buttons): JSON (id/uuid), XML (id/uuid), open in new tab.
- Modal behavior: overlay dark scrim; modal card with dynamic form (create/edit match or add link). Forms use simple inputs (team names, image URLs, cup URL optional, place optional, date) and red submit button; cancel closes.

Ticket detail page (`ticket_detail.html`):
- Back link, then main match card: centered matchup with team avatars; date and optional place.
- Links grid (1/2/3 columns): each tile shows vendor name (red link), price text, optional vendor image badge.
- Empty state: “No links yet.”

Form fragments:
- `gen_tick_match.html`: inputs for team1, team2, img_team1, img_team2, img_cup (optional), place (optional), date; red submit, neutral cancel.
- `gen_tick_link.html`: inputs vendor, vendor_link, price (number), img_vendor; red submit, neutral cancel.
