# New Plugins Guide - 5 Powerful Additions

This guide covers the 5 new plugins added to your Neovim configuration.

---

## 1. 🔄 Inc-Rename (LSP Rename with Live Preview)

**Plugin**: `smjonas/inc-rename.nvim`  
**Purpose**: Rename symbols across your project with live preview

### Features:
- ✨ **Live Preview**: See all rename changes before applying
- ✨ **Multi-file Support**: Renames across entire project
- ✨ **LSP Integration**: Works with any LSP server
- ✨ **Undo Support**: Can undo like any other change

### Keybindings:
```vim
<leader>rn    - Incremental rename (cursor on symbol)
```

### Usage Example:
1. Place cursor on a variable