# frozen_string_literal: true

module Virgil
  module TUI
    class ToolCallMessage
      attr_reader :tool_name, :arguments

      def initialize(tool_name:, arguments:)
        @tool_name = tool_name
        @arguments = arguments
      end
    end

    class ToolResultMessage
      attr_reader :tool_call_id, :content

      def initialize(tool_call_id:, content:)
        @tool_call_id = tool_call_id
        @content = content
      end
    end

    class AgentResponseMessage
      attr_reader :content, :tool_calls

      def initialize(content:, tool_calls: nil)
        @content = content
        @tool_calls = tool_calls
      end
    end

    class GoalCompletedMessage
      attr_reader :content

      def initialize(content:)
        @content = content
      end
    end

    class ProgressMessage
      attr_reader :runs, :max_runs

      def initialize(runs:, max_runs:)
        @runs = runs
        @max_runs = max_runs
      end
    end

    class SubmitPromptMessage
      attr_reader :prompt

      def initialize(prompt:)
        @prompt = prompt
      end
    end

    class ResizeMessage
      attr_reader :width, :height

      def initialize(width:, height:)
        @width = width
        @height = height
      end
    end

    # Message to signal quit action
    class QuitMessage # rubocop:disable Lint/EmptyClass
    end

    # Internal message for queue polling - not sent from agent thread
    class QueuePollMessage # rubocop:disable Lint/EmptyClass
    end
  end
end
