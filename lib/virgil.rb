# frozen_string_literal: true

require "thor"
require "ruby_llm"

require_relative "virgil/cli"
require_relative "virgil/prompt"
require_relative "virgil/tools"
require_relative "virgil/version"
require_relative "virgil/virgo"

# Always required last
require_relative "virgil/agent"

module Virgil
  class Error < StandardError; end
end

# TODO: move this elsewhere?
RubyLLM.configure do |config|
  config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY", nil)
  config.default_model = "google/gemini-2.5-flash-lite"

  timestamp = Time.now.strftime("%Y%m%d_%H%M%S")

  config.log_file = "log/session-#{timestamp}-#{rand(0..1e6).to_i}.log"
  config.log_level = ENV.fetch("VIRGIL_LOG_LEVEL", "info").to_sym
end
