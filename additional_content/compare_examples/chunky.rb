require 'chunky_png'

module ChunkyCompare

  # фукнкция для сравнения двух изображений
  # @param [String] img1 путь к первому изображению
  # @param [String] img2 путь ко второму изображению
  # @return [ChunkyPNG::Image] результирующее изображение
  def self.get_diff(img1, img2)
    # загружаем в память первое изображение
    image_1 = ChunkyPNG::Image.from_file(img1)
    # загружаем в память второе изображение
    image_2 = ChunkyPNG::Image.from_file(img2)
    # инициализируем результирующее изображение
    diff = ChunkyPNG::Image.new(image_1.width, image_2.height, ChunkyPNG::Color::TRANSPARENT)
    # цикл по высоте изображения
    image_1.height.times do |y|
      # цикл по ширине изображения
      image_1.row(y).each_with_index do |pixel, x|
        # если пиксели двух изображений одинаковые
        if pixel == image_2[x,y]
          # то в результирующее изображение записываем пиксель второго изображения
          diff[x,y] = pixel
        else
          # иначе заполняем пискель зеленым цветом
          diff[x,y] = ChunkyPNG::Color.rgb(0, 255,0)
        end
      end
    end
    # возвращаем результирующее изображение
    diff.save('diff.png')
  end
end
