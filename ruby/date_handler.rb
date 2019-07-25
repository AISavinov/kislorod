
class DateHandler
  attr_reader :current_parse_date, :last_parse_date

  def initialize
    @current_parse_date = get_current_date  ## Записывать в логи о том,что была потерена последняя дата парса
    @last_parse_date = get_last_parse_date || @current_parse_date - 43_200
    @parse_date_file_name = 'last_parse_date'
  end

  def write_last_parse_date
    File.open('last_parse_date', 'w') { |f| f.write(@current_parse_date) } ## хранить в логах вссе даты парсинга
  end

  private

  def get_current_date
    Time.now.to_i + 10_800
  end

  def get_last_parse_date   
    file = File.open('last_parse_date', 'r') { |f| f.readline if f.size!= 0 }.chomp.to_i if File.exist?('last_parse_date') 
    if file.nil? || file.zero? 
      nil
    else
      file
    end
  end
end
