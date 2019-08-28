# frozen_string_literal: true

require_relative 'analytics_service_base'
require 'logger'

class GoogleAnalytics < AnalyticsServiceBase
  attr_accessor :tid, :ti, :tr, :cid, :phone, :created_at, :cost

  def initialize
    @tid = 'UA-144825607-1'
    @logger = Logger.new('ga_log')
  end

  def send_transaction(lead)
    ga_id = lead.ga_id
    cost = lead.cost
    lead_id = lead.lead_id
    lead_name = lead.lead_name
    Net::HTTP.post_form(
      URI('http://www.google-analytics.com/collect'),
      v: '1',
      tid: @tid,
      cid: ga_id,
      t: 'transaction',
      tr: cost,
      ni: '1',
      ti: lead_id
    )
    @logger.info("Send transaction:\nga_id: #{ga_id},\nlead_id: #{lead_id},\ncost: #{cost},\nin,ic: #{lead_name}")
    Net::HTTP.post_form(
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
      in: lead_name,
      ic: lead_name
    )
    @logger.info("Send item:\nga_id: #{ga_id},\nlead_id: #{lead_id},\ncost: #{cost},\nin,ic: #{lead_name}")
  end
end
