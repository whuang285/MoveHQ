# Move HQ V4.1

Cloud-synced moving + new-apartment organizer using Supabase.

## V4.1 fixes

- Fixed the Closet/Supabase migration issue that could make Closet appear broken.
- Added `migration_v4_closet_packing.sql` for projects that started from V3.
- Closet items no longer rely on a separate container field for packing truth.
- Use **Closet → Pack** to put a closet item into a real Box/Suitcase/Bag/Bin.
- Packing Helper is the source of truth for exact physical contents.
- Example: `Black boots → Box 1`; `Toiletries → Suitcase 1`; `Books → Suitcase 1`.
- Packing records can be edited or removed.
- Closet shows exactly which container(s) contain each item.
- If the closet table is missing, the rest of the app still loads and Closet explains how to fix the database.

## Setup for an existing V3 project

1. Open your Supabase project.
2. Open **SQL Editor**.
3. Run `migration_v4_closet_packing.sql` once.
4. Refresh Move HQ.

If you are creating a brand-new Supabase project, run `schema.sql` instead.

## GitHub Pages

1. Put the contents of this folder in your GitHub repository.
2. Set your Supabase URL and anon key in `config.js`.
3. GitHub → Settings → Pages → Deploy from branch → `main` → `/ (root)`.

## Data model

- `closet_items`: what clothing/shoes/accessories you own and whether you're bringing them.
- `containers`: the physical things you pack into.
- `container_contents`: the exact relationship between an item and a physical container.

This means a closet item can be moved between containers without changing the closet inventory itself.
