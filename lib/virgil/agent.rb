# frozen_string_literal: true

module Virgil
  class Agent < RubyLLM::Agent
    include ::Virgil::Tools

    instructions { Virgil::Prompt.load("initial") }

    tools CustomSearch, FetchLinks, FetchMarkdown

    def explore(user_prompt)
      ask("GOAL: #{user_prompt}")
    end
  end
end
