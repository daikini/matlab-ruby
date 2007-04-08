require 'matlab_api'
require 'matlab/driver/native/conversions'

module Matlab ; module Driver ; module Native
  class Driver
    def open(command)
      API.engOpen(command)
    end

    def close(engine)
      API.engClose(engine)
    end
    
    def eval_string(engine, string)
      API.engEvalString(engine, string)
    end
    
    def get_variable(engine, name)
      API.engGetVariable(engine, name).to_ruby
    end
    
    def put_variable(engine, name, value)
      API.engPutVariable(engine, name, value.to_matlab)
    end
  end
end ; end ; end