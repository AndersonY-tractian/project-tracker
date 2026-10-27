#!/bin/bash
# Usage:
#   project log <id> "<note>"                            — add a log entry to a project
#   project stage <id> "<stage>" "<note>"                — update current stage + log
#   project status <id> active|paused|archived
#   project branch <id> "<branch>" active|paused|done "<note>"  — add/update a branch
#   project recall <id>                                  — print the recall command
#   project ls                                           — list all projects

PROJECTS_FILE="$HOME/project-tracker/projects.json"

cmd="$1"
id="$2"

case "$cmd" in
  log)
    note="$3"
    today=$(date '+%Y-%m-%d')
    python3 - "$id" "$today" "$note" "$PROJECTS_FILE" << 'PYEOF'
import json, sys
id, today, note, path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
data = json.load(open(path))
for p in data['projects']:
    if p['id'] == id:
        p.setdefault('history', []).append({'date': today, 'stage': p.get('stage', ''), 'note': note})
        p['updatedAt'] = today
        print(f"✓ Logged to {p['name']}: {note}")
        break
else:
    print(f"Project '{id}' not found. Run: project ls")
    sys.exit(1)
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
    ;;

  stage)
    stage="$3"
    note="$4"
    today=$(date '+%Y-%m-%d')
    python3 - "$id" "$today" "$stage" "$note" "$PROJECTS_FILE" << 'PYEOF'
import json, sys
id, today, stage, note, path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
data = json.load(open(path))
for p in data['projects']:
    if p['id'] == id:
        p['stage'] = stage
        p['updatedAt'] = today
        p.setdefault('history', []).append({'date': today, 'stage': stage, 'note': note})
        print(f"✓ Updated {p['name']} → {stage}")
        break
else:
    print(f"Project '{id}' not found. Run: project ls")
    sys.exit(1)
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
    ;;

  status)
    new_status="$3"
    python3 - "$id" "$new_status" "$PROJECTS_FILE" << 'PYEOF'
import json, sys
id, new_status, path = sys.argv[1], sys.argv[2], sys.argv[3]
if new_status not in ('active', 'paused', 'archived'):
    print("Status must be: active, paused, or archived")
    sys.exit(1)
data = json.load(open(path))
for p in data['projects']:
    if p['id'] == id:
        p['status'] = new_status
        print(f"✓ {p['name']} → {new_status}")
        break
else:
    print(f"Project '{id}' not found")
    sys.exit(1)
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
    ;;

  recall)
    python3 - "$id" "$PROJECTS_FILE" << 'PYEOF'
import json, sys
id, path = sys.argv[1], sys.argv[2]
data = json.load(open(path))
for p in data['projects']:
    if p['id'] == id:
        cmd = p.get('recallCommand', f"cd {p.get('path', '~')}")
        print(f"\n{cmd}\n")
        break
else:
    print(f"Project '{id}' not found")
PYEOF
    ;;

  here)
    # Read project ID from .tracker-id in current directory, then log or show info
    TRACKER_ID_FILE="$(pwd)/.tracker-id"
    if [ ! -f "$TRACKER_ID_FILE" ]; then
      echo "No .tracker-id file in $(pwd)"
      echo "Run: echo \"<project-id>\" > .tracker-id"
      exit 1
    fi
    HERE_ID=$(cat "$TRACKER_ID_FILE" | tr -d '[:space:]')
    if [ -z "$2" ]; then
      echo "Project: $HERE_ID"
      echo "Run: project here \"<note>\" to log progress"
    else
      note="$2"
      today=$(date '+%Y-%m-%d')
      python3 - "$HERE_ID" "$today" "$note" "$PROJECTS_FILE" << 'PYEOF'
import json, sys
id, today, note, path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
data = json.load(open(path))
for p in data['projects']:
    if p['id'] == id:
        p.setdefault('history', []).append({'date': today, 'stage': p.get('stage', ''), 'note': note})
        p['updatedAt'] = today
        print(f"✓ [{p['name']}] {note}")
        break
else:
    print(f"Project '{id}' not found in tracker")
    sys.exit(1)
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
    fi
    ;;

  branch)
    branch_name="$3"
    branch_status="$4"
    branch_note="$5"
    today=$(date '+%Y-%m-%d')
    python3 - "$id" "$branch_name" "$branch_status" "$branch_note" "$today" "$PROJECTS_FILE" << 'PYEOF'
import json, sys
id, branch_name, branch_status, branch_note, today, path = sys.argv[1:]
data = json.load(open(path))
for p in data['projects']:
    if p['id'] == id:
        branches = p.setdefault('branches', [])
        existing = next((b for b in branches if b['name'] == branch_name), None)
        if existing:
            if branch_status: existing['status'] = branch_status
            if branch_note:   existing['note'] = branch_note
            print(f"✓ Updated branch {branch_name} on {p['name']}")
        else:
            branches.insert(0, {'name': branch_name, 'status': branch_status or 'active', 'note': branch_note or ''})
            print(f"✓ Added branch {branch_name} to {p['name']}")
        p['updatedAt'] = today
        break
else:
    print(f"Project '{id}' not found. Run: project ls")
    sys.exit(1)
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
    ;;

  ls|list)
    python3 - "$PROJECTS_FILE" << 'PYEOF'
import json, sys
data = json.load(open(sys.argv[1]))
print(f"\n{'ID':<30} {'STATUS':<10} {'STAGE'}")
print("─" * 70)
for p in data['projects']:
    print(f"{p['id']:<30} {p['status']:<10} {p.get('stage','')}")
print()
PYEOF
    ;;

  *)
    echo ""
    echo "Usage:"
    echo "  project ls                                           — list all projects"
    echo "  project log <id> \"<note>\"                           — add a log entry"
    echo "  project stage <id> \"<stage>\" \"<note>\"               — update stage"
    echo "  project status <id> active|paused|archived"
    echo "  project branch <id> \"<branch>\" active|paused|done \"<note>\"  — add/update branch"
    echo "  project recall <id>                                  — print recall command"
    echo ""
    ;;
esac
