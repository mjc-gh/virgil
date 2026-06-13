# frozen_string_literal: true

module Virgil
  module TUI
    module Components
      # Card displaying the user's research prompt at the top of the research screen
      class PromptCard < EventCard
        def initialize(id:, prompt:)
          super(id:, header: "🔍 Research Prompt", content: prompt, expanded: false)
        end
      end
    end
  end
end
