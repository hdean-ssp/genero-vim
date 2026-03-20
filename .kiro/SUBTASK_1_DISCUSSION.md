# Subtask 1: Extended Autocomplete Sources - Discussion Points

## Key Findings

### Available Commands
query.sh exposes 20+ commands across 5 categories:
- **Signature Queries**: find-function, search-functions, list-file-functions, dependencies
- **Module Queries**: find-module, search-modules, list-file-modules
- **Module-Scoped**: find-functions-in-module, find-module-for-function
- **Header Queries**: find-reference, find-author, file-references, etc.
- **Database Management**: create-dbs, create-signatures-db, create-modules-db

### Performance Characteristics
- Exact lookups: <1ms
- Pattern searches: <10ms
- Database operations: <5s
- All suitable for real-time autocomplete

## Three Implementation Strategies

### Option A: Sequential Queries (Simple)
```
Current file → Same module → Project-wide → Snippets
```
- Pros: Simple, predictable, easy to debug
- Cons: Slower (multiple queries), may timeout on large codebases
- Best for: Small to medium codebases

### Option B: Batch Query (Complex)
```
Execute all queries in parallel, merge results
```
- Pros: Fastest, all data available
- Cons: Complex implementation, large result sets to handle
- Best for: Large codebases, performance-critical

### Option C: Hybrid (Recommended)
```
Current file immediately + Project-wide in background
```
- Pros: Fast initial response, comprehensive results, async
- Cons: Requires async handling, more complex
- Best for: All codebases, best UX

## Key Challenges

1. **Directory Filtering**: query.sh doesn't support it - need post-filtering
2. **Module Detection**: Need to identify current file's module first
3. **Large Result Sets**: search-functions can return 100+ results
4. **Performance**: Multiple queries can add latency
5. **Deduplication**: Same function may appear in multiple queries

## Proposed MVP (Phase 1)

**Scope**: Current file + Project-wide functions
**Approach**: Hybrid (current file immediate, project-wide async)
**Result Limit**: 100 total (configurable)
**Priority**: Current file > Project-wide

**Implementation**:
1. Keep existing current-file query
2. Add async project-wide search in background
3. Merge results with deduplication
4. Show current file results immediately
5. Update with project-wide when ready
6. Cache results for next query

**Expected Performance**: ~25ms (acceptable)

## Questions for You

1. **Scope**: Should we start with MVP (current + project-wide) or include module-scoped?
2. **Async**: Should background queries update the completion menu, or just cache for next time?
3. **Result Limit**: 100 results reasonable, or should it be configurable?
4. **Snippets**: Include in MVP or defer to Phase 4?
5. **Variables**: Should we include variable completion, or just functions?
6. **Batch Queries**: Should we explore batch query support in query.sh?

## Recommendation

Start with **Phase 1 (MVP)** using **Hybrid approach**:
- Fast initial response (current file)
- Comprehensive results (project-wide in background)
- Configurable result limit
- Defer module/directory/snippets to later phases
- Focus on functions first, variables later

This gives users immediate value while keeping implementation manageable.
