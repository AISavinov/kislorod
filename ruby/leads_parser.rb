# frozen_string_literal: true

require 'json'

class LeadsParser
  attr_accessor :parsed_leads
  ##TODO: make parsed result with needed data for analytics handlers
  #TODO: make order id from options json, example of json:
  #{"rooms"=>"2", "bathrooms"=>"1", "kitchen"=>"1", "hall"=>"1", "dish_washing"=>"0", "refregerator"=>"0", "microwave_oven"=>"0", "oven"=>"0", "balconies"=>"0", "cupboard"=>"0", "ironing"=>"0", "windows"=>"0"}
  def initialize(leads)
    leads.each do |lead|
      customer = lead['customer']
      cleaner = lead['cleaner']
      @phone = lead['phone']
      @unix_created_at = lead['created_at']
      @subbed_created_at = @unix_created_at.sub(' ', '_')
      @cost = lead['cost']
      @ti = [@created_at, @phone, @cost].compact.join('_') # #trans_indif TODO: подумать,что выбрать для id
      @cleaner_name = ###????TODO
      # if cleaner.size <= 1
      #   cleaner = cleaner.first
      #   @cleaner_name = ['cleaner', cleaner['first_name'], cleaner['last_name'], cleaner['phone']].compact.join('_')
      # end
      @status = lead['status']
      @customer_first_name = customer['first_name']
      @user_id = if (u = [@customer_first_name, @phone].compact.join('_')).empty?
                   nil
                 else
                   u
      end
      @roi_id = '100002' # #customer['roistat_first_visit']
      @tr = lead['cost'] # #доход
      @lead_id = [@created_at, @phone, @cost, @customer_first_name].compact.join('_') # #trans_indif TODO: подумать,что выбрать для id
    end
  end
end
