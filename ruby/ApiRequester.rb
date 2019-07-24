require 'net/http'


class ApiRequester

  def initialize
    @api_token = 'db3d7e90af505b851146f0c84891e737'
    @get_orders_url = "http://kislorodlab.sys.it-co.ru/api/get_orders?token=#{@api_token}"
  end

  def get_orders(from, to, date_type)
    puts Net::HTTP.post_form(
      URI(@get_orders_url),
      from: from,
      to: to,
      date_type: date_type
    ).body
  end
end
