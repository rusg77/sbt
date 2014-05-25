require 'benchmark'
require '../compare_examples/rmagick'
require '../compare_examples/chunky'

time = Benchmark.measure do
  1.times do
    ChunkyCompare::get_diff('images/1.png', 'images/2.png')
  end
end

puts time