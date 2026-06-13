# frozen_string_literal: true

require_relative "test_helper"

class TUIComponentsTest < Minitest::Test
  def test_event_card_toggle
    card = Virgil::TUI::Components::EventCard.new(
      id: 1,
      header: "Test Card",
      content: "Test content",
      expanded: false
    )

    refute card.expanded

    card.toggle

    assert card.expanded

    card.toggle

    refute card.expanded
  end

  def test_event_card_update_content
    card = Virgil::TUI::Components::EventCard.new(
      id: 1,
      header: "Test Card",
      content: "Initial content"
    )

    assert_equal "Initial content", card.content

    card.update_content("Updated content")

    assert_equal "Updated content", card.content
  end

  def test_tool_card_creation
    card = Virgil::TUI::Components::ToolCard.new(
      id: 1,
      tool_call_id: "call_abc123",
      tool_name: "FetchMarkdown",
      arguments: { url: "https://example.com" }
    )

    assert_equal "FetchMarkdown", card.tool_name
    assert_equal({ url: "https://example.com" }, card.arguments)
    assert_nil card.result
  end

  def test_tool_card_stores_tool_call_id
    card = Virgil::TUI::Components::ToolCard.new(
      id: 1,
      tool_call_id: "call_abc123",
      tool_name: "FetchMarkdown",
      arguments: {}
    )

    assert_equal "call_abc123", card.tool_call_id
  end

  def test_response_card_creation
    card = Virgil::TUI::Components::ResponseCard.new(
      id: 1,
      content: "Agent response",
      is_goal_completed: false
    )

    assert_equal "Agent response", card.content
    refute card.is_goal_completed
  end
end
