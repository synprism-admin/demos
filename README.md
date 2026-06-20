# Synprism Demo Hub

Live at **demos.synprism.io** — hosted on Cloudflare Pages, deployed from this repo.

---

## Repo Structure

```
/                        ← Dashboard (index.html + demos.json)
/questionnaire/          ← Client intake form
/diamondwelldrilling/    ← Each demo is just a folder
/jtinteriors/
/beakertrac/
...
```

Cloudflare Pages serves everything from root. Any folder with an `index.html` is a live demo automatically — no nginx config, no server restarts, no SSH.

---

## Deploying a New Demo

**1. Build the site locally** (Webby does this in chat)

The finished file lives at `/home/adam/<slug>/index.html`

**2. Run the deploy script:**

```bash
cd /home/adam/synprism-demos

./deploy-demo.sh <slug> "<Name>" "<Category>" "<Icon>" "<Tag1,Tag2>"
```

**Example:**
```bash
./deploy-demo.sh diamondwelldrilling \
  "Diamond Well Drilling" \
  "Well Drilling · Auburn, CA" \
  "💧" \
  "Well Drilling,Pumps,Lab Testing,Filtration"
```

That's it. The script:
- Copies the HTML into the repo
- Updates `demos.json` (dashboard auto-updates)
- Commits and pushes to GitHub
- Cloudflare Pages deploys in ~60 seconds

---

## Updating an Existing Demo

Just rebuild the HTML, then run the same deploy command with the same slug — it updates in place.

Or for a quick push of any single file:
```bash
./push.sh jtinteriors       # push one demo
./push.sh dashboard         # push only the dashboard
./push.sh                   # push everything
```

---

## Updating the Dashboard Only

Edit `index.html` or `demos.json` directly, then:
```bash
./push.sh dashboard
```

---

## Adding demos.json fields

Each entry in `demos.json` supports:

| Field | Required | Notes |
|-------|----------|-------|
| `slug` | ✓ | Folder name, URL path |
| `name` | ✓ | Display name on dashboard |
| `category` | | Industry · Location |
| `icon` | | Emoji for the card |
| `path` | ✓ | `/slug/` |
| `status` | | `live`, `pending`, `pitched` |
| `location` | | City, state |
| `phone` | | Business phone |
| `tags` | | Array of strings |
| `accent` | | `cyan-purp`, `purple-mag`, `mag-cyan` |
| `added` | | `YYYY-MM-DD` |

---

## Cloudflare Setup (one-time)

1. Cloudflare Dashboard → Pages → Create application → Pages → Connect to Git
2. Select this repo → branch `main` → build command: *(blank)* → output: *(blank)*
3. Custom domain: `demos.synprism.io`
4. For dashboard password protection: Workers & Pages → Access → Add an application → Self-hosted → protect `/` only

---

## Local Dev

```bash
cd /home/adam/synprism-demos
python3 -m http.server 8080
# Open http://localhost:8080
```
