# Bubbletea Ruby TUI Development Guide

## Overview

This document captures lessons learned while implementing a Terminal User Interface (TUI) for Virgil using the [Bubbletea Ruby](https://github.com/gazu/bubbletea) framework—a Ruby port of Charm's Bubble Tea Go framework.

## Bubbletea Ruby Pattern

Bubbletea Ruby implements the **Elm-style Model-View-Update (MVU)** architecture:

```
User Input → update() → [model, command] → view() → Render
```

### Key Methods

- **`update(message)`** – Handles all events and state mutations
  - **Must return:** `[self, command]` tuple (array, not just self)
  - `self` is the updated model
  - `command` is a Bubbletea command (or `nil` for no action)
  - Called for every event: keyboard input, window resize, custom messages, etc.

- **`view()`** – Renders the current model state
  - Returns a string to display
  - Called after each `update()`

- **`include Bubbletea::Model`** – Mixin that provides model behavior

## Message Types and Handling

### Built-in Messages

- `Bubbletea::KeyMessage` – keyboard input
  - Access key name via `message.name` (e.g., "q", "enter", "j", "down")
  - NOT `message.key` (this doesn't exist)
- `Bubbletea::WindowSizeMessage` – terminal resize events
- Custom messages – user-defined classes for domain events

### Returning Commands

The `update` method must always return `[model, command]`:

```ruby
def update(message)
  case message
  when Bubbletea::KeyMessage
    if message.name == "q"
      return [self, Bubbletea.quit]
    end
  end
  [self, nil]  # No command
end
```

## Custom Messages

Define custom message classes for inter-component communication:

```ruby
class MyCustomMessage
  attr_reader :data
  
  def initialize(data:)
    @data = data
  end
end
```

Send custom messages from callbacks (e.g., agent threads):

```ruby
Bubbletea.send_message(MyCustomMessage.new(data: "value"))
```

## Threading and Background Work

### Problem

`Bubbletea.send_message()` from background threads doesn't work because it returns a command object that must be returned from the `update()` method. Background threads have no `update` context.

### Solution: Thread-Safe Queue with Polling

**Pattern:**
1. Agent thread pushes messages to a `Queue` instance
2. Main event loop polls the queue via `Bubbletea.tick(0.1)`
3. Poll handler drains all queued messages and processes them
4. Polling continues until explicitly stopped

**Implementation:**
- Use Ruby's built-in `Queue` class (thread-safe by default)
- Poll every 100ms using `Bubbletea.tick`
- Batch-process all queued messages on each poll
- Start polling when agent research begins
- Stop polling when goal is completed

**Example:**
```ruby
# In agent thread:
@message_queue.push(MyMessage.new(data: "value"))

# In App#update:
when QueuePollMessage
  until @message_queue.empty?
    msg = @message_queue.pop(true)
    process_queued_message(msg)
  end
  cmd = @polling_active ? Bubbletea.tick(0.1) { QueuePollMessage.new } : nil
  return [self, cmd]
```

This pattern ensures reliable message delivery while maintaining the MVU architecture.

## Styling with Lipgloss

### Creating Styles

```ruby
style = Lipgloss::Style.new
  .foreground("#00D7FF")
  .bold(true)
  .padding(1)

rendered = style.render("Text here")
```

### Color Formats

- Hex: `"#FF0000"`
- RGB: Not directly supported; convert to hex
- Common methods: `foreground()`, `background()`, `bold()`, `faint()`, `border_style()`, etc.

### Common Pitfalls

- ❌ `dim()` – doesn't exist
- ✅ `faint()` – correct method for dimming text
- ❌ Lipgloss::PLACE_CENTER – doesn't exist
- ✅ `Lipgloss::Position::CENTER` – correct constant

## Layout and Positioning

### Centering Content

```ruby
Lipgloss.place(
  width,
  height,
  Lipgloss::Position::CENTER,
  Lipgloss::Position::CENTER,
  "Content to center"
)
```

### Breaking Long Lines

Use Ruby string concatenation across lines:

```ruby
attr_reader :field1, :field2, :field3, :field4, :field5, :field6,
            :field7
```

## Component Architecture

### Screen Classes

Screens are mini-MVU models implementing `Bubbletea::Model`:

```ruby
class MyScreen
  include Bubbletea::Model
  
  def initialize(width: 80, height: 24)
    @width = width
    @height = height
  end
  
  def update(message)
    # Handle events, mutate state
    [self, nil]  # Always return [model, command]
  end
  
  def view
    # Return string to render
  end
end
```

### App-Level Orchestration

The main app manages screen transitions and delegates messages:

```ruby
class App
  include Bubbletea::Model
  
  def update(message)
    case message
    when ScreenTransitionMessage
      @current_screen = :new_screen
    else
      model, cmd = delegate_to_screen(message)
      return [model, cmd] if cmd
    end
    [self, nil]
  end
end
```

## Testing TUI Components

### Unit Testing Models

```ruby
def test_screen_update
  screen = MyScreen.new
  model, cmd = screen.update(MyMessage.new(data: "test"))
  
  assert_equal screen, model  # Model should return self
  assert_nil cmd
end
```

### Integration Testing

- Test message handling flows
- Test state mutations
- Avoid testing rendered output (it's fragile)

## Queue Usage in Ruby

### Thread-Safe Queue

```ruby
queue = Queue.new
queue.push(item)

# Non-blocking pop (raises ThreadError if empty)
begin
  item = queue.pop(true)
rescue ThreadError
  # Queue is empty
end

# Blocking pop (waits for item)
item = queue.pop()
```

## Tick Commands

Keep the event loop alive with periodic updates:

```ruby
Bubbletea.tick(0.1) { ProgressMessage.new(runs: 1, max_runs: 5) }
```

The block yields a message that will be processed on the next tick. Duration is in seconds.

## Key Learnings

1. **Always return `[self, command]` from `update`** – The framework requires this tuple; returning just `self` breaks rendering

2. **Use `message.name` for keyboard input** – Not `.key` or other variants

3. **Thread-safety is complex** – Background threads sending messages require careful synchronization; avoid if possible

4. **Lipgloss has limited styling** – Methods like `dim()` don't exist; use `faint()` instead

5. **Component composition** – Build screens as separate MVU models, then orchestrate them in the main app

6. **Style over substance for now** – Get core functionality working first, polish UI later

## References

- [Bubbletea Ruby GitHub](https://github.com/gazu/bubbletea)
- [Charm Ecosystem](https://charm.sh/)
- [Lipgloss Documentation](https://github.com/charmbracelet/lipgloss)
