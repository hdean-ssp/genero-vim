# Genero-Tools Packaging Plan

## Current State

### What We Have
1. **genero-vim plugin** - Main Vim/Neovim plugin (this repository)
2. **genero-tools-api** - Documentation and API specifications (in this repo)
3. **External genero-tools** - Separate project with `query.sh` executable
   - Currently referenced via config: `genero_tools_path = "~/personal/genero-tools/query.sh"`
   - Provides shell interface for code querying and analysis

### Current Integration
- Plugin calls `query.sh` via `system()` commands
- Path is configurable but requires manual setup
- Users must have genero-tools installed separately
- No built-in fallback or bundled version

---

## Packaging Options

### Option 1: Bundle genero-tools as a Git Submodule (Recommended)
**Pros:**
- Keeps genero-tools as separate project (maintainability)
- Single clone gets everything
- Easy to update genero-tools independently
- Clear separation of concerns

**Cons:**
- Requires users to clone with `--recursive`
- Submodule management overhead

**Implementation:**
```bash
git submodule add <genero-tools-repo-url> genero-tools
```

**Directory structure:**
```
genero-vim/
├── autoload/
├── plugin/
├── genero-tools/          # Submodule
│   ├── query.sh
│   ├── generate_signatures.sh
│   └── ...
└── lua/
```

**Config update:**
```lua
-- Auto-detect bundled genero-tools
local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h')
genero_tools_path = plugin_dir .. '/genero-tools/query.sh'
```

---

### Option 2: Merge genero-tools into Plugin
**Pros:**
- Single repository to maintain
- No submodule complexity
- Simpler distribution

**Cons:**
- Larger repository
- Harder to maintain separate projects
- Mixing concerns (plugin vs CLI tool)

**Not recommended** - violates separation of concerns

---

### Option 3: Create Standalone Package
**Pros:**
- Clean separation
- Can be used independently
- Easier to distribute via package managers

**Cons:**
- Users must install two packages
- More complex setup

**Implementation:**
- Publish genero-tools to npm, pip, or system package manager
- Plugin detects and uses installed version
- Fallback to bundled version if available

---

## Recommended Approach: Git Submodule + Auto-Detection

### Implementation Steps

1. **Add submodule:**
   ```bash
   git submodule add <genero-tools-repo-url> genero-tools
   ```

2. **Update plugin initialization** (in `autoload/genero_tools/config.vim`):
   ```vim
   function! genero_tools#config#get_default_tools_path()
     " Try bundled genero-tools first
     let plugin_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h')
     let bundled_path = plugin_dir . '/genero-tools/query.sh'
     
     if filereadable(bundled_path)
       return bundled_path
     endif
     
     " Fall back to system PATH
     if executable('query.sh')
       return 'query.sh'
     endif
     
     " Fall back to BRODIR
     let brodir = $BRODIR
     if !empty(brodir)
       return brodir . '/etc/genero-tools/query.sh'
     endif
     
     return 'query.sh'  " Last resort
   endfunction
   ```

3. **Update documentation:**
   - Update SETUP.md with submodule clone instructions
   - Update README with bundled genero-tools info
   - Update init.lua.example with auto-detection

4. **Update .gitignore** (if needed):
   - Ensure genero-tools submodule is tracked

### Installation Instructions

**For users:**
```bash
# Clone with submodules
git clone --recursive https://github.com/hdean-ssp/genero-vim.git

# Or if already cloned
git submodule update --init --recursive
```

**For vim-plug users:**
```vim
Plug 'hdean-ssp/genero-vim', {'do': 'git submodule update --init --recursive'}
```

---

## Benefits

1. **Zero-config for most users** - Works out of the box
2. **Backward compatible** - Still respects user config
3. **Flexible** - Can use bundled, system, or custom version
4. **Maintainable** - genero-tools stays as separate project
5. **Distributable** - Single clone gets everything needed

---

## Migration Path

1. Add submodule to genero-vim
2. Update config auto-detection
3. Update documentation
4. Release as new version
5. Existing users can opt-in by updating and running `git submodule update --init --recursive`

---

## Related Files to Update

- `autoload/genero_tools/config.vim` - Add auto-detection logic
- `SETUP.md` - Update installation instructions
- `README.md` - Mention bundled genero-tools
- `init.lua.example` - Remove manual path configuration
- `.vimrc.example` - Remove manual path configuration
- `docs/CONFIGURATION.md` - Update configuration docs

---

## Questions to Resolve

1. Is genero-tools in a separate repository? If so, what's the URL?
2. Should we make genero-tools executable in the submodule?
3. Do we need to handle Windows compatibility for query.sh?
4. Should we provide pre-built binaries or keep as shell scripts?
