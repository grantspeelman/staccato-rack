require 'minitest_helper'

class TestStaccato::Rack < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Staccato::Rack::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
