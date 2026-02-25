#!/usr/bin/env python3
"""
GTD Health Alerts
Checks for aging tasks, stashed projects, and generates alerts
"""

import os
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path

# Workspace root
WORKSPACE = Path.home() / ".openclaw/workspace"
PROJECTS_DIR = WORKSPACE / "projects"


def check_aging_tasks():
    """Check for tasks waiting > 3 days and next > 7 days"""
    alerts = []
    
    # 3 days ago
    three_days_ago = datetime.now() - timedelta(days=3)
    
    # 7 days ago
    seven_days_ago = datetime.now() - timedelta(days=7)
    
    for task_file in PROJECTS_DIR.rglob("K*.md"):
        content = task_file.read_text()
        mtime = datetime.fromtimestamp(task_file.stat().st_mtime)
        
        # Waiting > 3 days
        if "status: waiting" in content and mtime < three_days_ago:
            id_match = re.search(r'id: (K\d+)', content)
            title_match = re.search(r'title: ([^\n]+)', content)
            
            if id_match and title_match:
                task_id = id_match.group(1)
                title = title_match.group(1)
                days = (datetime.now() - mtime).days
                alerts.append(f"⏰ [[{task_file}|{task_id}]]: {title} ({days} days) - Waiting")
        
        # Next > 7 days
        if "status: next" in content and mtime < seven_days_ago:
            id_match = re.search(r'id: (K\d+)', content)
            title_match = re.search(r'title: ([^\n]+)', content)
            
            if id_match and title_match:
                task_id = id_match.group(1)
                title = title_match.group(1)
                days = (datetime.now() - mtime).days
                alerts.append(f"🎯 [[{task_file}|{task_id}]]: {title} ({days} days) - Next > 7 days → break down or demote?")
    
    return alerts


def check_stashed_projects():
    """Check for stashed projects > 7 days"""
    alerts = []
    
    seven_days_ago = datetime.now() - timedelta(days=7)
    stash_dir = PROJECTS_DIR / "P000-STASH"
    
    if not stash_dir.exists():
        return alerts
    
    for stash_file in stash_dir.glob("P*.md"):
        mtime = datetime.fromtimestamp(stash_file.stat().st_mtime)
        
        if mtime < seven_days_ago:
            content = stash_file.read_text()
            project_match = re.search(r'\[\[([^|\]]+)\|([^|\]]+)\]\]', content)
            
            if project_match:
                project_link = project_match.group(1)
                project_id = project_match.group(2)
                days = (datetime.now() - mtime).days
                alerts.append(f"📦 [[{project_link}|{project_id}]] stashed for {days} days - Recall?")
    
    return alerts


def check_inbox_overflow():
    """Check for too many inbox tasks"""
    alerts = []
    
    inbox_count = 0
    for task_file in PROJECTS_DIR.rglob("K*.md"):
        content = task_file.read_text()
        
        if "status: inbox" in content:
            inbox_count += 1
    
    if inbox_count > 10:
        alerts.append(f"📥 {inbox_count} tasks in inbox - Consider triage")
    
    return alerts


def generate_alerts():
    """Generate all GTD health alerts"""
    all_alerts = []
    
    # Check aging tasks
    all_alerts.extend(check_aging_tasks())
    
    # Check stashed projects
    all_alerts.extend(check_stashed_projects())
    
    # Check inbox overflow
    all_alerts.extend(check_inbox_overflow())
    
    return all_alerts


def format_alert(alerts: list) -> str:
    """Format alerts for display"""
    if not alerts:
        return "✅ GTD Health: No alerts"
    
    today = datetime.now().strftime("%Y-%m-%d")
    output = f"\n⚠️ GTD Health Alerts - {today}\n"
    output += "=" * 50 + "\n\n"
    
    for alert in alerts:
        output += f"{alert}\n"
    
    output += "\n" + "=" * 50 + "\n"
    output += "💡 Actions:\n"
    output += "   ':unblock K00X' - Update waiting task\n"
    output += "   ':demote K00X later' - Demote next task\n"
    output += "   ':recall P00X' - Recall stashed project\n"
    output += "   ':gtd' - Show full dashboard\n"
    
    return output


def main():
    """Main entry point"""
    alerts = generate_alerts()
    alert_text = format_alert(alerts)
    
    print(alert_text)
    
    # Return exit code based on alerts
    if alerts:
        sys.exit(1)  # Exit with error if alerts present
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
