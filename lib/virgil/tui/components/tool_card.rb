# frozen_string_literal: true

module Virgil
  module TUI
    module Components
      class ToolCard < EventCard
        attr_reader :tool_call_id, :tool_name, :arguments, :result

        def initialize(id:, tool_call_id:, tool_name:, arguments:, result: nil)
          @tool_call_id = tool_call_id
          @tool_name = tool_name
          @arguments = arguments
          @result = result

          content = format_arguments(arguments)
          super(id:, header: "🔧 #{tool_name}", content:, expanded: false)
        end

        def update_result(new_result)
          @result = new_result
          self
        end

        private

        def format_arguments(args)
          case args
          when Hash
            args.map { |k, v| "  #{k}: #{format_value(v)}" }.join("\n")
          when String
            args
          else
            args.to_s
          end
        end

        def format_value(value)
          case value
          when String
            value.length > 50 ? "#{value.slice(0, 47)}..." : value
          when Hash, Array
            value.inspect.slice(0, 50)
          else
            value.to_s.slice(0, 50)
          end
        end

        def render_expanded(focused: false)
          header_view = Styles.card_title.render("▼ #{@header}")

          args_section = "Arguments:\n#{@content}"
          result_section = if @result
                             "\n\nResult:\n#{@result.is_a?(String) ? @result : @result.inspect}"
                           else
                             "\n\n(pending...)"
                           end

          full_content = "#{args_section}#{result_section}"
          content_view = Styles.card_expanded.render(full_content)

          card_content = "#{header_view}\n#{content_view}"
          border_style(focused).render(card_content)
        end

        def render_collapsed(focused: false)
          header_view = Styles.card_title.render("▶ #{@header}")
          summary = @content.split("\n").first&.slice(0, 60)
          summary = "#{summary}..." if summary && summary.length >= 60

          content_view = Styles.card_collapsed.render(summary || "(no content)")

          card_content = "#{header_view}\n#{content_view}"
          border_style(focused).render(card_content)
        end
      end
    end
  end
end
