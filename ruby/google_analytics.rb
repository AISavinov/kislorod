require_relative 'analytics_service_base'

class GoogleAnalytics < AnalyticsServiceBase
  def send_transaction(cid, tr, ti)
    p Net::HTTP.post_form(
      URI("https://www.google-analytics.com/debug/collect"),
      v: '1',
      tid: "sptosit u tolika",
      cid: cid,
      t: 'transaction',
      tr: tr,
      ni: '1', ##????
      ti: ti ##???
    ).body
  end
end
