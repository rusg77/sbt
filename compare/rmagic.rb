require 'RMagick'

module Compare

  def self.compare(img1, img2)
    img1 =  Magick::Image::from_blob(img1).first
    img2 =  Magick::Image::from_blob(img2).first
    img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric)[0].to_blob
  end

end
