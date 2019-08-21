# frozen_string_literal: true

require_relative 'analytics_service_base'

class GoogleAnalytics < AnalyticsServiceBase
  attr_accessor :tid, :ti, :tr, :cid, :phone, :created_at, :cost

  def initialize
    @tid = 'UA-144825607-1'
  end

  def send_transaction(lead)
    get_data_from_lead(lead)
    ga_id = lead.ga_id
    cost = lead.cost
    lead_id = lead.lead_id
    p Net::HTTP.post_form(
      URI('http://www.google-analytics.com/collect'),
      v: '1',
      tid: @tid,
      cid: ga_id,
      t: 'transaction',
      tr: cost,
      ni: '1',
      ti: lead_id
    ).body
    p Net::HTTP.post_form(
      URI('http://www.google-analytics.com/collect'),
      v: '1',
      tid: @tid,
      cid: ga_id,
      t: 'item',
      tr: cost,
      ni: '1',
      ti: lead_id,
      iq: '1',
      ip: cost,
      in: lead.lead_name,
      ic: 'order'
    ).body
  end
end
