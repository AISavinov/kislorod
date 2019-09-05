# frozen_string_literal: true

require 'sqlite3'

class DateHandler
  attr_reader :current_parse_date, :last_parse_date

  def initialize
    @current_parse_date = get_current_date
  end

  private

  def get_current_date
    Time.now.to_i
  end
end
