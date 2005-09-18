require File.dirname(__FILE__) + '/../test_helper'

class NodeTest < Test::Unit::TestCase
  fixtures :nodes

  def setup
    @node = Node.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Node,  @node
  end
end
