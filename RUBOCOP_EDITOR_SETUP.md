# RuboCop Editor Setup Guide

This guide will help you set up RuboCop to run automatically in Cursor/VS Code.

## 🚀 Quick Setup

### 1. Install Required Extensions

Open the Command Palette (`Cmd+Shift+P` on Mac, `Ctrl+Shift+P` on Windows/Linux) and run:

```
Extensions: Show Recommended Extensions
```

Install these essential extensions:

- **Ruby** (rebornix.ruby) - Ruby language support
- **Ruby LSP** (shopify.ruby-lsp) - Modern Ruby language server
- **Ruby RuboCop** (misogi.ruby-rubocop) - RuboCop integration

### 2. Reload Cursor/VS Code

After installing extensions, reload the editor:

- Command Palette → `Developer: Reload Window`

### 3. Verify Setup

1. Open any Ruby file (e.g., `app/models/user.rb`)
2. Make a small change (add a space, etc.)
3. Save the file (`Cmd+S` / `Ctrl+S`)
4. You should see RuboCop automatically run and fix issues

## ⚙️ Configuration Details

### Workspace Settings (`.vscode/settings.json`)

The workspace is configured with:

- **Auto-format on save** - RuboCop runs when you save files
- **Auto-correct on save** - Automatically fixes safe issues
- **Bundler integration** - Uses `bundle exec rubocop`
- **Custom config** - Uses your `.rubocop.yml` file

### Key Features

- ✅ **Format on Save** - Automatically formats code when saving
- ✅ **Lint on Save** - Shows errors and warnings in real-time
- ✅ **Auto-correct** - Fixes safe issues automatically
- ✅ **Problem Matcher** - Shows issues in the Problems panel
- ✅ **Bundler Support** - Uses your project's RuboCop version

## 🎯 How to Use

### Automatic (Recommended)

- Just save your files (`Cmd+S` / `Ctrl+S`)
- RuboCop will automatically run and fix issues
- Check the Problems panel for any remaining issues

### Manual Commands

#### Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`)

- `RuboCop: Check All Files`
- `RuboCop: Auto-correct`
- `RuboCop: Check Current File`

#### Tasks (`Cmd+Shift+P` → `Tasks: Run Task`)

- **RuboCop: Check All Files** - Run RuboCop on entire project
- **RuboCop: Auto-correct** - Auto-fix all correctable issues
- **RuboCop: Check Current File** - Check only the current file
- **Rails: Run Tests** - Run RSpec tests
- **Rails: Run Server** - Start Rails server

#### Terminal

```bash
# Check all files
bundle exec rubocop

# Auto-correct issues
bundle exec rubocop --auto-correct

# Check specific file
bundle exec rubocop app/models/user.rb

# Use helper script
bin/rubocop
```

## 🔧 Troubleshooting

### RuboCop Not Running

1. Check that extensions are installed and enabled
2. Reload the editor (`Developer: Reload Window`)
3. Check the Output panel for Ruby LSP logs
4. Verify `bundle exec rubocop` works in terminal

### Auto-correct Not Working

1. Check `.vscode/settings.json` has `"ruby.rubocop.autoCorrectOnSave": true`
2. Ensure RuboCop extension is enabled
3. Check that issues are marked as `[Correctable]` in RuboCop output

### Performance Issues

1. Exclude large directories in `.vscode/settings.json`
2. Use `files.exclude` to hide unnecessary files
3. Consider running RuboCop only on changed files

### Extension Conflicts

- Disable other Ruby formatters (Prettier, etc.)
- Ensure only one Ruby language server is active
- Check extension settings for conflicts

## 📁 File Structure

```
.vscode/
├── settings.json      # Workspace settings
├── extensions.json    # Recommended extensions
├── tasks.json         # Custom tasks
└── launch.json        # Debug configurations
```

## 🎉 You're All Set

Your editor is now configured to:

- ✅ Run RuboCop automatically on save
- ✅ Auto-correct safe issues
- ✅ Show problems in real-time
- ✅ Use your project's RuboCop configuration
- ✅ Integrate with Bundler

Happy coding! 🚀
