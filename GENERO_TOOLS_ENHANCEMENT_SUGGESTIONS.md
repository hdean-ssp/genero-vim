# Genero-Tools Enhancement Suggestions

Based on analysis of vim-genero-tools plugin and available genero-tools capabilities, here are strategic enhancement suggestions for the genero-tools project.

## Current Usage

The vim-genero-tools plugin currently uses:
- `find-function` - Find function by exact name
- `search-functions` - Search functions by pattern
- `list-file-functions` - List functions in a file
- `find-functions-in-module` - List functions in a module
- `file-references` - Get file metadata (references, authors)

## Unused Capabilities (High Value)

### 1. **Dependency Analysis** (Critical for Large Codebases)

**Current Gap:** No way to understand function call chains or impact analysis.

**Available Commands:**
- `find-function-dependencies` - Functions called BY a function
- `find-function-dependents` - Functions that CALL a function
- `find-module-dependencies` - Modules that a module depends on

**Enhancement Suggestion:**
Implement dependency visualization in the plugin:
- Show call graph for a function (what it calls, what calls it)
- Highlight circular dependencies
- Warn about deep call chains (performance risk)
- Refactoring impact analysis (show all affected functions)

**Use Case:** When refactoring a function, developers need to know:
- What will break if I change this?
- What functions depend on this behavior?
- Are there circular dependencies?

**Implementation Priority:** HIGH - Essential for safe refactoring

---

### 2. **Dead Code Detection** (Code Quality)

**Current Gap:** No way to identify unused functions.

**Available Command:**
- `find-dead-code` - Find functions that are never called

**Enhancement Suggestion:**
- Add command `:GeneroFindDeadCode` to list unused functions
- Highlight dead code in current file
- Option to exclude test functions or deprecated functions
- Generate report of dead code by module

**Use Case:** Large codebases accumulate dead code. Developers need to:
- Identify and remove unused functions
- Understand code coverage
- Clean up before major refactoring

**Implementation Priority:** MEDIUM - Useful for maintenance

---

### 3. **Author & Change Tracking** (Team Collaboration)

**Current Gap:** Limited metadata. Only shows file-level references/authors.

**Available Commands:**
- `find-author` - Find files modified by an author
- `author-expertise` - Show what areas an author has expertise in
- `file-authors` - Get all authors who modified a file
- `recent-changes` - Find files modified in last N days
- `search-references` - Search references by pattern

**Enhancement Suggestion:**
- Show author expertise when looking up functions
- Suggest code reviewers based on expertise
- Track recent changes in current file
- Show who last modified a function
- Blame-like feature (who changed what and when)

**Use Case:** Team collaboration:
- "Who should review this change?"
- "Who knows this code best?"
- "What changed recently in this file?"

**Implementation Priority:** MEDIUM - Improves team workflow

---

### 4. **Reference/Ticket Tracking** (Project Management)

**Current Gap:** References are shown but not searchable or actionable.

**Available Commands:**
- `find-reference` - Find files modified for a code reference
- `search-references` - Search references by pattern

**Enhancement Suggestion:**
- Add command `:GeneroFindReference <ref>` to find all files for a ticket
- Show reference context (what was changed for this ticket)
- Link references to functions (which functions were changed for this ticket)
- Generate change summary by reference/ticket

**Use Case:** Project tracking:
- "What code changed for ticket PRB-299?"
- "Which functions were modified for this release?"
- "What's the scope of this change?"

**Implementation Priority:** MEDIUM - Useful for project tracking

---

### 5. **Module-Level Analysis** (Architecture Understanding)

**Current Gap:** Limited module exploration.

**Available Commands:**
- `find-module` - Find module by exact name
- `search-modules` - Search modules by pattern
- `list-file-modules` - Find modules using a file
- `find-module-for-function` - Find which module(s) contain a function
- `find-functions-calling-in-module` - Find functions in module that call a function
- `find-module-dependencies` - Find modules that a module depends on

**Enhancement Suggestion:**
- Add command `:GeneroModuleGraph` to show module dependency graph
- Visualize module structure and relationships
- Show module statistics (function count, complexity)
- Identify tightly coupled modules
- Suggest module refactoring opportunities

**Use Case:** Architecture understanding:
- "What modules does this module depend on?"
- "Which modules are tightly coupled?"
- "What's the module structure?"

**Implementation Priority:** MEDIUM - Useful for architecture review

---

## Implementation Roadmap

### Phase 1: Quick Wins (Low Effort, High Value)
1. **Dead Code Detection** - `:GeneroFindDeadCode`
2. **Reference Lookup** - `:GeneroFindReference <ref>`
3. **Author Info** - Show author when looking up functions

### Phase 2: Dependency Analysis (Medium Effort, High Value)
1. **Function Dependencies** - `:GeneroDependencies <func>`
2. **Dependents** - `:GeneroDependents <func>`
3. **Call Graph** - Visual representation of dependencies

### Phase 3: Advanced Features (Higher Effort)
1. **Module Graph** - `:GeneroModuleGraph`
2. **Change Summary** - `:GeneroChangeSummary <ref>`
3. **Expertise Tracking** - Show author expertise

---

## Specific Feature Requests for Genero-Tools

### 1. **Enhanced Dependency Queries**

**Request:** Add optional parameters to dependency queries:
```bash
query.sh find-function-dependencies <name> --depth=2 --exclude-test
query.sh find-function-dependents <name> --recursive
```

**Benefit:** Better control over dependency analysis scope

---

### 2. **Circular Dependency Detection**

**Request:** Add command to detect circular dependencies:
```bash
query.sh find-circular-dependencies
query.sh find-circular-dependencies --module
```

**Benefit:** Identify architectural issues automatically

---

### 3. **Complexity Metrics**

**Request:** Add complexity analysis:
```bash
query.sh function-complexity <name>
query.sh module-complexity <name>
```

**Benefit:** Identify functions/modules that need refactoring

---

### 4. **Change Impact Analysis**

**Request:** Analyze impact of changes:
```bash
query.sh analyze-impact <function> --show-affected
query.sh analyze-impact <module> --show-affected
```

**Benefit:** Understand scope of changes before refactoring

---

### 5. **Batch Queries**

**Request:** Support batch queries for performance:
```bash
query.sh batch-query --file=queries.json
```

**Benefit:** Reduce overhead for multiple queries

---

## Integration Opportunities

### 1. **LSP Server Integration**
- Implement genero-tools as LSP server
- Provides hover, goto definition, find references
- Works with any editor supporting LSP

### 2. **CI/CD Integration**
- Generate code quality reports
- Detect dead code in CI pipeline
- Track complexity metrics over time

### 3. **IDE Integration**
- VS Code extension using genero-tools
- JetBrains plugin for Genero
- Vim/Neovim plugin (already exists)

---

## Priority Matrix

| Feature | Effort | Value | Priority |
|---------|--------|-------|----------|
| Dead Code Detection | Low | High | HIGH |
| Reference Lookup | Low | Medium | HIGH |
| Function Dependencies | Medium | High | HIGH |
| Module Graph | Medium | Medium | MEDIUM |
| Author Expertise | Low | Medium | MEDIUM |
| Circular Dependencies | Medium | High | MEDIUM |
| Complexity Metrics | Medium | Medium | MEDIUM |
| Change Impact Analysis | High | High | MEDIUM |

---

## Recommended Next Steps

### For Genero-Tools Project:
1. **Implement circular dependency detection** - Critical for large codebases
2. **Add complexity metrics** - Helps identify refactoring candidates
3. **Enhance dependency queries** - Add filtering and depth control
4. **Create LSP server** - Opens up integration with any editor

### For Vim-Genero-Tools Plugin:
1. **Add `:GeneroDependencies` command** - Show function call chain
2. **Add `:GeneroFindDeadCode` command** - List unused functions
3. **Add `:GeneroFindReference` command** - Find files for a ticket
4. **Enhance metadata display** - Show author and recent changes
5. **Add module graph visualization** - Show module relationships

---

## Conclusion

The genero-tools project has excellent foundation with comprehensive query capabilities. The main opportunities are:

1. **Dependency Analysis** - Critical for understanding large codebases
2. **Dead Code Detection** - Essential for code quality
3. **Change Tracking** - Important for team collaboration
4. **Architecture Visualization** - Helps with system understanding

These enhancements would make genero-tools an even more powerful tool for Genero development, especially for large-scale projects.
