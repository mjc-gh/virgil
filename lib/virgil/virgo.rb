# frozen_string_literal: true

module Virgil
  module Virgo
    ExecError = Class.new(StandardError) do
      def initialize(code, result)
        @code = code
        @result = result

        super("virgo exec failed (exit code: #{@code})")
      end

      attr_reader :status, :result
    end

    class << self
      def exec(subcmd, url)
        stdout, stderr, status = Open3.capture3(*build_args(subcmd, url))

        return stdout if status.success?

        handle_error status.exitstatus, stdout, stderr
      end

      private

      def build_args(subcmd, url)
        ["virgo", subcmd, "--json-logs"].tap do |args|
          args.push "--remote-host", remote_host, "--remote-port", remote_port if use_remote?
          args << url
        end
      end

      def handle_error(code, stdout, stderr)
        raise ExecError.new(code, stdout) if stderr.empty?

        begin
          result = JSON.parse(stderr.split("\n", 2).shift)

          raise ExecError.new(code, result["message"]) if result["message"]

          raise ExecError.new(code, stderr)
        rescue JSON::ParserError
          raise ExecError.new(code, stderr)
        end
      end

      def remote_host = ENV.fetch("VIRGIL_REMOTE_HOST", nil)
      def remote_port = ENV.fetch("VIRGIL_REMOTE_PORT", nil)

      def use_remote?
        !ENV["VIRGIL_REMOTE_HOST"].nil? &&
          !ENV["VIRGIL_REMOTE_PORT"].nil?
      end
    end
  end
end
