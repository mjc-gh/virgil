# frozen_string_literal: true

require_relative "test_helper"

class TUIMessagesTest < Minitest::Test
  def test_tool_call_message
    msg = Virgil::TUI::ToolCallMessage.new(
      tool_call_id: "call_abc123",
      tool_name: "FetchMarkdown",
      arguments: { url: "https://example.com" }
    )

    assert_equal "FetchMarkdown", msg.tool_name
    assert_equal "call_abc123", msg.tool_call_id
  end

  def test_progress_message
    msg = Virgil::TUI::ProgressMessage.new(runs: 3, max_runs: 5)

    assert_equal 3, msg.runs
  end

  def test_submit_prompt_message
    msg = Virgil::TUI::SubmitPromptMessage.new(prompt: "Research query")

    assert_equal "Research query", msg.prompt
  end

  def test_styles_created
    header_style = Virgil::TUI::Styles.header
    card_border_style = Virgil::TUI::Styles.card_border

    refute_nil header_style
    refute_nil card_border_style
  end
end
