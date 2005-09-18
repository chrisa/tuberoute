require File.dirname(__FILE__) + '/../test_helper'

class NodesetTest < Test::Unit::TestCase
  fixtures :nodesets

  def setup
    @nodeset = Nodeset.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Nodeset,  @nodeset
  end
end
