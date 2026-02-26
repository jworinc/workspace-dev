# workspace-dev - Detailed File & Project Overview

> **Date**: 2026-02-26
> **Status**: Active development workspace
> **Repo**: https://github.com/jworinc/workspace-dev

---

## 📋 Modified Files

### **WORK-LOG.md** (Modified)
- **Purpose**: Track all development work across projects
- **Changes**: Added entry for browser-tools-mcp-stripped (onboarded, created GitHub repo, symlinked)
- **Last Update**: 2026-02-26

### **gtd-tooling/scripts/gtd_commands.py** (Modified)
- **Purpose**: GTD command dispatcher
- **Changes**: Added "index" command
  ```python
  "index": lambda args: subprocess.run([str(WORKSPACE / "scripts" / "index-workspace.sh")] + args).returncode == 0,
  ```
- **Function**: Triggers workspace indexing via PageIndex

### **gtd-tooling/scripts/index-workspace.sh** (Modified)
- **Purpose**: PageIndex wrapper for OpenClaw
- **Function**:
  1. Bundle workspace (bundle-workspace.sh)
  2. Run PageIndex reasoning scan on workspace_bundle.md
  3. Copy workspace_tree.json to workspace/memory/
  4. Convert to Obsidian-friendly Markdown (Reasoning-Map.md)
- **Model**: GLM-4.7
- **Output**: `workspace/memory/workspace_tree.json`

### **gtd-tooling/scripts/maintenance.sh** (Modified)
- **Purpose**: GTD maintenance tasks
- **Changes**: Unknown (git diff not captured)

### **clog** (Submodule - Modified)
- **Purpose**: Caddy log viewer (Go-based)
- **Status**: Modified content, untracked content

---

## 🗂️ Untracked Projects (To Be Added or Removed)

| Project | Type | Purpose | Status |
|---------|------|---------|--------|
| **2lane-tdd** | Python/Testing | Parallel TDD framework for maintaining AS-IS and TO-BE versions | ✅ Active |
| **ChatIndex** | Python/Tree Indexing | Tree indexing for long conversations with hierarchical reasoning | ✅ Active |
| **PageIndex** | Python/Reasoning | Tree-of-content extraction and LLM reasoning for large docs | ✅ Active |
| **deepsearch** | Python/Claude Code | 3-agent research orchestrator (Claude Code, Codex, Gemini) | ✅ Active |
| **nanoclaw** | Python/CLI | Nano-sized OpenClaw CLI (lightweight alternative) | ✅ Active |
| **openclaw-mission-control** | TypeScript/React | Centralized operations and governance platform for OpenClaw | ⚠️ Old (duplicate of workspace/) |
| **oss-test-suite** | Python/TestSprite | Self-hosted local-first AI testing framework (no cloud dependency) | ✅ Active |

---

## 📁 Project Details

### **2lane-tdd**
- **Type**: Python/Testing framework
- **Purpose**: Parallel development framework for maintaining AS-IS (current) and TO-BE (refactored) versions simultaneously, using tests to guarantee correctness
- **Structure**:
  - `.active-lane` - Current lane tracking
  - `docs/` - Documentation
  - `.pytest_cache/` - Test cache
- **Key Files**:
  - `README.md` (8 KB) - Philosophy and quick start
  - `QUICKSTART.md` (9.8 KB) - Quick start guide
  - `CAPABILITIES-SUMMARY.md` (10.9 KB) - Capabilities summary
- **Status**: Active, developed in 2026-02-25

---

### **ChatIndex**
- **Type**: Python/Tree Indexing
- **Purpose**: Context management system for LLMs to efficiently navigate and utilize long conversation histories through hierarchical tree-based indexing
- **Structure**:
  - `.codex/` - Codex integration
  - `.pytest_cache/` - Test cache
  - `.venv/` - Virtual environment
  - `CI/` - CI/CD pipelines
- **Key Files**:
  - `README.md` - Tree indexing for long conversations
- **Status**: Active, updated 2026-02-26

---

### **PageIndex**
- **Type**: Python/Reasoning
- **Purpose**: Tree-of-content extraction and LLM reasoning for large documents, enabling structured navigation and intelligent retrieval
- **Structure**:
  - `.gitignore` - Git ignore
  - `.gitattributes` - Git attributes
  - `CHANGELOG.md` - Changelog
  - `LICENSE` - MIT license
- **Key Files**:
  - `README.md` - Vectify.ai branding and description
- **Status**: Active, imported 2026-02-25

---

### **deepsearch**
- **Type**: Python/Claude Code Plugin
- **Purpose**: Orchestrates deep research across 3 coding agents (Claude Code, Codex CLI, Gemini CLI) running in parallel with cross-pollination refinement and final synthesis
- **Structure**:
  - `.claude/` - Claude Code config
  - `.claude-plugin/` - Claude Code plugin config
  - `.git/` - Git
  - `.gitignore` - Git ignore
  - `CHANGELOG.md` - Changelog
- **Key Files**:
  - `README.md` - Deepsearch with Vibeproxy routing
- **Status**: Active, updated 2026-02-26 (Vibeproxy adaptation)

---

### **nanoclaw**
- **Type**: Python/CLI
- **Purpose**: Nano-sized OpenClaw CLI (lightweight alternative to full OpenClaw)
- **Structure**:
  - `.claude/` - Claude Code config
  - `.codex/` - Codex config
  - `.env.example` - Environment template
  - `.github/` - GitHub workflows
  - `.gitignore` - Git ignore
- **Key Files**:
  - `README.md` - NanoClaw branding and description
- **Status**: Active, cloned 2026-02-26

---

### **openclaw-mission-control**
- **Type**: TypeScript/React
- **Purpose**: Centralized operations and governance platform for running OpenClaw across teams and organizations, with unified visibility, approval controls, and gateway-aware orchestration
- **Structure**:
  - `.dockerignore` - Docker ignore
  - `.env.example` - Environment template
  - `.github/` - GitHub workflows
  - `.gitignore` - Git ignore
  - `.markdownlint-cli2.yaml` - Markdown lint config
- **Key Files**:
  - `README.md` - OpenClaw Mission Control
- **Status**: ⚠️ Old (duplicate of workspace/openclaw-mission-control/)

---

### **oss-test-suite**
- **Type**: Python/TestSprite
- **Purpose**: Self-hosted, local-first AI testing framework for Web UIs and HTTP APIs, mimicking TestSprite workflow without cloud dependency
- **Structure**:
  - `.github/` - GitHub workflows
  - `api/` - API testing
  - `docs/` - Documentation
  - `infra/` - Infrastructure
  - `PROJECT_SUMMARY.md` - Project summary
- **Key Files**:
  - `README.md` - OSS Test Suite (TestSprite-style)
- **Status**: Active, imported 2026-02-25

---

## 🔗 Symlinked Projects

### **browser-tools-mcp-stripped** (Symlink)
- **Location**: `/Users/anton/Code/browser-tools-mcp-stripped` (symlinked from ~/Code/browser-tools-mcp-stripped)
- **Purpose**: Stripped MCP (Model Context Protocol) browser tools
- **Structure**:
  - `browser-tools-mcp/` - MCP tools
  - `browser-tools-server/` - MCP server
  - `chrome-extension/` - Chrome extension
  - `docs/` - Documentation
  - `full-cycle-test.js` - Full cycle test
  - `test-server.js` - Test server
- **Key Files**:
  - `README.md` - MCP browser tools
  - `LICENSE` - License
- **GitHub**: https://github.com/jworinc/browser-tools-mcp-stripped
- **Status**: Onboarded 2026-02-26 (11:40)

---

## 📝 Configuration Files

### **CLAUDE.md**
- **Purpose**: Dev workspace rules
- **Content**: "Follow patterns in rules/, Log corrections to [[LEARNED]]"

### **HANDOFF.md**
- **Purpose**: Dev session handoff
- **Context**:
  - Workspace: `/Users/anton/.openclaw/workspace-dev`
  - Agent: `dev` (👨‍💻)
  - Framework: Pro-Workflow (Split Memory, Learned Rules)
- **Current State**:
  - workspace-dev initialized
  - CLAUDE.md and rules/ directory created
  - LEARNED.md initialized
  - openclaw.json updated with `dev` agent
- **Next Steps**: Explore workspace, apply patterns, log learnings, deploy to cloud

### **LEARNED.md**
- **Purpose**: Self-correcting memory for learnings
- **Status**: Empty (attached image reference)

### **rules/** (Directory)
- **Purpose**: Project-specific guidance
- **Status**: Empty

---

## 📊 Summary

| Category | Count | Status |
|----------|--------|--------|
| **Modified Files** | 5 | To be committed |
| **Untracked Projects** | 7 | To be added or removed |
| **Symlinked Projects** | 1 | External reference |
| **Active Projects** | 6 | Ready to work |
| **Old/Duplicate** | 1 | openclaw-mission-control |

---

## 🎯 Next Steps

### **Immediate**
1. **Commit GTD tooling changes** (index command, index-workspace.sh)
2. **Decide on untracked projects**:
   - Add to monorepo?
   - Remove (if duplicate/old)?
   - Keep untracked?
3. **Fix clog submodule** (modified content, untracked content)

### **Short-term**
1. **Test PageIndex integration** with workspace indexing
2. **Review deepsearch Vibeproxy adaptation**
3. **Consider adding 2lane-tdd to monorepo**

---

## 📝 Git Status

```
Modified Files:
  - WORK-LOG.md
  - gtd-tooling/scripts/gtd_commands.py
  - gtd-tooling/scripts/index-workspace.sh
  - gtd-tooling/scripts/maintenance.sh
  - clog (submodule)

Untracked Files:
  - 2lane-tdd/
  - CLAUDE.md
  - ChatIndex/
  - HANDOFF.md
  - LEARNED.md
  - PageIndex/
  - browser-tools-mcp-stripped (symlink)
  - deepsearch/
  - nanoclaw/
  - openclaw-mission-control/
  - oss-test-suite/
```

---

**End of Overview**
