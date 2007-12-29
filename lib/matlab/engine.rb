module Matlab
  
  # The Engine class encapsulates a single connection to a MATLAB instance.
  # Usage:
  #
  #   require 'matlab'
  #
  #   engine = Matlab::Engine.new
  #
  #   engine.x = 123.456
  #   engine.y = 789.101112
  #   engine.eval_string "z = x * y"
  #   p engine.z
  #
  #   engine.close
  #
  # Values are sent to and from MATLAB by calling a method on the
  # engine with the variable name of interest.
  class Engine
    # The low-level opaque engine handle that this object wraps.
    attr_reader :handle

    # A reference to the underlying MATLAB driver used by this engine.
    attr_reader :driver
    
    # Create a new Engine object that connects to MATLAB via the given command
    def initialize(command = "matlab -nodesktop -nosplash", options = {})
      load_driver(options[:driver])
      
      @handle = @driver.open(command)
    end
    
    # Sends the given string to MATLAB to be evaluated
    def eval_string(string)
      @driver.eval_string(@handle, string)
    end
    
    # Put a value to MATLAB via a given name
    def put_variable(name, value)
      @driver.put_variable(@handle, name, value)
    end
    
    # Get a value from MATLAB via a given name
    def get_variable(name)
      @driver.get_variable(@handle, name)
    end
    
    # Call a MATLAB function passing in the arguments
    def method_missing(method_id, *args)
      method_name = method_id.id2name
      
      variable_names = []
      args.each_with_index do |arg, index|
        variable_names << variable_name = "mr#{index}_#{method_name}"
        put_variable(variable_name, arg)
      end
      
      eval_string("#{method_name}(#{variable_names.join(", ")})")
      result = get_variable("ans")
      eval_string("clear #{variable_names.join(" ")}")
      result
    end
      
    # Closes this engine
    def close
      @driver.close(@handle)
    end
    
    private
      # Loads the corresponding driver, or if it is nil, attempts to locate a
      # suitable driver.
      def load_driver(driver)
        case driver
          when Class
            # do nothing--use what was given
          when Symbol, String
            require "matlab/driver/#{driver.to_s.downcase}/driver"
            driver = Matlab::Driver.const_get(driver)::Driver
          else
            [ "Native" ].each do |d|
              begin
                require "matlab/driver/#{d.downcase}/driver"
                driver = Matlab::Driver.const_get(d)::Driver
                break
              rescue SyntaxError
                raise
              rescue ScriptError, Exception, NameError
              end
            end
            raise "no driver for matlab found" unless driver
        end

        @driver = driver.new
      end
  end
end
