# frozen_string_literal: true

module Virgil
  module TUI
    # Main TUI app orchestrating screens and agent communication
    # rubocop:disable Metrics
    class App
      include Bubbletea::Model

      attr_reader :screen, :current_screen, :prompt_screen, :research_screen, :width, :height, :agent_thread,
                  :message_queue, :polling_active

      def initialize(width: 80, height: 24, initial_prompt: nil)
        @width = width
        @height = height
        @current_screen = :prompt
        @initial_prompt = initial_prompt
        @prompt_screen = Screens::Prompt.new(width:, height:)
        @research_screen = Screens::Research.new(width:, height:)
        @agent_thread = nil
        @message_queue = Queue.new
        @polling_active = false
      end

      def update(message)
        case message
        when Bubbletea::WindowSizeMessage
          handle_resize(message)
          return [self, nil]
        when SubmitPromptMessage
          @current_screen = :research
          @polling_active = true
          start_agent_research(message.prompt)
          # Start the queue polling loop
          return [self, Bubbletea.tick(0.1) { QueuePollMessage.new }]
        when QueuePollMessage
          # Drain all messages from the queue
          until @message_queue.empty?
            begin
              msg = @message_queue.pop(true) # non-blocking
              process_queued_message(msg)
            rescue ThreadError
              break # Queue is empty
            end
          end

          # Continue polling if active
          cmd = @polling_active ? Bubbletea.tick(0.1) { QueuePollMessage.new } : nil
          return [self, cmd]
        else
          model, cmd = delegate_to_screen(message)
          return [self, cmd] if cmd
        end

        [self, nil]
      end

      def view
        case @current_screen
        when :prompt
          @prompt_screen.view
        when :research
          @research_screen.view
        end
      end

      private

      def handle_resize(message)
        @width = message.width
        @height = message.height
        @prompt_screen = Screens::Prompt.new(width: @width, height: @height)
        @research_screen = Screens::Research.new(width: @width, height: @height)
      end

      def handle_agent_response(message)
        is_goal_completed = message.content.include?("__GOAL_COMPLETED__")
        @research_screen.add_agent_response(content: message.content, is_goal_completed:)

        # Stop polling when goal is completed
        @polling_active = false if is_goal_completed
      end

      def delegate_to_screen(message)
        case @current_screen
        when :prompt
          @prompt_screen.update(message)
        when :research
          @research_screen.update(message)
        end
      end

      def process_queued_message(msg)
        case msg
        when ToolCallMessage
          @research_screen.add_tool_call(tool_name: msg.tool_name, arguments: msg.arguments)
        when ToolResultMessage
          @research_screen.update_tool_result(content: msg.content)
        when AgentResponseMessage
          handle_agent_response(msg)
        when ProgressMessage
          @research_screen.set_progress(runs: msg.runs, max_runs: msg.max_runs)
        end
      end

      def start_agent_research(prompt)
        @agent_thread = Thread.new do
          agent = Virgil::Agent.new
          setup_agent_callbacks(agent)
          agent.explore(prompt) do |runs, max_runs|
            @message_queue.push(ProgressMessage.new(runs:, max_runs:))
          end
        rescue StandardError => e
          handle_error(e)
        end
      end

      def handle_error(error)
        error_msg = "Error: #{error.message}\n#{error.backtrace.join("\n")}"
        @message_queue.push(ToolResultMessage.new(tool_call_id: "error", content: error_msg))
      end

      def setup_agent_callbacks(agent)
        agent.after_message do |message|
          send_tool_result(message) if message.role == :tool
          send_assistant_messages(message) if message.role == :assistant
        end

        agent.before_tool_call do |tool_call|
          @message_queue.push(ToolCallMessage.new(tool_name: tool_call.name, arguments: tool_call.arguments))
        end
      end

      def send_tool_result(message)
        @message_queue.push(ToolResultMessage.new(tool_call_id: message.tool_call_id, content: message.content))
      end

      def send_assistant_messages(message)
        send_tool_calls(message.tool_calls) if message.tool_calls&.any?
        return unless message.content && !message.content.empty?

        @message_queue.push(AgentResponseMessage.new(content: message.content, tool_calls: message.tool_calls))
      end

      def send_tool_calls(tool_calls)
        tool_calls.each_value do |tool_call|
          @message_queue.push(ToolCallMessage.new(tool_name: tool_call.name, arguments: tool_call.arguments))
        end
      end
    end
    # rubocop:enable Metrics
  end
end
