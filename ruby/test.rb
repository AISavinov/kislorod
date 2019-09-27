# frozen_string_literal: true

require_relative 'api_requester'
require_relative 'date_handler'
require_relative 'response_handler'
require_relative 'google_analytics'
require_relative 'roi_stat'
require 'logger'

date_handler = DateHandler.new
response = ApiRequester.new.get_orders(date_handler.current_parse_date - 10_000, date_handler.current_parse_date, 'created')
response_handler = ResponseHandler.new(response)
p response_handler.leads
# res = response_handler.leads.map do |l|
#   customer = l['customer']
#   customer['roistat_first_visit']
# end
# # #рассылание данных по апишкам

# #TODO: make parsed result with needed data for analytics handlers
# TODO: make order id from options json, example of json:
# {"rooms"=>"2", "bathrooms"=>"1", "kitchen"=>"1", "hall"=>"1", "dish_washing"=>"0", "refregerator"=>"0", "microwave_oven"=>"0", "oven"=>"0", "balconies"=>"0", "cupboard"=>"0", "ironing"=>"0", "windows"=>"0"}

# def initialize(leads)
#  leads.each do |lead|
#    customer = lead['customer']
#    cleaner = lead['cleaner']
#    @phone = lead['phone']
#    @unix_created_at = lead['created_at']
#    @subbed_created_at = @unix_created_at.sub(' ', '_')
#    @cost = lead['cost']
#    @ti = [@created_at, @phone, @cost].compact.join('_') # #trans_indif TODO: подумать,что выбрать для id
#    @cleaner_name = ###????TODO

# options =  lead[:options]
# options.map do |k,v|
#   if v.to_i > 0
#    k + '-' + v
#   end
# end.compact.join('_')

# log = Logger.new('stdout')
# log.debug("Created Logger")
# log.info("Program finished")
