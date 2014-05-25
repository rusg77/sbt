require 'RMagick'

module Compare

  # фукнкция для сравнения двух изображений
  # @param [String] img1 путь к первому изображению
  # @param [String] img2 путь ко второму изображению
  # @return [String] результирующее изображение
  def self.compare(img1, img2)
    # загружаем в память первое изображение
    img1 =  Magick::Image::from_blob(img1).first
    # загружаем в память второе изображение
    img2 =  Magick::Image::from_blob(img2).first
    # получаем результирующее изображение с помощью метода compare_channel
    img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric)[0].to_blob
  end


  # фукнкция для сравнения двух изображений и вычисления расхождения в %
  # @param [String] img1 путь к первому изображению
  # @param [String] img2 путь ко второму изображению
  # @return [String, Float] результирующее изображение, процент расхождения
  def self.get_diff(img1, img2)
    # загружаем в память первое изображение
    img1 =  Magick::Image::read(img1).first
    pixels1 = img1.get_pixels(0, 0, img1.columns, img1.rows)
    # загружаем в память второе изображение
    img2 =  Magick::Image::read(img2).first
    pixels2 = img2.get_pixels(0, 0, img2.columns, img2.rows)
    # массив для хранеия пикселей нового изображения
    diff = []
    # переменная для хранения количества различающихся пикселей
    diff_pixels = 0
    pixels1.zip(pixels2).each do |pixel1, pixel2|
      if pixel1 == pixel2
        diff << pixel1
      else
        diff_pixels += 1
        diff << Magick::Pixel.from_color('red')
      end
    end
    img_diff = Magick::Image.new(img1.columns, img1.rows)
    return img_diff.store_pixels(0, 0, img1.columns, img1.rows, diff), diff_pixels.to_f/(img1.columns*img1.rows)*100
  end
end



Compare.get_diff('1.png', '2.png')
