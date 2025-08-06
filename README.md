# smart-newline.nvim ✨

## Introduction 🚀

A Neovim plugin that provides intelligent newline insertion with proper indentation for brackets and HTML tags.

## Purpose 🎯

This plugin enhances your coding experience by automatically creating properly indented newlines when you're inside brackets or HTML tags, saving you from manual formatting. ⚡

## Table of Contents 📖

- [Introduction](#introduction-)
- [Purpose](#purpose-)
- [Requirements](#requirements-)
- [Features](#features-)
- [Installation](#installation-)
- [Configuration](#configuration-)
- [Usage](#usage-)

## Requirements ⚡️

- Neovim >=0.10

## Features 🌟

- **Smart bracket handling** 🔧: Automatically formats newlines inside `{}`, `[]`, and `()` brackets
- **HTML tag support** 🏷️: Intelligent newline insertion between opening and closing HTML tags
- **Proper indentation** 📐: Maintains consistent indentation based on your buffer settings
- **Configurable trigger** ⚙️: Customize the key binding to activate smart newline
- **Flexible configuration** 🎛️: Enable/disable bracket or HTML tag features independently

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
      function() require("Smart-newline").newline() end,
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

## Usage 🚀

1. Position your cursor inside empty brackets `{}`, `[]`, or `()`
2. Press the trigger key (default: `o` in normal mode)
3. The plugin will create a properly indented newline structure

For HTML tags:

1. Position your cursor between opening and closing tags: `<div>|</div>`
2. Press the trigger key
3. Get properly formatted HTML structure with indentation

The plugin automatically detects your indentation settings (tabs vs spaces, indent size) and applies them consistently.
