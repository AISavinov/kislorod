# frozen_string_literal: true

require 'logger'

class Plarin
  def initialize
    @logger = Logger.new('plarin_log')
  end

  def send(ad_id, payment)
    if ad_id.nil? || payment.nil?
      @logger.error('Could not send lead: ' + ad_id.to_s + payment.to_s)
    else
      response = Net::HTTP.post_form(
        URI('https://postback.plarin.net/3vHX5BwbYPJrtN58raW3ceD7'),
        g10: ad_id,
        g10_value: payment
      ).body
      @logger.info("Send lead with utm_content:#{ad_id}, cost: payment\n#{response}")
    end
  end
end
