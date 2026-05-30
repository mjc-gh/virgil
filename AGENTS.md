# AGENTS.md – Virgil RubyLLM Agent Research Gem

## Project Overview
Virgil is a Ruby gem that wraps [RubyLLM](https://rubyllm.com/agents/) agents to perform research by crawling the web. The gem is built as a command-line tool using Thor and integrates with LLM providers (Anthropic, OpenRouter) via RubyLLM.

**Required Ruby version:** 3.2.0+

## Build, Test, and Verification

### Core commands (Rake)
- `bundle exec rake` – default task; runs `test` then `rubocop` (both required to pass)
- `bundle exec rake test` – run Minitest suite
- `bundle exec rake rubocop` – lint with RuboCop (includes minitest and rake plugins)

### Static analysis settings
- **Linter:** RuboCop with plugins: `rubocop-minitest`, `rubocop-rake`
- **Config:** `.rubocop.yml` enforces double-quoted strings, enables NewCops
- **Style note:** Documentation comments are disabled (`Style/Documentation: false`)

## Gem Build and Installation

- **Gemspec:** `virgil.gemspec` – uses `git ls-files -z` to populate file list
- **Binaries:** executable is `exe/virgil` (registered via `spec.bindir = "exe"`)
- **Entry point:** `lib/virgil/cli.rb` defines the Thor CLI commands
- **Main module:** `lib/virgil.rb` loads submodules and config logic

## Configuration and Setup

**Config file location:** `~/.config/virgil/config.yml` (respects `XDG_CONFIG_HOME` if set)

**Required config keys:**
- `provider` – one of `openrouter` or `anthropic`
- `api_key` – LLM provider API key
- `model` – (optional in config.yml) default model name; can be overridden via CLI `--model` flag
- `debug` – (optional) if `true`, sets RubyLLM log level to debug (creates log files in `log/`)

**Setup command:** `virgil setup` – interactive prompt to create/update config.yml

**Note:** `Virgil.configure!` is called by `explore` command; it validates all required keys exist.

## Architecture

### Module structure
- `Virgil::Agent` – extends `RubyLLM::Agent`; includes tools and initial instructions
- `Virgil::CLI` – Thor CLI; entry point for `setup` and `explore` commands
- `Virgil::Tools` – custom tools for web research: `CustomSearch`, `FetchLinks`, `FetchMarkdown`
- `Virgil::Virgo` – wrapper around virgo (external web crawler dependency)
- `Virgil::Prompt` – loads prompt templates from `prompts.txt`

### Agent flow
1. User runs `virgil explore "PROMPT"`
2. `CLI#explore` calls `Virgil.configure!(model:)`
3. Creates `Agent.new` and calls `agent.explore(prompt)`
4. Agent uses RubyLLM to orchestrate tool calls (search, fetch links, fetch markdown)
5. After each agent message, `after_message` callback prints tool summaries and final answers

### Tool integration
- Tools are defined as classes in `lib/virgil/tools/*.rb`
- Each tool integrates with Virgo (web crawler)
- `FetchMarkdown` and `FetchLinks` rely on chromedp (handled by virgo)

## Dependencies

### Gem dependencies (production)
- `ruby_llm ~> 1.5` – LLM agent framework
- `thor ~> 1.5` – CLI command framework

### Dev dependencies
- Minitest 5.16+, RuboCop 1.21+, Guard with minitest/rubocop plugins
- IRB, Rake

### External dependency
- **Virgo gem** – must be installed separately; handles web crawling via chromedp

## CI/CD
- **CI runs on:** Ruby 4.0.2 (see `.github/workflows/main.yml`)
- **CI executes:** `bundle exec rake` (test + rubocop)

## Testing
- **Test suite:** `test/test_*.rb` files
- **Test helper:** `test/test_helper.rb` – adds custom `test()` DSL sugar and loads the gem
