require 'test/unit'
require 'matlab'
require 'matlab/engine'
require 'rubygems'
require 'mocha'

class Driver
end

class EngineTest_Init < Test::Unit::TestCase
  def test_new
    driver = mock()
    driver.expects(:open).with("matfoo")
    Driver.expects(:new).returns(driver)
    
    engine = Matlab::Engine.new("matfoo", :driver => Driver)
  end
  
  def test_new_with_invalid_driver
    exception = assert_raise(LoadError) do
      engine = Matlab::Engine.new("matfoo", :driver => "foo")
    end
    assert_equal "no such file to load -- matlab/driver/foo/driver", exception.message
    
    exception = assert_raise(LoadError) do
      engine = Matlab::Engine.new("matfoo", :driver => :bar)
    end
    assert_equal "no such file to load -- matlab/driver/bar/driver", exception.message
  end
  
  def test_new_with_native_driver
    begin
      require 'matlab_api'
      
      Matlab::Driver::Native::API.expects(:engOpen).with("matfoo")
      assert_nothing_raised do
        engine = Matlab::Engine.new("matfoo")
      end
    rescue LoadError => e
      exception = assert_raise(RuntimeError) do
        engine = Matlab::Engine.new("matfoo")
      end
      assert_equal "no driver for matlab found", exception.message
    end
  end
end

class EngineTest < Test::Unit::TestCase
  def setup
    @driver = mock()
    @handle = mock()
    @driver.expects(:open).with("matfoo").returns(@handle)
    Driver.expects(:new).returns(@driver)
    
    @engine = Matlab::Engine.new("matfoo", :driver => Driver)
  end
  
  def test_eval_string
    @driver.expects(:eval_string).with(@handle, "z = x * y")
    @engine.eval_string "z = x * y"
  end
  
  def test_close
    @driver.expects(:close).with(@handle)
    @engine.close
  end
  
  def test_get_variable
    @driver.expects(:get_variable).with(@handle, "x")
    @engine.get_variable("x")
  end
  
  def test_put_variable
    @driver.expects(:put_variable).with(@handle, "y", 123.456)
    @engine.put_variable("y", 123.456)
  end
  
  def test_method_missing
    @engine.expects(:put_variable).with("mr0_rand", 2)
    @engine.expects(:put_variable).with("mr1_rand", 4)
    @engine.expects(:eval_string).with("rand(mr0_rand, mr1_rand)")
    @engine.expects(:get_variable).with("ans").returns("The Answer")
    @engine.expects(:eval_string).with("clear mr0_rand mr1_rand")
    
    assert_equal "The Answer", @engine.rand(2, 4)
  end
end