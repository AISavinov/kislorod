

class LastParseDateHandler

  def initialize
    @current_parse_date = current_date
    @last_parse_date = get_last_parse_date ##проверить на пустую строку
  end

  def write_last_parse_date
    File.open('last_parse_date', 'w') { |f| f.write(@current_parse_date) }
  end

  private

  def get_current_date
    Time.now.to_i + 10_800
  end

  def get_last_parse_date    ## не работает при несуществующем файле
    File.open("my/file/path", "r") do |f|
      f.each_line do |line|
        line
      end
    end
  end
end
