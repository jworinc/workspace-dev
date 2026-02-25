# Workspace-Dev Onboarding

**Date**: 2026-02-25
**Purpose**: Quick reference for workspace-dev usage

---

## Overview

**Workspace-Dev** is the dedicated development workspace for active projects (dev/fixed work).

**Location**: `/Users/anton/.openclaw/workspace-dev`
**Git Remote**: github.com/jworinc/workspace-dev
**Type**: Monorepo (multiple projects in single repository)

---

## Project Summary

| Project | Language | Purpose | Status |
|---------|----------|----------|--------|
| **clog** | Go | Caddy log viewer | Active |
| **present** | Swift/SwiftUI | macOS app for URL slide presentations | Active |
| **xtool** | Swift/SwiftPM | Cross-platform Xcode replacement | Active |
| **monitor-openclaw** | TBD | OpenClaw monitoring tool | Planned |

---

## Workspace Comparison

### Workspace-AI (`/Users/anton/.openclaw/workspace-ai`)
**Purpose**: AI & development work
**Content**:
- OpenClaw CLI work and integrations
- AI development projects
- Documentation (docs/ folder)
- Obsidian vault work
- Viking/Semantica deployment
- NVStack implementation

**When to Use**:
- OpenClaw development
- AI tools integration
- Documentation work
- Obsidian tasks
- Knowledge graph deployment

---

### Workspace-Dev (`/Users/anton/.openclaw/workspace-dev`)
**Purpose**: General dev/fixed work
**Content**:
- clog (Caddy log viewer)
- present (macOS presentation app)
- xtool (Xcode replacement)
- monitor-openclaw (planned)
- General development work

**When to Use**:
- Fixing bugs in existing projects
- New feature development
- Cross-platform tooling
- DevOps/monitoring
- Any general dev work (not AI-specific)

---

## Work-Log System

**File**: `WORK-LOG.md`

**Purpose**: System for tracking work entries with structured logging

**Usage**:
1. Each work entry gets a timestamped entry
2. Format: Date, project, description
3. Provides audit trail of development work

**Example**:
```markdown
## 2026-02-25

### clog
- [10:00] Started investigation of log parsing issue
- [10:30] Added regex filter for request IDs
- [11:00] Testing with sample Caddy logs

### xtool
- [13:00] Refactored XKit service initialization
- [14:30] Added error handling for Apple Developer Services
```

---

## Project-Specific Documentation

Each project has its own README.md:

| Project | README | Key Sections |
|---------|----------|--------------|
| **clog** | `clog/README.md` | Features, usage, Caddy log format |
| **present** | `present/README.md` | Features, slide format, macOS-specific notes |
| **xtool** | `xtool/README.md` | Commands, XKit library, build system |
| **monitor-openclaw** | TBD | Not yet created |

---

## Git Workflow

**Single Repository**: All projects in one monorepo

**Structure**:
```
workspace-dev/
├── clog/
│   ├── go.mod
│   ├── main.go
│   └── README.md
├── present/
│   ├── Present/
│   ├── Sources/
│   ├── Makefile
│   └── README.md
├── xtool/
│   ├── Sources/
│   ├── Tests/
│   └── README.md
├── README.md (workspace overview)
└── WORK-LOG.md (work tracking)
```

**Branching**:
- Each project can use its own branches
- Main branch for stable releases
- Feature branches for new work

---

## Quick Reference

### For AI/Assistant Work
**Use**: `workspace-ai`

**Examples**:
- OpenClaw CLI development
- AI tool integration
- Obsidian + Viking setup
- Documentation for AI work

### For Dev/Fixed Work
**Use**: `workspace-dev`

**Examples**:
- Fixing clog bugs
- Adding features to present
- Refactoring xtool
- General development tasks

---

## When to Use Work-Log

**When to Log Entry**:
- Start working on a project
- Complete a feature/bug fix
- Make a significant architectural decision
- Deploy a project
- Start/finish a major task

**Format**:
```markdown
## YYYY-MM-DD

### [Project Name]
- [Time] Description of work
- [Time] Description of work
```

---

## Getting Started

### Working with clog

```bash
cd ~/workspace-dev/clog
go run .
# or
make build
./clog --file /path/to/caddy.log
```

### Working with present

```bash
cd ~/workspace-dev/present
make build
open build/present.app
```

### Working with xtool

```bash
cd ~/workspace-dev/xtool
swift build
# or
swift run
```

---

## Key Files

| File | Purpose |
|-------|----------|
| `README.md` | Workspace overview |
| `WORK-LOG.md` | Work entry tracking |
| `clog/README.md` | Caddy log viewer details |
| `present/README.md` | Present app details |
| `xtool/README.md` | Xcode replacement details |

---

## Integration with Workspace-AI

### Cross-Workspace Projects

Some projects may span both workspaces:

**OpenBrowserClaw**:
- Workspace-AI: Development (most recent session)
- Workspace-Dev: Could also work on here

**NVStack**:
- Workspace-AI: Implementation and TDD
- Workspace-Dev: General development if needed

### Documentation Strategy

- **Workspace-AI**: AI-specific documentation in `docs/` folder
- **Workspace-Dev**: Project-specific READMEs in each project
- **MEMORY.md** (in workspace-ai): Long-term memory for both workspaces

---

## Summary

**Workspace-Dev** is your dedicated development workspace for:
- Existing projects (clog, present, xtool)
- New development work
- General dev/fixed tasks
- Bug fixes and feature additions

**Workspace-AI** remains for:
- OpenClaw development
- AI tool integration
- Documentation and knowledge work

**Use Work-Log** to track all development work in workspace-dev.

---

**Workspace-dev onboarded.** ✅
