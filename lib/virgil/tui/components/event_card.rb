# frozen_string_literal: true

module Virgil
  module TUI
    module Components
      class EventCard
        attr_reader :id, :header, :content, :expanded

        def initialize(id:, header:, content:, expanded: false)
          @id = id
          @header = header
          @content = content
          @expanded = expanded
        end

        def toggle
          @expanded = !@expanded
          self
        end

        def update_content(new_content)
          @content = new_content
          self
        end

        def view
          if @expanded
            render_expanded
          else
            render_collapsed
          end
        end

        private

        def render_collapsed
          summary = @content.is_a?(String) ? @content.split("\n").first&.slice(0, 60) : @content.to_s.slice(0, 60)
          summary = "#{summary}..." if summary && summary.length >= 60

          header_view = Styles.card_title.render("▶ #{@header}")
          content_view = Styles.card_collapsed.render(summary || "(no content)")

          card_content = "#{header_view}\n#{content_view}"
          Styles.card_border.render(card_content)
        end

        def render_expanded
          header_view = Styles.card_title.render("▼ #{@header}")
          content_lines = @content.is_a?(String) ? @content.split("\n") : [@content.to_s]
          content_view = Styles.card_expanded.render(content_lines.join("\n"))

          card_content = "#{header_view}\n#{content_view}"
          Styles.card_border.render(card_content)
        end
      end
    end
  end
end
