# frozen_string_literal: true

require_relative 'api_requester'
require_relative 'date_handler'
require_relative 'response_handler'
require_relative 'google_analytics'

date_handler = DateHandler.new
response = ApiRequester.new.get_orders(date_handler.last_parse_date - 2_600_000, date_handler.current_parse_date, 'created')
response_handler = ResponseHandler.new(response)
# #рассылание данных по апишкам
if response_handler.is_success_response # #и отправилли все данные
  ga = GoogleAnalytics.new
  unless response_handler.count.zero?
    response_handler.leads.each do |lead|
      next unless lead['status'] == 'paid'

      cid = 'GA1.2.104555568.1565031104' # #lead['ga_cid']
      tr = lead['cost'] # #доход
      ti = lead['created_at'] + (lead['phone'] || '') + (lead['cost'] || '') # #trans_indif
      ga.send_transaction(cid, tr, ti)
    end
  end
  date_handler.write_last_parse_date
end
