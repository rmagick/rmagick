
require 'RMagick'

require 'minitest/autorun'
require 'fileutils'

class MiniTest::Test
  def assert_nothing_raised(&block)
    yield
  end
  
  def assert_raise(*args, &block)
    assert_raises(*args, &block)
  end
  
  def assert_not_same(expected, actual, message = '')
    assert(!expected.equal?(actual), message)
  end
  
  def assert_not_equal(*args)
    refute_equal(*args)
  end
  
  def assert_not_nil(*args)
    refute_nil(*args)
  end
end
