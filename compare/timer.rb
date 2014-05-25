require 'benchmark'
require './chunky'
require './rmagick'

# time = Benchmark.measure do
#   10.times do
    Compare::get_diff('1.png', '2.png')
#   end
# end

# puts time