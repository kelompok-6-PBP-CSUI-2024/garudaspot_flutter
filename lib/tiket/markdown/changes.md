# Ticket module updates

- Added Dart models `ticket_match.dart` and `ticket_link.dart` with `fromJson`/`toJson` helpers for TicketMatch and TicketLink data.
- Backend now exposes reusable TicketMatch/TicketLink serializers and accepts JSON payloads for create/edit endpoints, plus CORS is configured for the production host.
