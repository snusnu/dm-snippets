require 'rubygems'
require 'test/unit'
#require 'spec/test/unit'

module Foo
  def test_foo
    assert_equal 3, 1+2
  end
end

class TestIncludedTestModules < Test::Unit::TestCase
  include Foo
  def test_add_1_and_2
    assert_equal 3, 1 + 2
  end
end

__END__

mungo:snippets snusnu$ spec specunit.rb --format specdoc

TestIncludedTestModules
- test_add_1_and_2

Finished in 0.001532 seconds

1 example, 0 failures

