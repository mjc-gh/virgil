# frozen_string_literal: true

module Virgil
  class Agent < RubyLLM::Agent
    def initialize
      @chat = RubyLLM.chat
      @chat.with_instructions Prompt.load("initial")
      @chat.with_tools(
        Tools::FetchMarkdown
      )
    end

    def explore(prompt)
      @chat.ask(prompt)
    end
  end
end
