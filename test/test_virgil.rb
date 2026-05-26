# frozen_string_literal: true

require "test_helper"

class TestVirgil < Minitest::Test
  test "has module version" do
    refute_nil ::Virgil::VERSION
  end
end
