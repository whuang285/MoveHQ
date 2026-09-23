# Move HQ V2

A lightweight move + new-apartment command center designed for GitHub Pages. No build step and no dependencies.

## What's new in V2
- Real dashboard with actionable counts and packing progress
- Editable tasks with status, priority, category, due date, notes
- Room-by-room inventory with Bring / Pack / Sell / Donate / Trash / Replace decisions
- Inventory status updates directly from the table
- Rooms with budgets and room-level planning
- Wishlist with product URL, price, room, priority, status, notes and photo URL
- Moodboard references
- Search + filters across tasks and inventory
- JSON export/import backups
- Mobile responsive layout + PWA manifest
- Data persists in browser localStorage
- No accidental test files or build tooling

## Deploy
1. Create a GitHub repository.
2. Upload all files in this folder to the repository root.
3. GitHub: Settings → Pages → Deploy from branch → `main` → `/ (root)`.
4. Open the generated GitHub Pages URL on desktop or phone.

## Important limitation
V2 is still browser-local. Your desktop and phone will have separate data unless you manually export/import the JSON backup.

## V3 direction
For true cross-device sync, add Supabase (auth + Postgres + Storage) or another hosted backend. The UI/data model is intentionally simple enough to migrate to a cloud backend.
