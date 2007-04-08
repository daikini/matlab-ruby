# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/matlab/version.rb'

Hoe.new('matlab-ruby', Matlab::Version::STRING) do |p|
  p.rubyforge_name = 'matlab-ruby'
  p.author = ["Jonathan Younger"]
  p.email = ["jonathan.younger@lipomics.com"]
  p.summary = "A Ruby interface to the Matlab interpreted language."
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = "http://matlab-ruby.rubyforge.org/"
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.spec_extras["extensions"] = "ext/matlab_api/extconf.rb"
end

# vim: syntax=Ruby
