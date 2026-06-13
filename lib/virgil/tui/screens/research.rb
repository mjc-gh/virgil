# frozen_string_literal: true

module Virgil
  module TUI
    module Screens
      # Research screen with scrollable viewport and collapsible cards
      # rubocop:disable Metrics
      class Research
        include Bubbletea::Model

        CHROME_LINES = 3 # progress bar + blank line + help text

        attr_reader :cards, :viewport, :width, :height, :progress_runs, :progress_max, :selected_index

        def initialize(width: 80, height: 24, prompt: nil)
          @width = width
          @height = height
          @cards = []
          @selected_index = -1
          @progress_runs = 0
          @progress_max = 0
          @card_id_counter = 0
          @viewport = Bubbles::Viewport.new
          @viewport.width = width
          @viewport.height = [height - CHROME_LINES, 1].max
          @tool_call_id_map = {}

          add_prompt_card(prompt) if prompt
        end

        def add_tool_call(tool_call_id:, tool_name:, arguments:)
          card_id = @card_id_counter
          @card_id_counter += 1
          card = Components::ToolCard.new(
            id: card_id,
            tool_call_id:,
            tool_name:,
            arguments:
          )
          @cards << card
          @tool_call_id_map[tool_call_id] = card
          self
        end

        def update_tool_result(tool_call_id:, content:)
          card = @tool_call_id_map[tool_call_id]
          card&.update_result(content)
          self
        end

        def add_agent_response(content:, is_goal_completed: false)
          card_id = @card_id_counter
          @card_id_counter += 1
          card = Components::ResponseCard.new(
            id: card_id,
            content: is_goal_completed ? content.gsub("__GOAL_COMPLETED__", "").strip : content,
            is_goal_completed:
          )
          @cards << card
          self
        end

        def set_progress(runs:, max_runs:)
          @progress_runs = runs
          @progress_max = max_runs
          self
        end

        def update(message)
          case message
          when Bubbletea::KeyMessage
            case message.name
            when "q"
              return [self, Bubbletea.quit]
            when "j", "down"
              @selected_index = [@selected_index + 1, @cards.length - 1].min
              scroll_to_selected
            when "k", "up"
              @selected_index = [@selected_index - 1, -1].max
              scroll_to_selected
            when "enter"
              @cards[@selected_index].toggle if @selected_index.between?(0, @cards.length - 1)
            end
          when ResizeMessage
            @width = message.width
            @height = message.height
            @viewport.width = @width
            @viewport.height = [@height - CHROME_LINES, 1].max
            scroll_to_selected
          end
          [self, nil]
        end

        def view
          progress_text = @progress_max.positive? ? "Step #{@progress_runs} of #{@progress_max}" : "Researching..."
          progress_view = Styles.progress.render("▶ #{progress_text}")

          cards_content = @cards.each_with_index.map { |card, i| card.view(focused: i == @selected_index) }.join("\n\n")
          @viewport.content = cards_content

          help_text = "q: quit | ↑/k: up | ↓/j: down | Enter: expand/collapse"
          help_view = Styles.help_text.render(help_text)

          "#{progress_view}\n\n#{@viewport.view}\n#{help_view}"
        end

        private

        def add_prompt_card(prompt)
          card_id = @card_id_counter
          @card_id_counter += 1
          @cards << Components::PromptCard.new(id: card_id, prompt:)
          @selected_index = 0
        end

        def scroll_to_selected
          return if @selected_index.negative? || @cards.empty?

          # Calculate the start line of the selected card by summing rendered
          # line counts of all preceding cards (plus 2 for the "\n\n" separator).
          start_line = @cards.first(@selected_index).sum do |card|
            card.view(focused: false).lines.count + 2
          end

          end_line = start_line + @cards[@selected_index].view(focused: false).lines.count - 1
          vp_height = @viewport.height

          if start_line < @viewport.y_offset
            @viewport.y_offset = start_line
          elsif end_line >= @viewport.y_offset + vp_height
            @viewport.y_offset = end_line - vp_height + 1
          end
        end
      end
      # rubocop:enable Metrics
    end
  end
end
