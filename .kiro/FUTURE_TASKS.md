# Future Tasks & Known Issues

## Snippet Expansion Placeholder Navigation (Low Priority)

**Status**: Deferred for future work  
**Issue**: Snippet placeholder expansion (${1:name}, ${2:params}, etc.) is not fully functional with LuaSnip integration

**Current Behavior**:
- Snippets insert correctly with placeholder syntax visible
- Tab key navigation between placeholders not working as expected
- Placeholder text is displayed literally instead of being interactive

**Root Cause**:
- LuaSnip integration needs proper snippet object creation with node parsing
- Current implementation uses basic text nodes instead of insert nodes with proper placeholder handling
- May require refactoring snippet registration and expansion logic

**Potential Solutions**:
1. Parse placeholder syntax (${1:name}) and create proper LuaSnip insert_node objects
2. Implement custom snippet expansion that handles placeholders independently
3. Consider using a simpler snippet engine if LuaSnip integration proves too complex
4. Investigate LuaSnip's snippet format more thoroughly for proper integration

**Priority**: Low - Snippets work for basic insertion; placeholder navigation is a nice-to-have enhancement

**Notes**:
- User can still use snippets effectively for code templates
- Focus on other features first; revisit when snippet expansion becomes critical
- All compatibility issues with nvim-notify and noice.nvim have been resolved
