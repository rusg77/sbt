require 'chunky_png'
include ChunkyPNG

module Compare

  def compare
    # too slow loading :(
    image_1 = Image.from_file('1.png')
    image_2 = Image.from_file('2.png')
  end

end