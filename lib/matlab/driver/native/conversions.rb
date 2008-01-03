require 'matlab_api'
require 'matlab/matrix'

class String
  # Converts the string to a MATLAB mxArray
  def to_matlab
    Matlab::Driver::Native::API.mxCreateString(self)
  end
end

class TrueClass
  # Converts true to a MATLAB logical scalar
  def to_matlab
    Matlab::Driver::Native::API.mxCreateLogicalScalar(self)
  end
end

class FalseClass
  # Converts false to a MATLAB logical scalar
  def to_matlab
    Matlab::Driver::Native::API.mxCreateLogicalScalar(self)
  end
end

class NilClass
  # Converts nil to MATLAB NaN
  def to_matlab
    Matlab::Driver::Native::API.mxGetNaN
  end
  
  def to_ruby
    nil
  end
end

class Float
  # Converts the value to nil if it is a MATLAB NaN
  def to_ruby
    to_s == nil.to_matlab.to_s ? nil : self
  end
end

class Numeric
  # Converts the value to a MATLAB double
  def to_matlab
    Matlab::Driver::Native::API.mxCreateDoubleScalar(self)
  end
end

class Array
  # Converts the array into a 1 Dimensional MATLAB numeric or cell matrix
  def to_matlab
    if all? { |value| value.kind_of?(Numeric) || value.nil? }
      matrix = Matlab::Matrix.new(size, 1)
    
      each_with_index do |value, index|
        matrix[index, 0] = value
      end
      matrix.to_matlab
    else
      to_cell_matrix.to_matlab
    end
  end
  
  # Flattens and converts the array to a 1 Dimensional Matlab::CellMatrix
  def to_cell_matrix
    cell_matrix = Matlab::CellMatrix.new(size, 1)
    
    each_with_index do |value, index|
      cell_matrix[index, 0] = value
    end
    cell_matrix
  end
end

class Hash
  # Converts the hash into a 1 Dimensional MATLAB struct matrix
  def to_matlab
    struct_matrix = Matlab::StructMatrix.new(1, 1, *keys)
    
    each do |(key, value)|
      struct_matrix[0,0][key] = value
    end
    
    struct_matrix.to_matlab
  end
end

module Matlab
  class Matrix
    # Converts the matrix into a MATLAB numeric matrix
    def to_matlab
      matrix = Matlab::Driver::Native::API.mxCreateDoubleMatrix(m, n, Matlab::Driver::Native::API::MxREAL)
      double_array = Matlab::Driver::Native::API::DoubleArray.new(m * n)
      
      index = 0
      n.times do |column_index|
        m.times do |row_index|
          double_array[index] = (@cells[row_index][column_index] ? @cells[row_index][column_index].to_f : nil.to_matlab)
          index += 1
        end
      end
      
      Matlab::Driver::Native::API.mxSetPr(matrix, double_array)
      matrix
    end
    
    # Creates a Matlab::Matrix or Ruby Array from a MATLAB numeric matrix
    def self.from_matlab(matrix)
      m = Matlab::Driver::Native::API.mxGetM(matrix)
      n = Matlab::Driver::Native::API.mxGetN(matrix)
      
      matlab_matrix = self.new(m, n)
      double_array = Matlab::Driver::Native::API::DoubleArray.frompointer(Matlab::Driver::Native::API.mxGetPr(matrix))
      
      index = 0
      n.times do |column_index|
        m.times do |row_index|
          matlab_matrix[row_index, column_index] = (Matlab::Driver::Native::API.mxIsNaN(double_array[index]) ? nil : double_array[index])
          index += 1
        end
      end
      
      if m == 1 || n == 1
        matlab_matrix.cells.flatten
      else
        matlab_matrix
      end
    end
  end
  
  class CellMatrix
    # Converts the matrix into a MATLAB cell matrix
    def to_matlab
      matrix = Matlab::Driver::Native::API.mxCreateCellMatrix(m, n)
      
      index = 0
      n.times do |column_index|
        m.times do |row_index|
          value = (@cells[row_index][column_index].nil? ? Matlab::Driver::Native::API.mxCreateDoubleScalar(nil.to_matlab) : @cells[row_index][column_index].to_matlab)
          Matlab::Driver::Native::API.mxSetCell(matrix, index, value)
          index += 1
        end
      end

      matrix
    end
    
    # Creates a Matlab::CellMatrix or Ruby Array from a MATLAB cell matrix
    def self.from_matlab(matrix)
      m = Matlab::Driver::Native::API.mxGetM(matrix)
      n = Matlab::Driver::Native::API.mxGetN(matrix)
      
      cell_matrix = self.new(m, n)
      
      index = 0
      n.times do |column_index|
        m.times do |row_index|
          value = Matlab::Driver::Native::API.mxGetCell(matrix, index).to_ruby
          cell_matrix[row_index, column_index] = (value.nil? || value.to_s == nil.to_matlab.to_s ? nil : value)
          index += 1
        end
      end
      
      if m == 1 || n == 1
        cell_matrix.cells.collect { |cell| cell.first }
      else
        cell_matrix
      end
    end
  end
  
  class StructMatrix
    # Converts the matrix into a MATLAB struct matrix
    def to_matlab
      matrix = Matlab::Driver::Native::API.mxCreateStructMatrix(m, n, 0, nil)
      names.each { |name| Matlab::Driver::Native::API.mxAddField(matrix, name) }
      
      index = 0
      m.times do |row_index|
        n.times do |column_index|
          names.each do |name|
            value = (@cells[row_index][column_index][name].nil? ? Matlab::Driver::Native::API.mxCreateDoubleScalar(nil.to_matlab) : @cells[row_index][column_index][name].to_matlab)
            Matlab::Driver::Native::API.mxSetField(matrix, index, name, value)
          end
          index += 1
        end
      end

      matrix
    end
    
    # Creates a Matlab::StructMatrix or Ruby Hash from a MATLAB struct matrix
    def self.from_matlab(matrix)
      m = Matlab::Driver::Native::API.mxGetM(matrix)
      n = Matlab::Driver::Native::API.mxGetN(matrix)
      names = (0...Matlab::Driver::Native::API.mxGetNumberOfFields(matrix)).collect { |i| Matlab::Driver::Native::API.mxGetFieldNameByNumber(matrix, i) }
      
      struct_matrix = self.new(m, n, *names)
      
      index = 0
      m.times do |row_index|
        n.times do |column_index|
          names.each do |name|
            value = Matlab::Driver::Native::API.mxGetField(matrix, index, name)
            struct_matrix[row_index, column_index][name] = (value.nil? || Matlab::Driver::Native::API.mxIsEmpty(value) || value.to_ruby.to_s == nil.to_matlab.to_s ? nil : value.to_ruby)
          end
          index += 1
        end
      end
      
      if m == 1 && n == 1
        struct_matrix.cells.flatten.first
      else
        struct_matrix
      end
    end
  end
end

class SWIG::TYPE_p_mxArray_tag
  include Matlab::Driver::Native::API
  
  def to_ruby
    case
    when mxIsStruct(self)
      Matlab::StructMatrix.from_matlab(self)
    when mxIsCell(self)
      Matlab::CellMatrix.from_matlab(self)
    when mxIsChar(self)
      mxArrayToString(self)
    when mxIsLogical(self)
      mxIsLogicalScalarTrue(self)
    when (mxGetM(self) > 1 || mxGetN(self) > 1)
      Matlab::Matrix.from_matlab(self)
    when mxIsDouble(self)
      mxGetScalar(self)
    when mxIsEmpty(self)
      nil
    end
  end
end