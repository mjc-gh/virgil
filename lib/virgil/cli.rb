# frozen_string_literal: true

module Virgil
  class CLI < Thor
    def self.exit_on_failure? = true

    desc "explore PROMPT", "Explore the web with Virgil using PROMPT"
    def explore(prompt)
      message = Agent.new.explore(prompt)

      puts message.content
    end
  end
end
