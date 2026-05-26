# frozen_string_literal: true

module Virgil
  module Tools
    class CustomSearch < RubyLLM::Tool
      desc "Search DuckDuckGo for links and to explore when researching"

      param :query, type: :string, desc: "Search query", required: true

      def execute(query:)
        url = "https://lite.duckduckgo.com/lite?q=#{query}"

        Virgil::Virgo.exec "links", url
      rescue Virgil::Virgo::ExecError => e
        { error: e.result }
      rescue StandardError => e
        { error: "#{e.class}: #{e.message}" }
      end
    end
  end
end
