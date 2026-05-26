# frozen_string_literal: true

module Virgil
  class CLI < Thor
    def self.exit_on_failure? = true

    desc "explore PROMPT", "Explore the web with Virgil using PROMPT"
    def explore(prompt)
      agent = Agent.new
      agent.after_message do |message|
        case message.role
        when :tool
          puts "[tool] #{message.tool_call_id[20..]} (content size: #{message.content.size})"

        when :assistant
          if !message.tool_calls.nil? && message.tool_calls.any?
            tool_tally = message.tool_calls.values.map(&:name).tally

            puts "[virgil] #{tool_tally}"
          end

          puts "[virgil] #{message.content}" unless message.content.empty?
        end
      end

      agent.before_tool_call do |tool_call|
        puts "[#{tool_call.name}] called with #{tool_call.arguments.inspect}"
      end

      agent.explore prompt
    end
  end
end
