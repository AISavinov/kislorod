require_relative 'ApiRequester.rb'

# to_date = Time.now.to_i + 10_800
# from_date = to_date - 86_400
# date_type = 'created'

ApiRequester.new.get_orders(from_date.to_s, to_date.to_s, date_type)
