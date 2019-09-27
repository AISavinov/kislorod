# frozen_string_literal: true

require_relative 'api_requester'
require_relative 'date_handler'
require_relative 'response_handler'
require_relative 'google_analytics'
require_relative 'roi_stat'
require_relative 'leads_parser'
require_relative 'database_handler'
require_relative 'plarin'

begin
  db = DatabaseHandler.new
  date_handler = DateHandler.new
  last_parse_date = if !(lpd = db.get_last_parse_date).empty?
                      lpd.flatten.first.to_i
                    else
                      date_handler.current_parse_date
  end
  response = ApiRequester.new.get_orders(last_parse_date, date_handler.current_parse_date, 'changed')
  response_handler = ResponseHandler.new(response)
  logger = Logger.new('stdout')
  logger.info("Started job; kislorod api succeed response: #{response_handler.is_success_response}")
  if response_handler.is_success_response
    ga = GoogleAnalytics.new
    roi = RoiStat.new
    parser = LeadsParser.new
    plarin = Plarin.new
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
          if parser.lead_status == 'paid'
            ga.send_transaction(parser) if !parser.ga_id.nil? && parser.ga_id != '' ## dont know why we have to accert it
            utm = roi.get_utm_content(parser.lead_id)
            plarin.send(utm, parser.cost) unless utm.nil?
          end
        else
          db.write_undefind_user(user_id) unless db.undefind_user_already_exists(user_id)
          logger.error("No ga or ym or roi id in user info in lead with id: #{parser.lead_id}")
        end
      end
      roi.send_roistat
    end
    db.write_parse_date(date_handler.current_parse_date)
    logger.info("Succeed at #{date_handler.current_parse_date}")
  end
  db.close
rescue StandardError => e
  logger = Logger.new('stderr')
  logger.error("In initialize:\n" + e.to_s)
end
