$:.unshift "../../../lib"
require 'test/unit'
require 'matlab'
require 'matlab/driver/native/driver'
require 'rubygems'
require 'mocha'

class DriverTest < Test::Unit::TestCase
  include Matlab::Driver::Native
  
  def setup
    @driver = Driver.new
  end
  
  def test_open
    API.expects(:engOpen).with("matfoo")
    @driver.open("matfoo")
  end
  
  def test_close
    API.expects(:engClose).with("engine")
    @driver.close("engine")
  end
  
  def test_eval_string
    API.expects(:engEvalString).with("engine", "string")
    @driver.eval_string("engine", "string")
  end
  
  def test_get_variable
    variable = mock(:to_ruby => "bar")
    API.expects(:engGetVariable).with("engine", "foo").returns(variable)
    assert_equal "bar", @driver.get_variable("engine", "foo")
  end
  
  def test_put_variable
    variable = mock(:to_matlab => "bar")
    API.expects(:engPutVariable).with("engine", "foo", "bar")
    @driver.put_variable("engine", "foo", variable)
  end
end