# frozen_string_literal: true

module Virgil
  class Agent < RubyLLM::Agent
    MAX_RUNS = 5

    include ::Virgil::Tools

    instructions { Virgil::Prompt.load("initial") }

    tools CustomSearch, FetchLinks, FetchMarkdown

    def explore(user_prompt)
      goal = user_prompt
      runs = 0

      loop do
        runs += 1
        resp = ask("STEP: #{runs} of #{MAX_RUNS}\nGOAL: #{goal}")

        break if resp.content.include?("__GOAL_COMPLETED__")
        break if runs >= MAX_RUNS

        yield runs, MAX_RUNS if runs > 1

        goal = "#{user_prompt}.\n LAST RUN: #{resp.content}"
      end
    end
  end
end
