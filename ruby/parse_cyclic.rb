# frozen_string_literal: true

require_relative 'api_requester'
require_relative 'date_handler'
require_relative 'response_handler'
require_relative 'leads_parser'
require_relative 'database_handler'

db = DatabaseHandler.new
date_handler = DateHandler.new
parser = LeadsParser.new
response = ApiRequester.new.get_orders(10_000, date_handler.current_parse_date, 'created')
response_handler = ResponseHandler.new(response)
if response_handler.is_success_response # #и отправилли все данные
  unless response_handler.count.zero?
    response_handler.leads.each do |lead|
      next unless lead['customer'].is_a? Hash

      parser.parse(lead)
      user_id = parser.user_id
      roi_id = parser.roi_id
      ga_id = parser.ga_id
      ym_id = parser.ym_id
      if roi_id && ga_id && ym_id
        if parser.is_cyclic
          db.write_cyclic_lead_info(user_id, ga_id, ym_id, roi_id) unless db.exists_in_db(user_id)
        end
      elsif !db.exists_in_db(user_id)
        db.write_undefind_user(user_id) unless db.undefind_user_already_exists(user_id)
      end
    end
  end
end
db.close
