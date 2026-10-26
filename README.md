# Project Tracker

A personal kanban dashboard for tracking everything you're working on — with a CLI for logging progress from any terminal session.

![Dashboard](https://user-images.githubusercontent.com/placeholder/dashboard-preview.png)

## Setup (5 minutes)

**1. Clone and enter the folder**
```bash
git clone https://github.com/tractianandersonyang/project-tracker.git ~/project-tracker
cd ~/project-tracker
```

**2. Create your projects file**
```bash
cp projects.template.json projects.json
```
Edit `projects.json` to add your own projects. Each one has a name, description, status, tags, and a recall command (the shell command you run to jump back into that project).

**3. Start the dashboard**
```bash
./serve.sh
```
Opens `http://localhost:8765/dashboard.html` in your browser.

---

## CLI usage

Log progress to any project from your terminal:

```bash
# From inside a project directory (needs a .tracker-id file):
~/project-tracker/project.sh here "what you did"

# By project ID from anywhere:
~/project-tracker/project.sh log <project-id> "what you did"

# Other commands:
~/project-tracker/project.sh ls                          # list all projects
~/project-tracker/project.sh stage <id> "<stage>" "<note>"  # update stage
~/project-tracker/project.sh status <id> active|paused|archived|parking-lot
```

**Optional: `.tracker-id` shortcut**

Drop a `.tracker-id` file in any project repo so the CLI knows which project it belongs to:
```bash
echo "my-first-project" > ~/my-first-project/.tracker-id
```

Then from inside that repo:
```bash
~/project-tracker/project.sh here "finished the auth flow"
```

**Optional: shell alias**

Add to your `.zshrc`:
```bash
alias tracker='~/project-tracker/serve.sh'
alias project='~/project-tracker/project.sh'
```

---

## Dashboard features

- **Kanban columns**: Active, Paused, Parking Lot, Archived (collapsible right strip)
- **Drag and drop** cards between columns — saves instantly
- **Search** across name, description, tags, products, and stage (`/` to focus)
- **Card expand** → full history timeline + recall command copy button
- **Media attachments** — attach videos or images to a card (add `"media"` array to project)
- **Auto-refresh** every 30 seconds

---

## Adding a project

Either edit `projects.json` directly, or click **+ Add Project** in the dashboard.

### Project fields

| Field | Description |
|-------|-------------|
| `id` | Unique slug, e.g. `my-feature-branch` |
| `name` | Display name |
| `description` | One-liner shown on the card |
| `status` | `active` / `paused` / `parking-lot` / `archived` |
| `stage` | Current phase, e.g. "In review", "Design", "Done" |
| `products` | Labels: `webapp`, `mobile`, `ai`, `personal`, etc. |
| `tags` | Free-form chips |
| `recallCommand` | Shell command to jump back in (shown + copyable on expand) |
| `history` | Array of `{ date, stage, note }` entries |
| `media` | Optional: `[{ type: "video", src: "media/demo.mp4", label: "Demo" }]` |

---

## Customization

- **Add columns**: Edit the HTML and add a new `data-status` column, then use that status string in your projects.
- **Add product labels**: Add a `.product-yourname` CSS class in `dashboard.html`.
- **Attach media**: Copy files into `media/` (gitignored) and reference them in `projects.json`.
- **Ask Claude**: Open Claude Code in this folder and describe what you want — it knows the full schema.

---

## Requirements

- Python 3 (for the local server)
- A modern browser
- No accounts, no auth, no cloud dependency
