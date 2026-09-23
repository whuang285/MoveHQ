# Move HQ V3

A cloud-synced move + new-apartment planner. V3 uses **Supabase Auth, Postgres, Row Level Security, and private cloud storage**. Your desktop and phone use the same account and see the same data.

## 1. Create Supabase
1. Create a project at https://supabase.com/.
2. Open **SQL Editor** and run all of `schema.sql`.
3. In **Project Settings → API**, copy the Project URL and the **anon/public** key.
4. Edit `config.js`:
```js
window.MOVE_HQ_CONFIG = {
  supabaseUrl: 'https://YOUR-PROJECT.supabase.co',
  supabaseAnonKey: 'YOUR-ANON-KEY'
};
```
Never put the Supabase `service_role` key in this app or GitHub.

## 2. Run locally
Because Supabase auth is hosted, serve the folder rather than opening `index.html` directly. For example:
```bash
python3 -m http.server 8080
```
Then open http://localhost:8080.

## 3. GitHub Pages
Upload the project files to a GitHub repo. Enable **Settings → Pages → Deploy from branch → main → /(root)**.

Important: `config.js` contains your Supabase public anon key. That key is designed to be used client-side; security comes from Supabase Auth + RLS. Do not put a service-role key here.

## 4. Auth redirect
In Supabase, go to **Authentication → URL Configuration** and add your deployed GitHub Pages URL to **Site URL / Redirect URLs**, e.g. `https://YOUR-USERNAME.github.io/move-hq/`.

## 5. Cloud photos
Photos are uploaded into the private `move-hq-media` bucket under your user ID. RLS prevents another signed-in user from reading, changing, or deleting your files. The app creates signed URLs when it displays them.

## What is synced
- Tasks
- Rooms + budgets
- Inventory
- Packing status
- Wishlist
- Moodboard
- Move date
- Product links
- Uploaded photos

Every change writes to Supabase immediately. There is no localStorage data store and no export/import requirement for normal use.
