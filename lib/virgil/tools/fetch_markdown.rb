# frozen_string_literal: true

module Virgil::Tools
  class FetchMarkdown < RubyLLM::Tool
    desc "Fetch the content of a URL as markdown"

    param :url, type: :string, desc: "URL to fetch", required: true

    def execute(url:)
      args = [url]
      args.prepend "--remote-host", self.class.remote_host, "--remote-port", self.class.remote_port if self.class.use_remote?

      stdout, stderr, status = Open3.capture3("virgo", "markdown", "--json-logs", *args)

      if status.success?
        stdout
      elsif stderr.empty?
        return { error: stdout }
      else
        begin
          result = JSON.parse(stderr)

          return { error: result.dig("message") || JSON.pretty_generate(result) }
        rescue JSON::ParserError
          return { error: stderr }
        end
      end

    rescue StandardError => e
      return { error: "#{e.class}: #{e.message}" }
    end

    def self.remote_host = ENV["VIRGIL_REMOTE_HOST"]
    def self.remote_port = ENV["VIRGIL_REMOTE_PORT"]

    def self.use_remote?
      !ENV["VIRGIL_REMOTE_HOST"].nil? &&
        !ENV["VIRGIL_REMOTE_PORT"].nil?
    end
  end
end
