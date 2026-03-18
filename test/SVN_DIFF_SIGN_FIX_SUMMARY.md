# SVN Diff Sign Integration Fix

## Problem
The SVN diff sign integration was incorrectly placing both `-` and `+` signs on modified lines:
- A `-` sign appeared on the line before the change
- A `+` sign appeared on the actual changed line
- This created confusing double-marker behavior

## Root Cause
The diff parser was treating modified lines as separate "added" and "deleted" events, rather than recognizing them as a single modification. When a line is modified in SVN diff format:
```
-old version
+new version
```

The parser was:
1. Recording the `-` as a deletion
2. Recording the `+` as an addition
3. Not detecting that these represent a single modification

## Solution
Updated two key components:

### 1. Diff Parser (`autoload/genero_tools/svn/parser.vim`)
Modified `parse_diff()` to detect modifications during parsing:
- Tracks the last deleted line number
- When an added line immediately follows a deleted line, it's marked as a **modification** instead
- The modified line is added to the `modified` list
- The deleted line is still added to the `deleted` list (for reference)

### 2. Sign Placement (`autoload/genero_tools/svn/signs.vim`)
Updated `place()` to handle modifications correctly:
- Places a single yellow `~` sign on modified lines
- Skips placing a `-` sign if the deleted line is part of a modification
- Skips placing a `+` sign if the added line is part of a modification

## Result
Modified lines now display:
- **Single yellow `~` sign** on the modified line
- No confusing `-` and `+` signs
- Clear visual indication of what changed

## Example
Before:
```
  2 | line 2
- 3 | line 3 old version
+ 3 | line 3 new version
  4 | line 4
```

After:
```
  2 | line 2
~ 3 | line 3 new version
  4 | line 4
```

## Testing
The fix properly handles:
- Single line modifications
- Multiple modifications in one file
- Mixed additions, modifications, and deletions
- Consecutive modifications
