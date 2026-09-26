# Move HQ V4

Move HQ is a cloud-synced moving + new-apartment organizer built for GitHub Pages + Supabase.

## V4 additions

### Packing Helper
Track the physical containers you are actually using:
- Box 1
- Box 2
- Suitcase 1
- Carry-on 1
- Storage bin 3
- Tote bag 2

Each container can store:
- type
- status (Planned / Packing / Packed / Moved)
- dimensions
- dimension unit
- weight limit
- location
- notes

Then add exact contents to each container. A content entry can be:
- linked to an existing household inventory item
- linked to a closet item
- manual text such as `Shoes A`, `Shoes B`, `Toiletries`, or `Books`

Example:

`Suitcase 1` — 22 × 14 × 9 in — 50 lb
- Books × 4
- Toiletries × 1
- Chargers × 1

`Box 1`
- Shoes A
- Shoes B
- Shoes C

### Closet
A dedicated cloud inventory for clothing, shoes, bags, and accessories with:
- category
- quantity
- season
- Bring / Sell / Donate / Decide / Trash
- packing status
- assigned container
- notes

Closet items can also be inserted directly into a packing container.

## Setup

1. Create a Supabase project.
2. Copy `config.example.js` to `config.js` and fill in your Supabase project URL and anon key.
3. Run the entire `schema.sql` in Supabase SQL Editor.
4. If you already installed Move HQ V3, run the V4 schema to add the new tables. The policy section is safe to rerun.
5. Upload the contents of this folder to a GitHub repository.
6. Enable GitHub Pages from the `main` branch and root folder.

The browser uses Supabase Auth for identity, PostgreSQL for data, and a private Supabase Storage bucket for photos. There is no localStorage data store.
