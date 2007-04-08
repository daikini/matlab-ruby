matlab-ruby
    http://matlab-ruby.rubyforge.org/
    jonathan.younger@lipomics.com
    A big thank you to Lipomics Technologies, Inc. http://www.lipomics.com for sponsoring this project.
    
== DESCRIPTION:
  
A Ruby interface to the MATLAB interpreted language.

== FEATURES:
  
* Data type conversion between MATLAB and Ruby String, Boolean, Nil and Numeric values
* Matrix, CellMatrix and StructMatrix helper classes for working with MATLAB matrices

== USAGE:

  require 'matlab'
  
  engine = Matlab::Engine.new
  engine.x = 123.456
  engine.y = 789.101112
  engine.eval_string "z = x * y"
  engine.z
  
  matrix = Matlab::Matrix.new(20, 400)
  20.times { |m| 400.times { |n| matrix[m, n] = rand } }
  engine.m = matrix
  
  engine.eval_string "save '/tmp/20_x_400_matrix"
  engine.close

== REQUIREMENTS:

* MATLAB
* GCC or some other compiler to build the included extension
* SWIG (If you want to recompile the SWIG wrapper)
* Mocha (For testing only)

== INSTALL:

Simply do the following, after installing MATLAB:

  * ruby setup.rb config
  * ruby setup.rb setup
  * ruby setup.rb install

Alternatively, you can download and install the RubyGem package for
matlab-ruby (you must have RubyGems and MATLAB installed, first):

  * gem install matlab-ruby

If you have MATLAB installed in a non-standard location, you can specify the location of the include and lib files by doing:

  * gem install matlab-ruby -- --with-matlab-include=/usr/local/matlab/extern/include \
     --with-matlab-lib=/usr/local/matlab/bin/glnx86

Also, the gem ships with the C source-code pre-built, so 
you do not need to have SWIG installed. However, if you have SWIG installed
and you want to generate the C file yourself, you can specify the
<code>--with-swig</code> option.

== LEGAL

MATLAB is a trademark of The MathWorks, Inc.

== LICENSE

matlab-ruby is licensed under the MIT License.

Copyright (c) 2007 Jonathan Younger <jonathan.younger@lipomics.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
