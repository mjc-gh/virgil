# frozen_string_literal: true

require "thor"
require "ruby_llm"
require "yaml"

require_relative "virgil/cli"
require_relative "virgil/prompt"
require_relative "virgil/tools"
require_relative "virgil/version"
require_relative "virgil/virgo"

# Always required last
require_relative "virgil/agent"

module Virgil
  Error = Class.new(StandardError)
  MissingConfiguration = Class.new(Error)
  InvalidConfiguration = Class.new(Error)

  class << self
    def available_providers = %w[openrouter anthropic]

    def config_dir
      @config_dir ||= File.join(ENV["XDG_CONFIG_HOME"] || File.join(Dir.home, ".config"), "virgil")
    end

    def config_file
      @config_file ||= File.join(config_dir, "config.yml")
    end

    def config
      @config ||= YAML.safe_load_file(config_file, permitted_classes: [Symbol])
    end

    # Configure RubyLLM and other setup
    def configure!(model:, debug: false)
      api_key = config[:api_key].to_s.strip
      provider = config[:provider].to_s.strip
      model = config[:model].to_s.strip if model.nil? || model.empty?

      raise MissingConfiguration, "api_key is not defined in config.yml" if api_key.empty?
      raise MissingConfiguration, "provider is not defined in config.yml" if provider.empty?
      raise MissingConfiguration, "model is not defined in config.yml nor provided as an option" if model.empty?
      raise InvalidConfiguration, "invalid provider in config.yml" unless available_providers.include?(provider)

      configure_ruby_llm!(api_key:, debug:, model:, provider:)
    end

    private

    def configure_ruby_llm!(api_key:, debug:, model:, provider:)
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")

      RubyLLM.configure do |c|
        c.default_model = model
        c.log_file = "log/session-#{timestamp}-#{rand(0..1e6).to_i}.log"
        c.log_level = (debug ? "debug" : "info").to_sym

        case provider
        when "anthropic"
          c.anthropic_api_key = api_key
        when "openrouter"
          c.openrouter_api_key = api_key
        end
      end
    end
  end
end
