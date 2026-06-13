# frozen_string_literal: true

module Virgil
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
      Virgil.logger.level = :debug if options[:debug]
      Virgil.configure! model: options[:model]

      app = TUI::App.new(initial_prompt: prompt)

      Bubbletea.run(
        app,
        alt_screen: true,
        mouse_cell_motion: true
      )
    end
  end
end
