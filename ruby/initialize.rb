# frozen_string_literal: true

require_relative 'api_requester'
require_relative 'date_handler'
require_relative 'response_handler'
require_relative 'google_analytics'
require_relative 'roi_stat'
require_relative 'leads_parser'
require_relative 'database_handler'

db = DatabaseHandler.new
date_handler = DateHandler.new
last_parse_date = if !(lpd = db.get_last_parse_date).empty?
  lpd.flatten.first.to_i
else 
  date_handler.current_parse_date
end
response = ApiRequester.new.get_orders(last_parse_date, date_handler.current_parse_date, 'created') ### TODO: remove 100_000
response_handler = ResponseHandler.new(response)
if response_handler.is_success_response # #и отправилли все данные
  ga = GoogleAnalytics.new
  roi = RoiStat.new
  parser = LeadsParser.new
  unless response_handler.count.zero?
    response_handler.leads.each do |lead|
      next unless lead['customer'].is_a? Hash
      parser.parse(lead)
      user_id = parser.user_id
      roi_id = parser.roi_id
      ga_id = parser.ga_id
      ym_id = parser.ym_id
      if roi_id && ga_id && ym_id
        roi.collect_bodies(parser)
        ga.send_transaction(parser) if parser.lead_status == 'paid'
        if parser.is_cyclic
          db.write_cyclic_lead_info(user_id, ga_id, ym_id, roi_id) unless db.exists_in_db(user_id)
        end
      elsif db.exists_in_db(user_id)
        p user_id, roi_id, ga_id, ym_id, parser.is_cyclic
        u = db.get_user_by_id(user_id)
        parser.ga_id = u[1]
        parser.ym_id = u[2]
        parser.roi_id = u[3]
        roi.collect_bodies(parser)
        ga.send_transaction(parser) if parser.lead_status == 'paid'
      else
        db.write_undefind_user(user_id) unless db.undefind_user_already_exists(user_id)
      end
    end
    roi.send_roistat
  end
  db.write_parse_date(date_handler.current_parse_date)
  db.close
end

