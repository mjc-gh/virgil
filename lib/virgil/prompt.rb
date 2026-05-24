# frozen_string_literal: true

module Virgil
  module Prompt
    def self.load(name)
      File.read File.expand_path(File.join("prompts", "#{name}.md"), __dir__)
    end
  end
end
