<a href="https://dotfyle.com/plugins/umutondersu/smart-newline.nvim">
	<img src="https://dotfyle.com/plugins/umutondersu/smart-newline.nvim/shield?style=flat" />
</a>

# smart-newline.nvim ✨

## Introduction 🚀

A Neovim plugin that provides intelligent newline insertion with proper indentation for brackets and HTML tags.

## Purpose 🎯

This plugin enhances your coding experience by automatically creating properly indented newlines when you're inside or around brackets and HTML tags, saving you from formatting and keeping your flow. ⚡

## Requirements ⚡️

- Neovim >=0.10

## Features 🌟

- **Smart bracket handling** 🔧: Formats newlines inside `{}`, `[]`, and `()`, and other custom brackets
- **HTML tag support** 🏷️: Intelligent newline insertion between opening and closing HTML tags
- **Proper indentation** 📐: Maintains consistent indentation based on your buffer settings
- **Flexible configuration** 🎛️: Enable/disable bracket or HTML tag features independently
- **Fallback behavior🔙**: Falls back to normal trigger key behavior when not applicable

## Installation 📦

### 💤 [Lazy.nvim](https://github/folke/lazy.nvim)

```lua
return {
  "umutondersu/smart-newline.nvim",
  event = "BufReadPost",
  opts = {}
}
```

If you do not want to override a key you can install without the trigger

```lua
return {
  "umutondersu/smart-newline.nvim",
  cmd = "Smartnewline",
  opts = {
    trigger = nil
  }
}
```

Or

```lua
return {
  "umutondersu/smart-newline.nvim",
  opts = {
    trigger = nil
  },
  keys = {
    {
      '<leader>o'
      function() require("smart-newline").newline() end,
      desc = "Smart Newline"
    }
  }
}
```

## Configuration ⚙️

The plugin comes with sensible defaults but can be customized:

```lua
require("smart-newline").setup({
  bracket_pairs = {
    { "{", "}" },
    { "[", "]" },
    { "(", ")" }
  },
  trigger = "o",
  html_tags = { enabled = true },
  brackets = { enabled = true }
})
```

- `bracket_pairs`: Array of bracket pairs to handle
- `trigger`: Key binding to activate smart newline functionality
- `html_tags.enabled`: Enable/disable HTML tag smart newline
- `brackets.enabled`: Enable/disable bracket smart newline

## Showcase 📖

### Bracket Newlines 🔧

**Before**

```javascript
function example() {|}
```

**After**

```javascript
function example() {
    |
}
```

### HTML Tag Newlines 🏷️

**Before**

```html
<div>|</div>
```

**After**

```html
<div>
  |
</div>
```

**Works inside tag attributes too:**

**Before**

```html
<div clas|s="example"></div>
```

**After**

```html
<div class="example">
  |
</div>
```
