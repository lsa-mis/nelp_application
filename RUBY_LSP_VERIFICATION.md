# Ruby LSP Verification Checklist

Use this checklist after installing Ruby LSP gems.

## Environment

- [ ] `.ruby-version` present and matches `ruby -v`
- [ ] `bundle info ruby-lsp` succeeds
- [ ] `script/check_ruby_lsp_env` shows all installed

## VS Code Extension

- [ ] Reloaded window (Developer: Reload Window)
- [ ] Output panel -> Ruby LSP shows "Starting Ruby LSP using Bundler"
- [ ] No load errors for `ruby-lsp-rails` or `ruby-lsp-rspec`

## Core Language Features

- [ ] Hover on a model/class shows doc or signature
- [ ] Go to Definition (Cmd+Click) works for a model
- [ ] Find References on a method shows call sites
- [ ] Document Symbols (Cmd+Shift+O) lists classes & methods
- [ ] Workspace Symbols (Cmd+T) finds models/controllers

## Rails Plugin

- [ ] Navigate from helper usage in a view to helper method
- [ ] Associations resolve (Cmd+Click on `has_many` target constant)

## RSpec Plugin

- [ ] Test lenses appear above `describe` blocks (Run / Debug)
- [ ] Workspace Symbols returns spec examples when searching

## Formatting

- [ ] Format Document formats via `syntax_tree`
- [ ] Format on type (e.g. after `end`) adjusts indentation

## Diagnostics & Code Actions

- [ ] Introduce RuboCop offense (extra spaces, unused var) -> squiggle
- [ ] Lightbulb offers autocorrect
- [ ] Running "Fix all auto-fixable" applies corrections

## Refactoring

- [ ] Rename symbol (F2) updates references safely

## Inlay / Semantic (if enabled)

- [ ] Semantic highlighting differentiates symbols

## Performance / Stability

- [ ] Initial indexing completes (no perpetual spinner)
- [ ] Subsequent hovers are fast (< 300ms perceived)

## Optional

- [ ] Add more plugins later (factory_bot, brakeman) if needed

---
If any box fails, capture the Ruby LSP Output log and run:

```
env -u RUBYOPT ruby --version
bundle doctor
script/check_ruby_lsp_env
```

Then triage gem versions or environment preload issues.
