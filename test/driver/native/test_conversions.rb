$:.unshift "../../../lib"
require 'test/unit'
require 'matlab'
require 'matlab/driver/native/conversions'
require 'rubygems'
require 'mocha'

class ConversionsTest < Test::Unit::TestCase
  def test_string_to_matlab_to_ruby
    assert_equal "foo", "foo".to_matlab.to_ruby
  end
  
  def test_true_to_matlab_to_ruby
    assert_equal true, true.to_matlab.to_ruby
  end
  
  def test_false_to_matlab_to_ruby
    assert_equal false, false.to_matlab.to_ruby
  end
  
  def test_nil_to_matlab_to_ruby
    assert_equal nil, nil.to_matlab.to_ruby
  end
  
  def test_float_to_ruby
    assert_nil nil.to_matlab.to_ruby
    assert_equal 12.345, 12.345.to_ruby
  end
  
  def test_numeric_to_matlab_to_ruby
    assert_equal 12345.0, 12345.to_matlab.to_ruby
    assert_equal 12.345, 12.345.to_matlab.to_ruby
  end
  
  def test_array_to_cell_matrix
    cell_matrix = Matlab::CellMatrix.new(7, 1)
    cell_matrix[0, 0] = true
    cell_matrix[1, 0] = "1"
    cell_matrix[2, 0] = "2"
    cell_matrix[3, 0] = ["3", nil, 5]
    cell_matrix[4, 0] = 6
    cell_matrix[5, 0] = 7
    cell_matrix[6, 0] = false
    
    assert_equal cell_matrix, [true, "1", "2", ["3", nil, 5], 6, 7, false].to_cell_matrix
  end
  
  def test_array_to_matlab_to_ruby
    assert_equal [1.0, nil, 3.0], [1, nil, 3.0].to_matlab.to_ruby
    assert_equal [1.0, "2", false, ["foo", "bar", "baz"]], [1, "2", false, ["foo", "bar", "baz"]].to_matlab.to_ruby
  end
  
  def test_hash_to_matlab_to_ruby
    assert_equal({"foo" => "bar"}, {"foo" => "bar"}.to_matlab.to_ruby) 
    assert_equal({"foo" => [1.0,2.0,3.0]}, {"foo" => [1,2,3]}.to_matlab.to_ruby) 
    assert_equal({"foo" => { "bar" => [1.0,2.0,3.0, [4.0,5.0,6.0]] }}, {"foo" => { "bar" => [1,2,3, [4,5,6]] }}.to_matlab.to_ruby)
  end
  
  def test_matlab_matrix_to_matlab_to_ruby
    matrix = Matlab::Matrix.new(3, 3)
    3.times { |m| 3.times { |n| matrix[m, n] = rand } }
    matrix[1, 1] = nil
    
    assert_equal matrix, matrix.to_matlab.to_ruby
  end
  
  def test_should_convert_a_0x0_matlab_matrix
    matrix = Matlab::Matrix.new(0, 0)
    assert_equal matrix, matrix.to_matlab.to_ruby
  end
  
  def test_matlab_cell_matrix_to_matlab_to_ruby
    cell_matrix = Matlab::CellMatrix.new(3, 3)
    3.times { |m| 3.times { |n| cell_matrix[m, n] = (n == 1 ? rand.to_s : rand) } }
    cell_matrix[0, 0] = true
    cell_matrix[1, 1] = nil
    cell_matrix[2, 2] = false
    
    assert_equal cell_matrix, cell_matrix.to_matlab.to_ruby
  end
  
  def test_matlab_struct_matrix_to_matlab_to_ruby
    cats = Matlab::StructMatrix.new(17, 1, "name")
    17.times { |m| 1.times { |n| cats[m, n]["name"] = "Kitty #{m}.#{n}" } }
    
    struct_matrix = Matlab::StructMatrix.new(17, 1, "name", "age", "married", "cats", "car")
    17.times do |m|
      1.times do |n|
        struct_matrix[m, n]["name"] = "Bob #{m}.#{n}"
        struct_matrix[m, n]["age"] = (rand * 100).to_i
        struct_matrix[m, n]["married"] = (rand > 0.5)
        struct_matrix[m, n]["cats"] = cats
        struct_matrix[m, n]["car"] = nil
      end
    end
    assert_equal struct_matrix, struct_matrix.to_matlab.to_ruby
  end
end