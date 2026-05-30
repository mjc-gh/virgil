# Virgil

This an experimental gem for building an [RubyLLM
agent](https://rubyllm.com/agents/) for completing research projects.

It depends on [virgo](https://github.com/mjc-gh/virgo) and uses chromedp
for crawling the web.

## Install

- Make sure you have [virgo installed](https://github.com/mjc-gh/virgo#install)
- Run `gem build` and then run `gem install virgil-0.1.0.gem`
- Run `virgil --help`

## Usage

```
❯ virgil --help
Commands:
  virgil explore PROMPT  # Explore the web with Virgil using PROMPT
  virgil help [COMMAND]  # Describe available commands or one specific command
  virgil setup           # Configure a provider and API key
  virgil tree            # Print a tree of all available commands
```
