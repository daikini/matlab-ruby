# Loads mkmf which is used to make makefiles for Ruby extensions
require 'mkmf'

SWIG_WRAP = "matlab_api_wrap.c"

matlab_dirs = dir_config( "matlab", "/usr/local/matlab/extern/include", "/usr/local/matlab/bin/glnx86" )

if have_header( "engine.h" ) && have_library( "eng", "engOpen" )
  if !File.exists?( SWIG_WRAP ) || with_config( "swig", false )
    swig_includes = (matlab_dirs.any? ? (matlab_dirs.collect { |dir| "-I#{dir}" }.join(" ")) : nil)
    puts "creating #{SWIG_WRAP}"
    system "swig -ruby #{swig_includes} matlab_api.i" or raise "could not build wrapper via swig (perhaps swig is not installed?)"
  end
  create_makefile( "matlab_api" )
end
