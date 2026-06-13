# frozen_string_literal: true

module Virgil
  module TUI
    module Screens
      # Research screen with scrollable viewport and collapsible cards
      # rubocop:disable Metrics
      class Research
        include Bubbletea::Model

        attr_reader :cards, :viewport, :width, :height, :progress_runs, :progress_max, :selected_index

        def initialize(width: 80, height: 24)
          @width = width
          @height = height
          @cards = []
          @selected_index = -1
          @progress_runs = 0
          @progress_max = 0
          @card_id_counter = 0
          @viewport = Bubbles::Viewport.new
          @tool_call_map = {}
        end

        def add_tool_call(tool_name:, arguments:)
          card_id = @card_id_counter
          @card_id_counter += 1
          card = Components::ToolCard.new(
            id: card_id,
            tool_name:,
            arguments:
          )
          @cards << card
          @tool_call_map[tool_name] = card_id
          self
        end

        def update_tool_result(content:)
          # Find the most recent tool card with matching name pattern
          @cards.reverse_each do |card|
            if card.is_a?(Components::ToolCard) && card.result.nil?
              card.update_result(content)
              break
            end
          end
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
            when "k", "up"
              @selected_index = [@selected_index - 1, -1].max
            when "enter"
              @cards[@selected_index].toggle if @selected_index.between?(0, @cards.length - 1)
            end
          when ResizeMessage
            @width = message.width
            @height = message.height
          end
          [self, nil]
        end

        def view
          progress_text = @progress_max.positive? ? "Step #{@progress_runs} of #{@progress_max}" : "Researching..."
          progress_view = Styles.progress.render("▶ #{progress_text}")

          cards_content = @cards.map(&:view).join("\n\n")

          help_text = "q: quit | ↑/k: up | ↓/j: down | Enter: expand/collapse"
          help_view = Styles.help_text.render(help_text)

          "#{progress_view}\n\n#{cards_content}\n\n#{help_view}"
        end
      end
      # rubocop:enable Metrics
    end
  end
end
