#!/usr/bin/env python3
"""
GTD Commands for OpenClaw Workspace
Handles task creation, project management, and GTD workflow
"""

import os
import re
import sys
import yaml
import subprocess
from datetime import datetime
from pathlib import Path

# Workspace root
WORKSPACE = Path.home() / ".openclaw/workspace"
ACTIVE_FILE = WORKSPACE / ".active"

# Paths
PROJECTS_DIR = WORKSPACE / "projects"
THREADS_DIR = WORKSPACE / "threads"
SKILLS_DIR = WORKSPACE / "skills"
MEMORY_DIR = WORKSPACE / "memory"

# Templates
TASK_TEMPLATE = """---
id: {id}
project: {project}
title: {title}
status: {status}
energy: {energy}
due: {due}
context: {context}
tags: {tags}
created: {created}
---

# {title}

↑ Part of [[../README|P{project} {project_name}]]

## Context
{context}

## Next Action
- [ ] [Specific next step] #next

## Definition of Done
- [ ] [Criteria 1]
- [ ] [Criteria 2]

## Notes
{notes}
"""

PROJECT_TEMPLATE = """---
id: {id}
title: {title}
status: {status}
area: {area}
created: {created}
stashed: false
tags: [project]
---

# {title}

## Overview
{overview}

## Tasks
- [ ] [[tasks/K001|K001]]: [First task] #next

## Last Session
[{date}] - Initial project creation

## Open Questions
- [?] → [?]

## Related
- [[threads/T001|T001]]: [Thread description]

## Resources
- [Links to code, docs, etc.]
"""


def get_next_id(prefix="K"):
    """Get next global ID for tasks (K001, K002...) or projects (P001, P002...)"""
    if prefix == "K":
        pattern = "K[0-9]*.md"
        folder = PROJECTS_DIR
    else:
        pattern = "P[0-9]*"
        folder = PROJECTS_DIR
    
    # Find all IDs
    ids = []
    for path in folder.rglob(pattern):
        if prefix == "K":
            match = re.search(r'K(\d+)', path.name)
        else:
            match = re.search(r'P(\d+)', path.name)
        
        if match:
            ids.append(int(match.group(1)))
    
    if ids:
        next_id = max(ids) + 1
    else:
        next_id = 1
    
    return f"{prefix}{next_id:03d}"


def get_active_project():
    """Get current active project ID"""
    if ACTIVE_FILE.exists():
        return ACTIVE_FILE.read_text().strip()
    return None


def set_active_project(project_id):
    """Set active project"""
    ACTIVE_FILE.write_text(project_id)


def create_task(title, project_id=None, status="next", **kwargs):
    """Create a new task"""
    # Get project ID
    if not project_id:
        project_id = get_active_project()
    
    if not project_id:
        print("❌ No active project. Use ':switch P00X' first")
        return None
    
    # Find project folder
    project_folder = PROJECTS_DIR / f"{project_id}-*"
    project_folder = list(PROJECTS_DIR.glob(f"{project_id}-*"))
    
    if not project_folder:
        print(f"❌ Project {project_id} not found")
        return None
    
    project_folder = project_folder[0]
    project_name = project_folder.name.split(f"{project_id}-")[1]
    
    # Get next task ID
    task_id = get_next_id("K")
    
    # Create slug
    slug = title.lower().replace(" ", "-")[:50]
    task_file = project_folder / "tasks" / f"{task_id}-{slug}.md"
    
    # Ensure tasks directory exists
    task_file.parent.mkdir(exist_ok=True)
    
    # Fill template
    content = TASK_TEMPLATE.format(
        id=task_id,
        project=project_id,
        title=title,
        status=status,
        energy=kwargs.get("energy", "medium"),
        due=kwargs.get("due", ""),
        context=kwargs.get("context", "computer"),
        tags=str(kwargs.get("tags", ["next"])),
        created=datetime.now().strftime("%Y-%m-%d"),
        context_desc=kwargs.get("context_desc", "Task created from conversation"),
        project_name=project_name,
        notes=kwargs.get("notes", "")
    )
    
    # Write task file
    task_file.write_text(content)
    
    # Git add the specific task file
    subprocess.run(
        ["git", "add", str(task_file.relative_to(WORKSPACE))],
        cwd=WORKSPACE,
        check=True
    )
    
    # Git commit
    subprocess.run(
        ["git", "commit", f"-m", f"Add task: {task_id} - {title}"],
        cwd=WORKSPACE,
        check=True
    )
    print(f"🔀 Git: Committed task {task_id}")
    
    # Update project README with task link
    readme = project_folder / "README.md"
    if readme.exists():
        readme_content = readme.read_text()
        
        # Add to Tasks section
        tasks_section = re.search(r'## Tasks\n', readme_content)
        if tasks_section:
            new_task = f"- [ ] [[tasks/{task_id}|{task_id}]]: {title} #next\n"
            readme_content = re.sub(
                r'## Tasks\n',
                f'## Tasks\n{new_task}',
                readme_content
            )
            readme.write_text(readme_content)
    
    print(f"✅ Created task: {task_id} in {project_id}")
    print(f"   File: {task_file}")
    
    # Git commit: Add task
    call_git_helper("commit", f"Add task: {task_id} - {title}")
    
    return task_id


def update_memory(message):
    """Add entry to today's memory log"""
    today = datetime.now().strftime("%Y-%m-%d")
    memory_file = MEMORY_DIR / f"{today}.md"
    
    # Create memory file if not exists
    if not memory_file.exists():
        header = f"# Memory: {today}\n\n## Activities\n"
        memory_file.write_text(header)
    
    # Append message
    memory_file.write_text(f"- {message}\n")


def call_git_helper(command, message=""):
    """Call GTD git helper script"""
    git_helper = WORKSPACE / "scripts" / "gtd_git_helper.sh"
    
    try:
        if command == "commit":
            subprocess.run(
                [str(git_helper), "commit", message],
                check=True,
                capture_output=True
            )
        elif command == "push":
            subprocess.run(
                [str(git_helper), "push"],
                check=True,
                capture_output=True
            )
        elif command == "status":
            subprocess.run(
                [str(git_helper), "status"],
                check=True,
                capture_output=True
            )
        elif command == "stash":
            subprocess.run(
                [str(git_helper), "stash"],
                check=True,
                capture_output=True
            )
        elif command == "init":
            subprocess.run(
                [str(git_helper), "init"],
                check=True,
                capture_output=True
            )
    except subprocess.CalledProcessError as e:
        print(f"⚠️  Git helper error: {e}")
        return False
    
    return True


def index_into_semantica(title, context, rationale):
    """Add a decision to Semantica and index into Viking"""
    semantica_dir = WORKSPACE / "semantica"
    decisions_dir = semantica_dir / "decisions"
    
    if not semantica_dir.exists():
        return False
        
    # 1. Get next ID
    try:
        files = list(decisions_dir.glob("DEC-*.json"))
        if not files:
            next_id = "DEC-001"
        else:
            ids = [int(re.search(r'DEC-(\d+)', f.name).group(1)) for f in files]
            next_id = f"DEC-{max(ids) + 1:03d}"
    except Exception:
        next_id = "DEC-002" # Fallback
        
    # 2. Create JSON
    timestamp = datetime.now().isoformat() + "Z"
    decision_data = {
        "id": next_id,
        "timestamp": timestamp,
        "decision": title,
        "context": context,
        "rationale": rationale,
        "conflicts": [],
        "related_decisions": [],
        "viking_uri": f"viking://logic/decisions/{next_id}.json"
    }
    
    decision_file = decisions_dir / f"{next_id}.json"
    import json
    with decision_file.open("w") as f:
        json.dump(decision_data, f, indent=2)
        
    print(f"🧠 Semantica: Logged decision {next_id}")
    
    # 3. Run Indexer
    try:
        subprocess.run(
            ["bash", str(semantica_dir / "index.sh")],
            cwd=semantica_dir,
            capture_output=True,
            text=True
        )
        print(f"✅ Viking: Indexed decision {next_id}")
    except Exception as e:
        print(f"⚠️  Viking index error: {e}")
        
    return next_id



def cmd_add_task(args):
    """Handle ':add task [description]'"""
    if not args:
        print("❌ Usage: :add task [task description]")
        return
    
    title = " ".join(args)
    task_id = create_task(title)
    
    if task_id:
        update_memory(f"Created task [[projects/*/tasks/{task_id}|{task_id}]]: {title}")
        return True
    
    return False


def cmd_defer(args):
    """Handle ':defer [item] [P00X]'"""
    if not args:
        print("❌ Usage: :defer [item description] [P00X (optional)]")
        return
    
    # Parse args for optional project ID
    project_id = None
    title_parts = []
    
    for arg in args:
        if re.match(r'^P\d+$', arg):
            project_id = arg
        else:
            title_parts.append(arg)
    
    title = " ".join(title_parts)
    
    # Create task with status: later
    task_id = create_task(title, project_id=project_id, status="later")
    
    if task_id:
        update_memory(f"Deferred task [[projects/*/tasks/{task_id}|{task_id}]]: {title}")
        return True
    
    return False


def cmd_later(args):
    """Handle ':later [item]'"""
    if not args:
        print("❌ Usage: :later [item description]")
        return
    
    title = " ".join(args)
    someday = WORKSPACE / "Someday.md"
    
    # Append to Someday.md
    today = datetime.now().strftime("%Y-%m-%d")
    entry = f"- [ ] {title}\n"
    
    content = someday.read_text()
    if f"## {today}" not in content:
        content = content.replace(
            "---\n",
            f"---\n\n## {today}\n{entry}"
        )
    else:
        content = re.sub(
            f"## {today}\n",
            f"## {today}\n{entry}",
            content
        )
    
    someday.write_text(content)
    
    print(f"✅ Added to Someday.md: {title}")
    update_memory(f"Later item: {title}")
    
    return True


def cmd_stash(args):
    """Handle ':stash'"""
    project_id = get_active_project()
    
    if not project_id:
        print("❌ No active project to stash")
        return False
    
    # Find project folder
    project_folder = list(PROJECTS_DIR.glob(f"{project_id}-*"))
    
    if not project_folder:
        print(f"❌ Project {project_id} not found")
        return False
    
    project_folder = project_folder[0]
    readme = project_folder / "README.md"
    
    # Update README with stashed: true
    if readme.exists():
        content = readme.read_text()
        content = re.sub(r'stashed: false', 'stashed: true', content)
        readme.write_text(content)
    
    # Create stash entry
    stash_file = PROJECTS_DIR / "P000-STASH" / f"{project_id}.md"
    stash_file.write_text(f"↑ Project: [[{project_folder.name}/README|{project_id}]]\n\n")
    
    # Clear active
    ACTIVE_FILE.write_text("")
    
    print(f"✅ Stashed project: {project_id}")
    update_memory(f"Stashed project [[{project_folder.name}/README|{project_id}]]")
    
    # Git commit: Stash project
    call_git_helper("stash")
    
    return True


def cmd_switch(args):
    """Handle ':switch P00X' or ':recall P00X'"""
    if not args:
        print("❌ Usage: :switch P00X")
        return False
    
    project_id = args[0]
    
    if not re.match(r'^P\d+$', project_id):
        print(f"❌ Invalid project ID: {project_id}")
        return False
    
    # Find project folder
    project_folder = list(PROJECTS_DIR.glob(f"{project_id}-*"))
    
    if not project_folder:
        print(f"❌ Project {project_id} not found")
        return False
    
    project_folder = project_folder[0]
    readme = project_folder / "README.md"
    
    # Unstash if needed
    if readme.exists():
        content = readme.read_text()
        content = re.sub(r'stashed: true', 'stashed: false', content)
        readme.write_text(content)
    
    # Set active
    set_active_project(project_id)
    
    print(f"✅ Switched to project: {project_id}")
    print(f"   Path: {project_folder}")
    
    # Git commit: Switch project
    call_git_helper("commit", f"Switch to project: {project_id}")
    
    # Show README preview
    if readme.exists():
        print(f"\n📄 {project_folder.name}:")
        for line in readme.read_text().split('\n')[:15]:
            print(f"   {line}")
    
    return True


def cmd_stashed(args):
    """Handle ':stashed'"""
    stash_dir = PROJECTS_DIR / "P000-STASH"
    
    if not stash_dir.exists():
        print("❌ No stashed projects")
        return True
    
    print("📦 Stashed Projects:")
    
    for stash_file in stash_dir.glob("P*.md"):
        content = stash_file.read_text()
        project_match = re.search(r'\[\[([^|\]]+)\|([^|\]]+)\]\]', content)
        
        if project_match:
            project_link = project_match.group(1)
            project_id = project_match.group(2)
            print(f"   - [[{project_link}|{project_id}]]")
    
    return True


def cmd_future(args):
    """Handle ':future'"""
    print("🔮 Future Projects (TBD/seeds):")
    
    for readme in PROJECTS_DIR.glob("P00*/README.md"):
        content = readme.read_text()
        
        if "status: future" in content:
            # Extract project info
            id_match = re.search(r'id: (P\d+)', content)
            title_match = re.search(r'title: ([^\n]+)', content)
            
            if id_match and title_match:
                project_id = id_match.group(1)
                title = title_match.group(1)
                print(f"   - {project_id}: {title}")
    
    return True


def cmd_gtd(args):
    """Handle ':gtd'"""
    print("📊 GTD Health Dashboard")
    print("=" * 50)
    
    # Tasks by status
    print("\n📋 Tasks by Status:")
    statuses = {}
    
    for task_file in PROJECTS_DIR.rglob("K*.md"):
        content = task_file.read_text()
        status_match = re.search(r'status: (\w+)', content)
        
        if status_match:
            status = status_match.group(1)
            statuses[status] = statuses.get(status, 0) + 1
    
    for status in ["inbox", "next", "waiting", "later", "done"]:
        count = statuses.get(status, 0)
        emoji = {"inbox": "📥", "next": "▶️", "waiting": "⏸️", "later": "📅", "done": "✅"}
        print(f"   {emoji.get(status, '')} {status}: {count}")
    
    # Tasks waiting > 3 days
    print("\n⏰ Tasks Waiting > 3 Days:")
    
    three_days_ago = datetime.now().timestamp() - (3 * 24 * 60 * 60)
    
    for task_file in PROJECTS_DIR.rglob("K*.md"):
        if task_file.stat().st_mtime < three_days_ago:
            content = task_file.read_text()
            
            if "status: waiting" in content:
                id_match = re.search(r'id: (K\d+)', content)
                title_match = re.search(r'title: ([^\n]+)', content)
                
                if id_match and title_match:
                    task_id = id_match.group(1)
                    title = title_match.group(1)
                    days = int((datetime.now().timestamp() - task_file.stat().st_mtime) / (24 * 60 * 60))
                    print(f"   - {task_id}: {title} ({days} days)")
    
    # Tasks next > 7 days
    print("\n🎯 Tasks Next > 7 Days:")
    
    seven_days_ago = datetime.now().timestamp() - (7 * 24 * 60 * 60)
    
    for task_file in PROJECTS_DIR.rglob("K*.md"):
        if task_file.stat().st_mtime < seven_days_ago:
            content = task_file.read_text()
            
            if "status: next" in content:
                id_match = re.search(r'id: (K\d+)', content)
                title_match = re.search(r'title: ([^\n]+)', content)
                
                if id_match and title_match:
                    task_id = id_match.group(1)
                    title = title_match.group(1)
                    days = int((datetime.now().timestamp() - task_file.stat().st_mtime) / (24 * 60 * 60))
                    print(f"   - {task_id}: {title} ({days} days) → break down or demote?")
    
    # Stashed projects > 7 days
    print("\n📦 Stashed Projects > 7 Days:")
    
    seven_days_ago = datetime.now().timestamp() - (7 * 24 * 60 * 60)
    
    for stash_file in PROJECTS_DIR.glob("P000-STASH/P*.md"):
        if stash_file.stat().st_mtime < seven_days_ago:
            content = stash_file.read_text()
            project_match = re.search(r'\[\[([^|\]]+)\|([^|\]]+)\]\]', content)
            
            if project_match:
                project_link = project_match.group(1)
                project_id = project_match.group(2)
                days = int((datetime.now().timestamp() - stash_file.stat().st_mtime) / (24 * 60 * 60))
                print(f"   - [[{project_link}|{project_id}]] ({days} days)")
    
    print("\n💡 Actions:")
    print("   ':switch P00X' - Recall stashed project")
    print("   ':demote K00X later' - Demote next task")
    print("   ':unblock K00X' - Update waiting task")
    
    return True


def cmd_viz(args):
    """Show GTD git visualization"""
    print("📈 GTD Git Visualization:")
    print("-" * 30)
    
    # Check if lazygit is installed
    lazygit = subprocess.run(["which", "lazygit"], capture_output=True, text=True)
    
    if lazygit.returncode == 0:
        print("💡 Suggestion: Run 'lazygit' for full interactive UI")
        print("-" * 30)
    
    # Show git graph
    subprocess.run([
        "git", "log", "--graph", "--oneline", "--decorate", "--all", "-n", "15"
    ], cwd=WORKSPACE)
    
    return True


def cmd_cb(args):
    """Integrate GTD visualization with CodexBar usage"""
    print("📊 CodexBar + GTD Combined Dashboard:")
    print("=" * 50)
    
    # 1. Get CodexBar Usage
    print("\n💰 Model Usage & Cost (via CodexBar):")
    print("-" * 30)
    
    try:
        cb_result = subprocess.run(
            ["codexbar", "usage", "--provider", "all"],
            capture_output=True,
            text=True
        )
        if cb_result.returncode == 0:
            # Print first 15 lines of usage
            for line in cb_result.stdout.split('\n')[:15]:
                if line.strip():
                    print(f"   {line}")
        else:
            print("   ⚠️  CodexBar usage lookup failed")
    except Exception as e:
        print(f"   ⚠️  CodexBar not found or error: {e}")
    
    # 2. Get GTD Progress (Recent Commits)
    print("\n📈 Recent GTD Progress (Git History):")
    print("-" * 30)
    subprocess.run([
        "git", "log", "--graph", "--oneline", "--decorate", "--all", "-n", "8"
    ], cwd=WORKSPACE)
    
    # 3. TIL Summary
    print("\n📝 Recent Today I Learned (TIL):")
    print("-" * 30)
    til_file = MEMORY_DIR / "TIL.md"
    if til_file.exists():
        lines = til_file.read_text().split('\n')
        # Show last 3 TIL entries (approx 15 lines)
        for line in lines[-15:]:
            if line.strip():
                print(f"   {line}")
    else:
        print("   (No TIL entries yet)")
    
    # 4. Task Status Summary
    print("\n📋 Current GTD Status:")
    print("-" * 30)
    cmd_gtd([])
    
    return True


def cmd_til(args):
    """Log a Today I Learned (TIL) entry"""
    if not args:
        print("❌ Usage: til [discovery]")
        return False
    
    discovery = " ".join(args)
    today = datetime.now().strftime("%Y-%m-%d %H:%M")
    
    til_file = MEMORY_DIR / "TIL.md"
    
    # Create TIL file if not exists
    if not til_file.exists():
        header = "# Today I Learned (TIL)\n\nTechnical saves, discoveries, and lessons learned.\n\n---\n"
        til_file.write_text(header)
    
    # Append discovery
    entry = f"\n### {today}\n- {discovery}\n"
    
    with til_file.open("a") as f:
        f.write(entry)
    
    print(f"✅ Logged TIL: {discovery}")
    
    # Commit TIL
    subprocess.run(
        ["git", "add", str(til_file.relative_to(WORKSPACE))],
        cwd=WORKSPACE,
        check=True
    )
    subprocess.run(
        ["git", "commit", "-m", f"TIL: {discovery[:50]}..."],
        cwd=WORKSPACE,
        check=True
    )
    print("🔀 Git: Committed TIL")
    
    # 🧠 NEW: Index into Semantica/Viking
    index_into_semantica(
        title=f"TIL: {discovery[:100]}",
        context="Today I Learned (Technical Save)",
        rationale=discovery
    )
    
    return True


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("❌ Usage: gtd_commands.py [command] [args...]")
        print("\nAvailable commands:")
        print("   add task [desc]      - Create new task")
        print("   defer [item] [P00X]  - Capture aside for project")
        print("   later [item]         - Append to Someday.md")
        print("   stash               - Stash current project")
        print("   switch P00X         - Switch project")
        print("   stashed             - List stashed projects")
        print("   future              - List future projects")
        print("   gtd                 - Show GTD dashboard")
        print("   viz                 - Show Git visualization")
        print("   status              - Alias for gtd")
        print("   cb                  - Combined CodexBar + GTD viz")
        print("   til [discovery]      - Log a Today I Learned")
        return
    
    command = sys.argv[1]
    args = sys.argv[2:]
    
    # Command dispatch
    commands = {
        "add": cmd_add_task,
        "defer": cmd_defer,
        "later": cmd_later,
        "stash": cmd_stash,
        "switch": cmd_switch,
        "recall": cmd_switch,  # Alias
        "stashed": cmd_stashed,
        "future": cmd_future,
        "gtd": cmd_gtd,
        "status": cmd_gtd,     # Alias
        "viz": cmd_viz,
        "cb": cmd_cb,
        "til": cmd_til,
        "snap": lambda args: subprocess.run([str(WORKSPACE / "scripts" / "snap.sh")] + args).returncode == 0,
        "find": lambda args: subprocess.run([str(WORKSPACE / "scripts" / "find.sh")] + args).returncode == 0,
        "sync-db": lambda args: subprocess.run([str(WORKSPACE / "scripts" / "sync-db.sh")] + args).returncode == 0,
        "walkthrough": lambda args: subprocess.run([str(WORKSPACE / "scripts" / "walkthrough.sh")] + args).returncode == 0,
    }
    
    if command in commands:
        success = commands[command](args)
        sys.exit(0 if success else 1)
    else:
        print(f"❌ Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
