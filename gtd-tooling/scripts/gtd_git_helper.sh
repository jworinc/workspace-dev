#!/bin/bash

# GTD Git Helper
# Automatically commits GTD actions to Git

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}$1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Commands: gtd_commit, gtd_push, gtd_stash, gtd_init

case "$1" in
  init)
    # Initialize GTD git repo
    log "Initializing GTD workspace as Git repo..."

    # Initialize if not already
    if [ ! -d ".git" ]; then
      git init
    fi

    # Initial commit
    git add .
    if git diff --cached --quiet HEAD; then
      git commit -m "Initial GTD workspace"
      success "GTD workspace initialized as Git repo"
    else
      log "No changes to commit (already initialized)"
    fi
    ;;

  commit)
    # Commit all GTD changes
    MESSAGE="$2"

    if [ -z "$MESSAGE" ]; then
      MESSAGE="GTD update"
    fi

    git add .
    if git diff --cached --quiet HEAD; then
      git commit -m "$MESSAGE"
      success "Committed: $MESSAGE"
    else
      log "No changes to commit"
    fi
    ;;

  push)
    # Push GTD repo to remote
    log "Pushing GTD workspace to remote..."

    # Check if origin exists
    if git remote get-url origin > /dev/null 2>&1; then
      git push origin HEAD
      success "Pushed to origin"
    else
      warn "No origin remote configured"
      log "To add remote:"
      echo "  git remote add origin https://github.com/username/repo.git"
    fi
    ;;

  stash)
    # Stash current project state
    log "Stashing GTD context..."

    if [ -f ".active" ]; then
      ACTIVE=$(cat .active)
      git add ".active"
      git commit -m "GTD stash: Active project is $ACTIVE"
      success "Stashed: $ACTIVE"
    else
      warn "No active project to stash"
    fi
    ;;

  status)
    # Show GTD git status
    log "GTD Git Status:"
    echo ""
    git status --short
    echo ""

    log "Recent commits:"
    git log --oneline -5
    ;;

  *)
    echo "Usage: gtd_git_helper.sh [command] [message]"
    echo ""
    echo "Commands:"
    echo "  init              Initialize GTD workspace as Git repo"
    echo "  commit [message]  Commit all changes"
    echo "  push              Push to remote"
    echo "  stash             Stash current active project"
    echo "  status            Show git status and recent commits"
    echo ""
    exit 1
    ;;
esac
