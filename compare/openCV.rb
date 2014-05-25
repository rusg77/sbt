require 'opencv'

module MyOpenCV
  # TODO
  def self.get_diff(img1, img2)
    image_1 = OpenCV::CvMat.load('1.png', OpenCV::CV_LOAD_IMAGE_COLOR)
    image_2 = OpenCV::CvMat.load('1.png', OpenCV::CV_LOAD_IMAGE_COLOR)
  end

end

MyOpenCV.get_diff('1', '2')