# frozen_string_literal: true

module Virgil
  module Tools
    class FetchLinks < RubyLLM::Tool
      desc "Fetch links for a URL"

      param :url, type: :string, required: true

      def execute(url:)
        Virgil::Virgo.exec "links", url
      rescue Virgil::Virgo::ExecError => e
        { error: e.result }
      rescue StandardError => e
        { error: "#{e.class}: #{e.message}" }
      end
    end
  end
end
