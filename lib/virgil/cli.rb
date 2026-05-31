# frozen_string_literal: true

require "fileutils"

module Virgil
  # rubocop:disable Metrics
  class CLI < Thor
    def self.exit_on_failure? = true

    desc "setup", "Configure a provider and API key"
    def setup
      FileUtils.mkdir_p Virgil.config_dir

      config = Virgil.config

      provider = ask("Which provider?", default: config[:provider], limited_to: Virgil.available_providers)
      model = ask("Default model?", default: config[:model])
      model = nil if model.empty?

      api_key = ask("API Key: ", default: config[:api_key], echo: false)
      abort "API key is required!" if api_key.empty?

      File.open Virgil.config_file, "w+" do |file|
        file << { provider:, model:, api_key: }.to_yaml
      end
    end

    option :debug, type: :boolean, default: false, aliases: :d
    option :model, type: :string, aliases: :m
    desc "explore PROMPT", "Explore the web with Virgil using PROMPT"
    def explore(prompt = nil)
      Virgil.configure!(debug: options[:debug], model: options[:model])

      prompt = ask("What are we researching today?") if prompt.nil?

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

          content = message.content

          next if content.nil? || content.empty?

          if content.include?("__GOAL_COMPLETED__")
            puts "[virgil] * #{content.gsub('__GOAL_COMPLETED__', '')}"
          else
            puts "[virgil] #{content}"
          end
        end
      rescue StandardError => e
        binding.pry
      end

      agent.before_tool_call do |tool_call|
        puts "[#{tool_call.name}] called with #{tool_call.arguments.inspect}"
      end

      agent.explore(prompt) do |runs, max_runs|
        puts "[virgil] goal not met (#{runs} of #{max_runs})"
      end
    end
  end
  # rubocop:enable Metrics
end
