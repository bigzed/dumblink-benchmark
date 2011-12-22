# Copyright (c) 2011 Steve Dierker
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

#!/usr/bin/env ruby

require 'fileutils'

# Setup test directory structure
def setup(target)
  Dir.mkdir(target) unless File.directory?(target)
  Dir.mkdir(target+"/cpp") unless File.directory?(target+"/cpp")
  Dir.mkdir(target+"/ruby") unless File.directory?(target+"/ruby")
  Dir.mkdir(target+"/method") unless File.directory?(target+"/method")
end

# tearDown structure
def tearDown(target)
  FileUtils.rm_rf(target)
end

# Time execution time of method or block
def time_method
  beginning_time = Time.now
  yield
  end_time = Time.now
  (end_time - beginning_time) * 1000
end

def main
  source = File.absolute_path(ARGV[0])
  target = File.absolute_path(ARGV[1])
  amount = ARGV[2].to_i

  cppD = target + "/cpp"
  rubyD = target + "/ruby"
  methodD = target + "/method"

  timeCpp = 0
  timeRuby = 0
  timeMethod = 0
  times = 1
 
  for j in 0..(times-1) do
    setup(target)
    timeCpp += time_method { system("dumblink_cpp/bin/dumblink #{source} #{cppD} #{amount}") }
    tearDown(cppD)
    timeRuby += time_method { system("ruby dumblink_rb/dumblink #{source} #{cppD} #{amount}") }
    tearDown(rubyD)
    timeMethod += time_method { for i in 0..(amount -1) do
                                File.link(source, (methodD + "/link#{i}"))
                               end }
    tearDown(methodD)
  end
  
  puts "This will benchmark hardlink creation of ruby and c++"
  puts "Dumblink C++: #{timeCpp/times}ms"
  puts "Dumblink Ruby: #{timeRuby/times}ms"
  puts "Dumblink Method: #{timeMethod/times}ms"

  tearDown(target)
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length < 3
    puts "Usage: " + $PROGRAMM_NAME + " <source> <target_dir> <amount>"
    Kernel.exit(1)
 end
  main()
end
