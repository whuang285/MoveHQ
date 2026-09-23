# Move HQ

GitHub Pages-ready moving + new apartment planning app.

## Features
- Dashboard and move countdown
- Tasks
- Room-by-room inventory
- Bring / Pack / Sell / Donate / Trash / Replace decisions
- Packing progress and boxes
- Rooms, budgets and furnishing progress
- Wishlist with product URLs, prices and photos
- Moodboard
- JSON export/import
- Responsive desktop/mobile UI
- PWA manifest for Add to Home Screen
- No Node/npm/build step

## Deploy
1. Create a GitHub repo, e.g. `move-hq`.
2. Upload the contents of this folder to the repo root.
3. GitHub → Settings → Pages → Deploy from branch → `main` → `/ (root)`.
4. Open the generated GitHub Pages URL on desktop and phone.

## Run locally
`python3 -m http.server 8000`
Then open `http://localhost:8000`.

## Data / sync
V1 stores data in browser `localStorage`. GitHub Pages hosts the app but does not sync your data between devices. Use Export/Import when moving data between devices.

For true cross-device sync, the next version should use a hosted database/auth service (for example Supabase) and cloud image storage.
