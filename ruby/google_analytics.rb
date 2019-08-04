require_relative 'analytics_service_base'

class GoogleAnalytics < AnalyticsServiceBase
  def send_transaction(cid, tr, ti)
    Net::HTTP.post_form(
      URI("http;//www.google-analytics.com/collect"),
      v: '1',
      tid: "sptosit u tolika",
      cid: cid,
      t: 'transaction',
      tr: tr,
      ni: '1', ##????
      ti: ti ##???
    )
  end
end