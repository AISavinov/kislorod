# frozen_string_literal: true

require_relative 'analytics_service_base'

class GoogleAnalytics < AnalyticsServiceBase
  attr_accessor :tid, :ti, :tr, :cid, :phone, :created_at, :cost

  def send_transaction(lead)
    get_data_from_lead(lead)
    p @tid, @ti, @tr, @cid, @phone, @created_at
    p Net::HTTP.post_form(
      URI('http://www.google-analytics.com/collect'),
      v: '1',
      tid: @tid,
      cid: @cid,
      t: 'transaction',
      tr: @tr,
      ni: '1', # #????
      ti: @ti # #???
    ).body
    p Net::HTTP.post_form(
      URI('http://www.google-analytics.com/collect'),
      v: '1',
      tid: @tid,
      cid: @cid,
      t: 'item',
      tr: @tr,
      ni: '1', # #????
      ti: @ti, # #???
      iq: '1',
      ip: @cost,
      in: @ti,
      ic: 'order'
    ).body
  end

  def get_data_from_lead(lead)
    customer = lead['customer']
    @created_at = lead['created_at'].sub(' ', '_')
    @phone = customer['phone']
    @cost = lead['cost']
    @cid = 'GA1.2.104555568.1565031104' # #customer['ga_cid']
    @tr = @cost # #доход
    # #[@created_at, @phone, @cost, @name].compact.join('_')
    @ti = [@created_at, @phone, @cost].compact.join('_') # #trans_indif TODO: подумать,что выбрать для id
    @tid = 'UA-144825607-1'
  end
end
