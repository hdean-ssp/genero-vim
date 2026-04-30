# Documentation Organization Guide

**Purpose**: Explain how documentation is organized and where to find what you need

**Last Updated**: April 1, 2026

---

## Overview

Documentation is organized into two categories:

1. **User-Facing** (in `docs/`) - For end users of the plugin
2. **Agent/Internal** (in `.kiro/`) - For developers and agents working on the project

---

## User-Facing Documentation (`docs/`)

These files are for end users who want to use or configure the plugin.

### Setup & Installation
- **SETUP.md** (root) - Quick 2-minute setup guide
- **docs/SETUP_FRESH_VIM.md** - Detailed fresh Vim installation
- **docs/NEOVIM_SETUP.md** - Neovim-specific setup
- **docs/QUICK_START.md** - User guide with examples

### Features & Configuration
- **docs/COMPATIBILITY.md** - Vim vs Neovim feature matrix
- **docs/CONFIGURATION_UPDATE_LUA_ENABLED.md** - Lua layer configuration
- **docs/FLOATING_WINDOW_CONFIGURATION.md** - Floating window options
- **docs/LUALINE_INTEGRATION.md** - Lualine statusline integration
- **docs/WHICH_KEY_INTEGRATION.md** - Which-key integration

### Feature Documentation
- **docs/COMPILER_INTEGRATION.md** - Compiler features
- **docs/ERROR_HANDLING.md** - Error handling guide
- **docs/HINTS.md** - Code hints system
- **docs/SNIPPETS.md** - Code snippets overview
- **docs/SNIPPET_CONFIGURATION.md** - Snippet configuration
- **docs/SVN_DIFF_MARKERS.md** - SVN integration
- **docs/UNIFIED_SIGN_COLUMN.md** - Sign column system
- **docs/DEBUG_STREAMING.md** - Debug output streaming
- **docs/AUTOCOMPLETE.md** - Autocomplete features
- **docs/API_INTEGRATION.md** - API reference

### Testing & Troubleshooting
- **docs/TESTING_GUIDE.md** - General testing guide
- **docs/SNIPPET_TESTING_GUIDE.md** - Snippet testing
- **docs/DEVELOPER_QUICK_REFERENCE.md** - Developer reference

### Architecture & Implementation
- **docs/SNIPPET_ARCHITECTURE.md** - Snippet system architecture
- **docs/LUA_API_REFERENCE.md** - Lua API reference
- **docs/NEOVIM_STATUSLINE_INTEGRATION.md** - Statusline integration details

### Pending & Ideas
- **docs/PENDING_FEATURES_AND_IDEAS.md** - Future features
- **docs/README.md** - Documentation index

---

## Agent/Internal Documentation (`.kiro/`)

These files are for developers and agents working on the project.

### Entry Points
- **START_HERE.md** - Main entry point for new agents (5 min read)
- **AGENT_CONTEXT.md** - Quick reference for returning agents (2 min read)
- **INDEX.md** - Complete file index
- **PROJECT_HANDOFF.md** - Project summary and handoff guide

### Project Tracking
- **FUTURE_BUGS.md** - Known bugs and issues to fix
- **FUTURE_TASKS.md** - Enhancement roadmap
- **BUGS_FIXED.md** - Completed bug fixes
- **IMPLEMENTATION_COMPLETE.md** - Implementation status
- **CONSOLIDATION_SUMMARY.md** - Consolidation work summary

### Bug Fixes
- **bug-fixes/BF-N/** - Individual bug fix directories
  - Each contains: README.md, IMPLEMENTATION_SUMMARY.md, IMPLEMENTATION_PROGRESS.md, QUICK_REFERENCE.md

### Enhancements
- **enhancements/** - Enhancement documentation
  - PHASE_N_*.md files for each planned enhancement

### Specifications
- **specs/** - Project specifications
  - display-enhancements/ - Display system specifications
  - Other feature specs as needed

### Steering & Rules
- **steering/aws-aidlc-rules/** - DLC workflow framework (reference only)

### Archive
- **archive/** - Old documentation (historical reference)
- **docs/** - Old documentation copies (historical reference)

---

## File Organization Rules

### Root Level (Minimal)
Only user-facing essentials:
- `README.md` - Project overview
- `SETUP.md` - Quick setup
- `LICENSE` - License
- `.vimrc.example` - Example Vim config
- `init.lua.example` - Example Neovim config

### `docs/` (User-Facing)
All documentation for end users:
- Feature guides
- Configuration guides
- Setup guides
- API reference
- Testing guides
- Troubleshooting

### `.kiro/` (Agent/Internal)
All documentation for developers:
- Entry points (START_HERE.md, AGENT_CONTEXT.md)
- Project tracking (FUTURE_BUGS.md, FUTURE_TASKS.md)
- Bug fixes (bug-fixes/)
- Enhancements (enhancements/)
- Specifications (specs/)
- Steering (steering/)
- Archive (archive/)

### `.kiro/archive/` (Historical)
Old documentation kept for reference:
- Previous implementation notes
- Historical decisions
- Deprecated approaches

---

## How to Find What You Need

### I'm a User Who Wants to...

**Install the plugin**
→ Read `SETUP.md` (root) or `docs/SETUP_FRESH_VIM.md`

**Configure the plugin**
→ Read `README.md` (root) Configuration section

**Use a specific feature**
→ Read `docs/[FEATURE].md` (e.g., `docs/SNIPPETS.md`)

**Troubleshoot an issue**
→ Read `docs/ERROR_HANDLING.md` or `docs/COMPATIBILITY.md`

**Understand Vim vs Neovim differences**
→ Read `docs/COMPATIBILITY.md`

---

### I'm a Developer Who Wants to...

**Understand the project**
→ Read `.kiro/START_HERE.md` (5 min)

**Get quick context**
→ Read `.kiro/AGENT_CONTEXT.md` (2 min)

**Fix a bug**
→ Read `.kiro/FUTURE_BUGS.md`, then `.kiro/bug-fixes/BF-N/README.md`

**Implement a feature**
→ Read `.kiro/FUTURE_TASKS.md`, then `.kiro/enhancements/PHASE_N_*.md`

**Understand architecture**
→ Read `.kiro/START_HERE.md` Architecture section, then `docs/SNIPPET_ARCHITECTURE.md`

**See what's been done**
→ Read `.kiro/BUGS_FIXED.md` and `.kiro/IMPLEMENTATION_COMPLETE.md`

---

## Consolidation Status

### ✓ Completed
- Removed `DLC_COMPLIANCE_BRIEF.md` from root (internal, not user-facing)
- Organized user docs in `docs/`
- Organized agent docs in `.kiro/`
- Created this guide

### Planned
- Archive old documentation in `.kiro/archive/`
- Consolidate duplicate documentation
- Remove redundant files

---

## Documentation Maintenance

### When Adding New Documentation

1. **Is it for end users?** → Put in `docs/`
2. **Is it for developers/agents?** → Put in `.kiro/`
3. **Is it historical?** → Put in `.kiro/archive/`
4. **Is it a root-level essential?** → Only if it's README.md, SETUP.md, or LICENSE

### When Updating Documentation

1. Update the file in its proper location
2. Update `.kiro/INDEX.md` if adding new files
3. Update this guide if changing organization

### When Removing Documentation

1. Check if it's referenced elsewhere
2. Move to `.kiro/archive/` if historical
3. Delete if truly redundant
4. Update `.kiro/INDEX.md`

---

## Quick Reference

| Need | Location | File |
|------|----------|------|
| Setup | Root | SETUP.md |
| Features | docs/ | [FEATURE].md |
| Configuration | README.md | Configuration section |
| Project overview | .kiro/ | START_HERE.md |
| Quick context | .kiro/ | AGENT_CONTEXT.md |
| Bug tracking | .kiro/ | FUTURE_BUGS.md |
| Enhancement roadmap | .kiro/ | FUTURE_TASKS.md |
| Bug fix details | .kiro/bug-fixes/ | BF-N/README.md |
| Enhancement details | .kiro/enhancements/ | PHASE_N_*.md |
| Architecture | docs/ | SNIPPET_ARCHITECTURE.md |
| API reference | docs/ | API_INTEGRATION.md |
| Specifications | .kiro/specs/ | [SPEC]/README.md |

---

## Summary

- **Users**: Look in `docs/` and root-level files
- **Developers**: Look in `.kiro/` for project documentation
- **Historical**: Look in `.kiro/archive/` for old documentation
- **This guide**: Explains where everything is

