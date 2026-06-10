# Ecosystem: How genero-vim Connects

```
                        ┌──────────────────────────────────┐
                        │   electRa/Castle Codebase        │
                        │       ~/work/genero              │
                        └───────────────┬──────────────────┘
                                        │ scanned by
                                        ▼
                        ┌──────────────────────────────────┐
                        │         genero-tools             │
                        │  workspace.db · modules.db       │
                        │  query.sh interface              │
                        └──────┬───────────────────┬───────┘
                               │                   │
          $GENERO_TOOLS_PATH   │                   │  databases read by
                               ▼                   ▼
┌─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐   ┌───────────────────────────────┐
│                                     │   │       electra-vault           │
│  ┌═══════════════════════════════┐  │   │  Obsidian vault generator     │
│  ║  genero-vim                   ║  │   └──────┬──────────┬────────────┘
│  ║  ★ THIS REPO ★               ║  │          │          │
│  ║                               ║  │          ▼          ▼
│  ║  Calls query.sh for:         ║  │   ┌──────────┐ ┌──────────────────┐
│  ║  • Go to definition (gd)     ║  │   │   AKR    │ │ electra-docs     │
│  ║  • Find references (gr)      ║  │   │          │ │                  │
│  ║  • Autocomplete (Ctrl+N)     ║  │   └──────────┘ └──────────────────┘
│  ║  • Peek definition (gp)      ║  │
│  ║  • Telescope pickers         ║  │
│  ║  • Function signatures       ║  │
│  ║  • Module file resolution    ║  │
│  ║  • Statusline breadcrumb     ║  │
│  ║                               ║  │
│  ║  Also provides:              ║  │
│  ║  • Compiler integration (F5) ║  │
│  ║  • SVN diff markers          ║  │
│  ║  • Code hints/linting        ║  │
│  ║  • Snippets (Neovim)         ║  │
│  ╚═══════════════════════════════╝  │
│                                     │
└─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
```

## Role in the Ecosystem

genero-vim is the **developer interface** — it provides real-time IDE features in Vim/Neovim by querying genero-tools databases, making the structural intelligence accessible during active development.

## Connections

| Repo | Relationship |
|------|-------------|
| **genero-tools** | Direct runtime dependency — all code intelligence features call `query.sh` via `$GENERO_TOOLS_PATH`. Without genero-tools databases, navigation and autocomplete won't work |
| **agent-knowledge-repository** | No direct dependency, but developers using genero-vim alongside AI agents with AKR steering get combined structural + experiential intelligence |
| **electra-documentation** | No direct dependency (operates at different level — real-time IDE vs static docs) |
| **electra-vault** | No direct dependency (both consume genero-tools independently — vim for real-time queries, vault for batch page generation) |

## Query Flow

```
Developer action in Vim/Neovim
        │
        ▼
genero-vim plugin (VimScript/Lua)
        │
        │  system("bash $GENERO_TOOLS_PATH <command> <args>")
        ▼
genero-tools/query.sh
        │
        │  sqlite3 workspace.db / modules.db
        ▼
JSON result → parsed → displayed in Vim
```

## Three-Tier Knowledge Model

```
Tier 1 (Structure)     genero-tools     → functions, calls, schema, metrics
Tier 2 (Experience)    AKR              → patterns, decisions, bug fixes, gotchas
Tier 3 (Business)      electra-docs     → architecture, data flows, integrations
                              │
                              ▼
                       electra-vault     → unified interlinked graph

Developer access:      genero-vim       → real-time IDE queries to Tier 1  ★ THIS REPO
```
