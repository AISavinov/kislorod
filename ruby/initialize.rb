require_relative 'api_requester'
require_relative 'date_handler'
require_relative 'response_handler'


date_handler = DateHandler.new
response = ApiRequester.new.get_orders(date_handler.last_parse_date, date_handler.current_parse_date, 'created')
response_handler = ResponseHandler.new(response)
##рассылание данных по апишкам
if response_handler.is_success_response ##и отправилли все данные
  date_handler.write_last_parse_date
end