# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "virgil"

require "minitest/autorun"

module Minitest
  class Test
    def self.test(name, &)
      define_method("test_#{name.gsub(/\s+/, '_')}", &)
    end

    def self.setup(&)
      define_method(:setup, &)
    end

    def self.teardown(&)
      define_method(:teardown, &)
    end
  end
end
