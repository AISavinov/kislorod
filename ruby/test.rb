# frozen_string_literal: true

require_relative 'api_requester'
require_relative 'date_handler'
require_relative 'response_handler'
require_relative 'google_analytics'
require_relative 'roi_stat'

date_handler = DateHandler.new
response = ApiRequester.new.get_orders(date_handler.last_parse_date - 10_080, date_handler.current_parse_date, 'created')
response_handler = ResponseHandler.new(response)
p response_handler.count
res = response_handler.leads.map do |l|
  customer = l['customer']
  customer['roistat_first_visit']
end
# #рассылание данных по апишкам
