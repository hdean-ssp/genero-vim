# Subtask 1: Extended Autocomplete Sources - Analysis & Design

## Overview
Expand autocomplete to include cross-file functions, variables, and snippets instead of just current-file functions.

## Current State
- Only uses `list-file-functions` for current file
- Filters by prefix match
- Returns ~10-50 results typically

## Available query.sh Commands for Extended Sources

### Function Queries
1. **search-functions** - Pattern-based search across all files
   - Performance: <10ms
   - Returns: All matching functions project-wide
   - Use case: Cross-file function discovery

2. **find-functions-in-module** - Functions in specific module
   - Performance: <1ms
   - Returns: Functions scoped to module
   - Use case: Module-scoped completion

3. **find-function-dependencies** - Functions called by target
   - Performance: <1ms
   - Returns: Called functions
   - Use case: Context-aware suggestions

### Module Queries
1. **search-modules** - Pattern-based module search
   - Performance: <10ms
   - Returns: Matching modules
   - Use case: Module name completion

2. **find-module-for-function** - Which modules contain function
   - Performance: <1ms
   - Returns: Module names
   - Use case: Scope information

## Design Approach: Prioritized Results

### Priority Levels (in order)
1. **Current File Functions** (highest priority)
   - Use: `list-file-functions`
   - Reason: Most relevant to current context
   - Performance: <1ms

2. **Same Directory Functions**
   - Use: `search-functions` with directory filter
   - Reason: Likely related to current work
   - Performance: <10ms
   - Challenge: query.sh doesn't have directory filter - need to post-filter results

3. **Same Module Functions**
   - Use: `find-module-for-function` then `find-functions-in-module`
   - Reason: Module-scoped relevance
   - Performance: <1ms + <1ms
   - Challenge: Requires two queries

4. **Project-wide Functions**
   - Use: `search-functions` with pattern
   - Reason: Fallback for broader search
   - Performance: <10ms
   - Challenge: Can return large result sets

5. **Snippets** (lowest priority)
   - Use: LuaSnip API (Neovim only)
   - Reason: Template-based completions
   - Performance: <1ms

## Implementation Strategy

### Option A: Sequential Queries (Simple, Slower)
```
1. Query current file functions
2. If < 20 results, query same module functions
3. If < 20 results, query project-wide functions
4. Add snippets if available
5. Deduplicate and sort by priority
```
**Pros**: Simple, predictable
**Cons**: Multiple queries, slower for large codebases

### Option B: Batch Query (Complex, Faster)
```
1. Execute all queries in parallel/batch
2. Merge results with priority weighting
3. Deduplicate
4. Sort by relevance score
```
**Pros**: Faster, all data available
**Cons**: More complex, need to handle large result sets

### Option C: Hybrid (Recommended)
```
1. Query current file (always)
2. If base string is long enough (3+ chars), query project-wide in background
3. Show current file results immediately
4. Update with project-wide results when ready
5. Cache results for next query
```
**Pros**: Fast initial response, comprehensive results
**Cons**: Requires async handling

## Challenges & Solutions

### Challenge 1: Directory Filtering
**Problem**: query.sh doesn't support directory filtering
**Solution**: 
- Post-filter results by comparing file paths
- Extract directory from current file path
- Filter results to same directory

### Challenge 2: Module Identification
**Problem**: Need to know current file's module
**Solution**:
- Use `find-module-for-function` on a function in current file
- Cache module info per file
- Fall back to directory-based filtering if no functions in file

### Challenge 3: Large Result Sets
**Problem**: search-functions can return 100+ results
**Solution**:
- Implement result limiting (config option)
- Prioritize by relevance (current file > same dir > same module > project)
- Use prefix matching to narrow results
- Implement pagination if needed

### Challenge 4: Performance
**Problem**: Multiple queries can be slow
**Solution**:
- Cache results aggressively
- Use async queries for background results
- Implement timeout handling
- Consider batch queries if query.sh supports them

### Challenge 5: Deduplication
**Problem**: Same function may appear in multiple queries
**Solution**:
- Use function name as unique key
- Keep highest-priority occurrence
- Track source (current file, same dir, etc.)

## Proposed Implementation

### Phase 1: Current File + Project-wide (MVP)
1. Keep current file functions (priority 1)
2. Add project-wide search (priority 4)
3. Deduplicate and limit results
4. Cache results

### Phase 2: Module-scoped (Enhancement)
1. Detect current file's module
2. Add module functions (priority 3)
3. Integrate with phase 1

### Phase 3: Directory-scoped (Enhancement)
1. Extract directory from current file
2. Filter project-wide results by directory (priority 2)
3. Integrate with phases 1-2

### Phase 4: Snippets (Enhancement)
1. Integrate LuaSnip snippets
2. Add as lowest priority
3. Neovim only

## Configuration Options

```vim
" Extended autocomplete sources
let g:genero_tools_config.autocomplete_extended_sources = 1
let g:genero_tools_config.autocomplete_include_project_wide = 1
let g:genero_tools_config.autocomplete_include_module_scoped = 1
let g:genero_tools_config.autocomplete_include_directory_scoped = 1
let g:genero_tools_config.autocomplete_include_snippets = 1
let g:genero_tools_config.autocomplete_max_results = 100
let g:genero_tools_config.autocomplete_async_background = 1
```

## Performance Expectations

### Current Implementation
- Single query: <1ms
- Display: <10ms
- Total: ~10ms

### Extended Implementation (Phase 1)
- Current file query: <1ms
- Project-wide query: <10ms
- Merge/deduplicate: <5ms
- Display: <10ms
- Total: ~25ms (acceptable)

### Extended Implementation (All Phases)
- Multiple queries: <5ms
- Module detection: <1ms
- Directory filtering: <5ms
- Merge/deduplicate: <10ms
- Display: <10ms
- Total: ~30ms (acceptable with caching)

## Next Steps

1. Implement Phase 1 (current file + project-wide)
2. Test performance and result quality
3. Implement Phase 2 (module-scoped)
4. Implement Phase 3 (directory-scoped)
5. Implement Phase 4 (snippets)
6. Add configuration options
7. Document usage and performance characteristics
