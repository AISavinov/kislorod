# frozen_string_literal: true

require_relative 'analytics_service_base'

class GoogleAnalytics < AnalyticsServiceBase
  attr_accessor :cid, :tr, :ti

  def send_transaction(lead)
    get_data_from_lead(lead)
    Net::HTTP.post_form(
      URI('https://www.google-analytics.com/debug/collect'),
      v: '1',
      tid: 'UA-144825607-1',
      cid: @cid,
      t: 'transaction',
      tr: @tr,
      ni: '1', # #????
      ti: @ti # #???
    ).body
  end

  def get_data_from_lead(lead)
    customer = lead['customer']
    @cid = 'GA1.2.104555568.1565031104' # #customer['ga_cid']
    @tr = lead['cost'] # #доход
    @ti = lead['created_at'].sub(' ', '_') + '_' + (customer['phone'] || '') + '_' + (lead['cost'] || '') # #trans_indif TODO: подумать,что выбрать для id
  end
end
