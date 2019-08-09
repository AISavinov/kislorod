# frozen_string_literal: true

require_relative 'api_requester'
require_relative 'date_handler'
require_relative 'response_handler'
require_relative 'google_analytics'
require_relative 'roi_stat'

date_handler = DateHandler.new
response = ApiRequester.new.get_orders(date_handler.last_parse_date - 100_000, date_handler.current_parse_date, 'created') ### TODO: remove 100_000
response_handler = ResponseHandler.new(response)
p response_handler.leads
# #рассылание данных по апишкам
if response_handler.is_success_response # #и отправилли все данные
  ga = GoogleAnalytics.new
  roi = RoiStat.new
  unless response_handler.count.zero?
    # response_handler.leads.each do |lead|
    #   lead
    #   roi.collect_bodies(lead)
    # end
    # roi.send_roistat
    # response_handler.leads.each do |lead|
    #   next unless lead['status'] == 'paid'
    #
    #   ga.send_transaction(lead)
    # end
  end
  date_handler.write_last_parse_date
end
