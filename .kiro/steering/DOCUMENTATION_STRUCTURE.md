---
inclusion: manual
---

# Documentation Structure Guide

This document describes the organization and purpose of all documentation in the genero-tools project.

## Overview

Documentation is organized into three categories:

1. **User Guides** (`/docs`) - For end users
2. **Development Guides** (`/.kiro/steering`) - For developers
3. **Roadmap** (root level) - For planning and future work

## User Guides (`/docs`)

### docs/README.md
**Purpose:** Documentation index and quick reference

Contains:
- Overview of all documentation
- Quick links to guides
- Command reference
- Troubleshooting quick links
- Development resources

**Audience:** Everyone - start here

### docs/QUICK_START.md
**Purpose:** Get started in 5 minutes

Contains:
- Installation instructions
- Basic configuration
- First compilation
- Common commands

**Audience:** New users

### docs/SETUP_FRESH_VIM.md
**Purpose:** Fresh Vim/Neovim installation guide

Contains:
- Step-by-step setup
- Plugin manager integration
- Configuration examples
- Verification steps

**Audience:** Users setting up fresh Vim/Neovim

### docs/COMPILER_INTEGRATION.md
**Purpose:** Complete compiler integration guide

Contains:
- Feature overview
- Configuration options
- Compiler output format
- Workflow examples
- Troubleshooting
- Advanced usage
- Performance tips

**Audience:** Users using compiler features

### docs/API_INTEGRATION.md
**Purpose:** Code navigation and API usage

Contains:
- Available commands
- Function lookup
- Module navigation
- Metadata access
- Examples

**Audience:** Users using code navigation features

### docs/NEOVIM.md
**Purpose:** Neovim-specific features

Contains:
- Neovim-only features
- Lua layer capabilities
- LSP integration
- Async operations
- Configuration

**Audience:** Neovim users

### docs/COMPATIBILITY.md
**Purpose:** Vim/Neovim compatibility information

Contains:
- Version requirements
- Feature compatibility matrix
- Known issues
- Workarounds

**Audience:** Users checking compatibility

## Development Guides (/.kiro/steering)

### COMPILER_DEVELOPMENT.md
**Purpose:** Compiler module architecture and development

Contains:
- Module structure
- Data flow diagrams
- Key components
- Parser implementation
- Autocompile workflow
- Configuration system
- Testing procedures
- Adding new features
- Performance optimization
- Debugging tips
- Common issues
- Future enhancements

**Audience:** Developers working on compiler integration

### vimscript-conventions.md
**Purpose:** Code style and conventions

Contains:
- Naming conventions
- Function organization
- Error handling
- Documentation standards
- Code formatting

**Audience:** Developers contributing code

### error-handling-patterns.md
**Purpose:** Error handling patterns and best practices

Contains:
- Error handling strategies
- Exception handling
- User feedback
- Logging patterns
- Recovery strategies

**Audience:** Developers implementing features

### lua-layer-architecture.md
**Purpose:** Lua layer design and implementation

Contains:
- Architecture overview
- Module structure
- Async patterns
- UI integration
- Performance considerations

**Audience:** Developers working on Lua layer

### genero-tools-cli.md
**Purpose:** CLI integration and usage

Contains:
- Available commands
- Command structure
- Output formats
- Integration patterns
- Examples

**Audience:** Developers integrating with CLI

## Roadmap (Root Level)

### QUICK_ENHANCEMENTS_ROADMAP.md
**Purpose:** Planned enhancements and features

Contains:
- Phase-based roadmap
- Implementation estimates
- Testing strategy
- Documentation updates
- Priority matrix

**Audience:** Project planners, contributors

### GENERO_TOOLS_ENHANCEMENT_SUGGESTIONS.md
**Purpose:** Enhancement ideas and suggestions

Contains:
- Unused capabilities
- Enhancement suggestions
- Use cases
- Implementation priority
- Integration opportunities

**Audience:** Project planners, stakeholders

## Documentation Principles

### Single Source of Truth
- Each topic covered in one place
- No duplicate information
- Cross-references between guides

### Clear Organization
- User guides in `/docs`
- Development guides in `/.kiro/steering`
- Roadmap at root level

### Audience-Focused
- User guides for end users
- Development guides for developers
- Roadmap for planners

### Up-to-Date
- Remove outdated information
- Consolidate related topics
- Keep examples current

### Helpful and Accurate
- Clear explanations
- Practical examples
- Troubleshooting sections
- Links to related topics

## Navigation Guide

### For Users

**Getting Started:**
1. Read `docs/README.md` for overview
2. Follow `docs/QUICK_START.md` for setup
3. Check `docs/SETUP_FRESH_VIM.md` if needed

**Using Features:**
- Compiler: `docs/COMPILER_INTEGRATION.md`
- Navigation: `docs/API_INTEGRATION.md`
- Neovim: `docs/NEOVIM.md`

**Troubleshooting:**
- Check feature guide troubleshooting section
- See `docs/COMPATIBILITY.md` for compatibility issues
- Check `docs/README.md` for quick help

### For Developers

**Getting Started:**
1. Read `.kiro/steering/COMPILER_DEVELOPMENT.md` for architecture
2. Review `.kiro/steering/vimscript-conventions.md` for code style
3. Check `.kiro/steering/error-handling-patterns.md` for patterns

**Working on Features:**
- Compiler: `.kiro/steering/COMPILER_DEVELOPMENT.md`
- Lua layer: `.kiro/steering/lua-layer-architecture.md`
- CLI: `.kiro/steering/genero-tools-cli.md`

**Contributing:**
1. Follow code style in `vimscript-conventions.md`
2. Use patterns from `error-handling-patterns.md`
3. Update relevant user guides in `/docs`

### For Planners

**Planning Work:**
1. Review `QUICK_ENHANCEMENTS_ROADMAP.md` for phases
2. Check `GENERO_TOOLS_ENHANCEMENT_SUGGESTIONS.md` for ideas
3. Prioritize based on effort/value matrix

## Maintenance

### Adding New Documentation

1. **Determine audience:** User or developer?
2. **Choose location:** `/docs` or `/.kiro/steering`
3. **Check for duplicates:** Consolidate if related content exists
4. **Add to index:** Update `docs/README.md` or `.kiro/steering/DOCUMENTATION_STRUCTURE.md`
5. **Cross-reference:** Link from related documents

### Updating Documentation

1. **Keep current:** Update when features change
2. **Remove outdated:** Delete obsolete information
3. **Consolidate:** Merge related topics
4. **Verify accuracy:** Test examples and commands
5. **Update index:** Reflect changes in README files

### Removing Documentation

1. **Check for references:** Ensure no broken links
2. **Consolidate content:** Move to appropriate location
3. **Update index:** Remove from README files
4. **Verify:** Ensure no orphaned content

## Documentation Checklist

When creating or updating documentation:

- [ ] Clear, concise title
- [ ] Audience clearly identified
- [ ] Purpose stated upfront
- [ ] Examples provided
- [ ] Troubleshooting section (if applicable)
- [ ] Links to related topics
- [ ] Accurate and current information
- [ ] Proper formatting and structure
- [ ] Added to appropriate index
- [ ] No duplicate information

## Quick Links

**User Guides:**
- [docs/README.md](../docs/README.md) - Documentation index
- [docs/QUICK_START.md](../docs/QUICK_START.md) - Getting started
- [docs/COMPILER_INTEGRATION.md](../docs/COMPILER_INTEGRATION.md) - Compiler features

**Development Guides:**
- [COMPILER_DEVELOPMENT.md](COMPILER_DEVELOPMENT.md) - Compiler architecture
- [vimscript-conventions.md](vimscript-conventions.md) - Code style
- [error-handling-patterns.md](error-handling-patterns.md) - Error handling

**Roadmap:**
- [QUICK_ENHANCEMENTS_ROADMAP.md](../QUICK_ENHANCEMENTS_ROADMAP.md) - Future work
- [GENERO_TOOLS_ENHANCEMENT_SUGGESTIONS.md](../GENERO_TOOLS_ENHANCEMENT_SUGGESTIONS.md) - Ideas
