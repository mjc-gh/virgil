# frozen_string_literal: true

require_relative "test_helper"

class TUIScreensTest < Minitest::Test
  def test_prompt_screen_creation
    screen = Virgil::TUI::Screens::Prompt.new(width: 80, height: 24)

    assert_equal 80, screen.width
    assert_equal 24, screen.height
    refute_nil screen.textarea
  end

  def test_research_screen_creation
    screen = Virgil::TUI::Screens::Research.new(width: 80, height: 24)

    assert_equal 80, screen.width
    assert_equal 24, screen.height
    assert_equal [], screen.cards
  end

  def test_research_screen_add_tool_call
    screen = Virgil::TUI::Screens::Research.new

    screen.add_tool_call(tool_name: "CustomSearch", arguments: { query: "test" })

    assert_equal 1, screen.cards.length
    assert_instance_of Virgil::TUI::Components::ToolCard, screen.cards[0]
  end

  def test_research_screen_add_agent_response
    screen = Virgil::TUI::Screens::Research.new

    screen.add_agent_response(content: "Agent response", is_goal_completed: false)

    assert_equal 1, screen.cards.length
    assert_instance_of Virgil::TUI::Components::ResponseCard, screen.cards[0]
  end
end
