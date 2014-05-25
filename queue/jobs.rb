require 'rmagick'
require_relative '../db/db'
require_relative '../tests/messages'
require_relative '../tests/login'

module Analyse
  @queue = :analyse

  # фукнкция для сравнения двух изображений и вычисления расхождения в %
  # @param [String] img1 первое изображение
  # @param [String] img2 второе изображение
  # @return [String, Float] результирующее изображение, процент расхождения
  def self.get_diff(img1, img2)
    # загружаем в память первое изображение
    img1 =  Magick::Image::from_blob(img1).first
    pixels1 = img1.get_pixels(0, 0, img1.columns, img1.rows)
    # загружаем в память второе изображение
    img2 =  Magick::Image::from_blob(img2).first
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
    img_diff.format = 'png'
    return img_diff.store_pixels(0, 0, img1.columns, img1.rows, diff).to_blob, diff_pixels.to_f/(img1.columns*img1.rows)*100
  end

  def self.perform(params)
    db = Mongo::MongoDB.new
    # result = params['result']
    result = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
    units_1 = params['report_1']['test_units']
    units_2 = params['report_2']['test_units']
    result_id = params['result_id']
    # цикл по тестовым группам
    units_1.each do |unit_name, unit_data|
      if units_2.has_key?(unit_name)
        # цикл по тестам
        unit_data['tests'].each do |test_name, test_data|
          if units_2[unit_name]['tests'].has_key?(test_name)
            result['test_units'][unit_name]['tests'][test_name]['status'] = 'ok'
            if test_data['screenshots'].length == units_2[unit_name]['tests'][test_name]['screenshots'].length
              result['test_units'][unit_name]['tests'][test_name]['screenshot_length'] = 'ok'
              if test_data['screenshots'].length == 0
                result['test_units'][unit_name]['tests'][test_name]['screenshots_non_zero'] = 'fail'
              else
                result['test_units'][unit_name]['tests'][test_name]['screenshots_non_zero'] = 'ok'
                result['test_units'][unit_name]['tests'][test_name]['screenshots'] = []
                screenshots_1 = test_data['screenshots']
                screenshots_2 = units_2[unit_name]['tests'][test_name]['screenshots']
                screenshots_1.each_with_index do |screenshot_1, index|
                  screenshots_data = []
                  screenshots_data << screenshot_1
                  screenshots_data << screenshots_2[index]
                  screenshot_1_img = db.get_screenshot(screenshot_1).read
                  screenshot_2_img = db.get_screenshot(screenshots_2[index]).read
                  diff, percent  = self.get_diff(screenshot_1_img, screenshot_2_img)
                  diff_id = db.add_screenshot(diff).to_s
                  screenshots_data << diff_id
                  screenshots_data << percent
                  result['test_units'][unit_name]['tests'][test_name]['screenshots'] << screenshots_data
                end
              end
            else
              result['test_units'][unit_name]['tests'][test_name]['screenshot_length'] = 'fail'
            end
          else
            result['test_units'][unit_name]['tests'][test_name]['status'] = 'no_data'
          end
        end
        result['test_units'][unit_name]['status'] = 'done'
      else
        result['test_units'][unit_name]['status'] = 'no_data'
      end
    end
    result['end_time'] = Time.now.to_i
    result['status'] = 'done'
    db.update_result(result_id, result)
  end
end


module Execute
  @queue = :execute

  def self.perform(params)
    db = Mongo::MongoDB.new
    puts params

    test_units_count = params['all_tests'].length
    report = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
    threads = (0..test_units_count-1).map do |i|
      Thread.new {
        report['test_units'][params['all_tests'].keys[i]] =
            Object.const_get(params['all_tests'].keys[i]).new(url=params['url'],
                                                              platform=params['platform'],
                                                              browser=params['browser'],
                                                              width=params['width'],
                                                              height=params['height'],
                                                              java_script=params['java_script'],
                                                              params['all_tests'].values[i]).execute_tests
      }
    end
    threads.each {|t| t.join}
    # other static
    units_failed = 0
    report['test_units'].each do |unit_name, unit_data|
      passed = 0
      unit_data['tests'].each do |test_name, test_data|
        if test_data['status'] == 'done'
          passed +=1
        end
      end
      unit_data['passed'] = passed
      unit_data['failed'] = unit_data['total'] - passed
      if unit_data['failed'] != 0
        units_failed +=1
      end
    end
    report['total'] = report['test_units'].length
    report['failed'] = units_failed
    report['passed'] = report['total'] - units_failed
    report['status'] = 'done'
    report['end_time'] = Time.now.to_i
    db.update_report(params['report_id'], report)
  end

end

