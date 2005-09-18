require File.dirname(__FILE__) + '/../test_helper'

class LineTest < Test::Unit::TestCase
  fixtures :lines

  def setup
    @line = Line.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Line,  @line
  end
end
