# frozen_string_literal: true

module Virgil
  module TUI
    module Components
      # Card for displaying agent response messages with goal completion indicator
      # rubocop:disable Metrics
      class ResponseCard < EventCard
        attr_reader :is_goal_completed

        def initialize(id:, content:, is_goal_completed: false)
          @is_goal_completed = is_goal_completed
          header = is_goal_completed ? "✓ Goal Completed" : "💬 Agent Response"
          super(id:, header:, content:, expanded: true)
        end

        def render_expanded
          icon = @is_goal_completed ? "✓" : "💬"
          header_text = @is_goal_completed ? "Goal Completed" : "Agent Response"
          style = @is_goal_completed ? Styles.success : Styles.info
          header_view = style.render("▼ #{icon} #{header_text}")

          content_lines = @content.is_a?(String) ? @content.split("\n") : [@content.to_s]
          content_view = Styles.card_expanded.render(content_lines.join("\n"))

          card_content = "#{header_view}\n#{content_view}"
          Styles.card_border.render(card_content)
        end

        def render_collapsed
          icon = @is_goal_completed ? "✓" : "💬"
          header_text = @is_goal_completed ? "Goal Completed" : "Agent Response"
          style = @is_goal_completed ? Styles.success : Styles.info
          header_view = style.render("▶ #{icon} #{header_text}")

          summary = @content.is_a?(String) ? @content.split("\n").first&.slice(0, 60) : @content.to_s.slice(0, 60)
          summary = "#{summary}..." if summary && summary.length >= 60

          content_view = Styles.card_collapsed.render(summary || "(no content)")

          card_content = "#{header_view}\n#{content_view}"
          Styles.card_border.render(card_content)
        end
      end
      # rubocop:enable Metrics
    end
  end
end
