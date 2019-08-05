require_relative 'api_requester'
require_relative 'date_handler'
require_relative 'response_handler'
require_relative 'google_analytics'

date_handler = DateHandler.new
response = ApiRequester.new.get_orders(date_handler.last_parse_date - 40000000, date_handler.current_parse_date, 'cleaning_date')
response_handler = ResponseHandler.new(response)
##рассылание данных по апишкам
if response_handler.is_success_response ##и отправилли все данные
  data = response_handler.response['data'].first
  p data
  ga = GoogleAnalytics.new
  data['leads'].each do |lead|
  	cid = lead['ga_cid']
  	tr = 'created'
  	ti = lead['cost']
    p lead['is_paid']
    ga.send_transaction(cid, tr, ti)
  end if !data['count'].zero?
  date_handler.write_last_parse_date
end
