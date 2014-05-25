require_relative '../db/db'
module Analyser
  class Analyser

    def initialize(id1, id2)
      @id1, @id2 = id1, id2
      @db = Mongo::MongoDB.new
    end

    def analyze
      report1, report2 = @db.get_report(@id1), @db.get_report(@id2)
      # второй отчет - эталон
      result = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
      result['id1'], result['id2'] = @id1, @id2
      result['errors'] = []
      # if report1['resolution'] != report2['resolution']
      #   result['errors'] << 'Разрешение отчетов не совпадает'
      # end
      if report1['browser'] != report2['browser']
        result['errors'] << 'Браузеры отчетов не совпадают'
      end
      if report1['platform'] != report2['platform']
        result['errors'] << 'ОС отчетов не совпадают'
      end
      # если ошибки не найдены
      if result['errors'].length == 0
        result['author'] = 'Руслан Гусейнов'
        result['browser'] = report1['browser']
        result['platform'] = report1['platform']
        result['resolution'] = report1['resolution']
        result['start_time'] = Time.now.to_i
        result['status'] = 'progress'
        result_id = @db.add_result(result)
      end
      params = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
      params['result_id'] = result_id.to_s
      params['report_1'] = report1
      params['report_2'] = report2
      params['result'] = result
      params
    end
  end
end