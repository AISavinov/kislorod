# frozen_string_literal: true

require 'json'

class LeadsParser
  attr_accessor :parsed_leads
  ##TODO: make parsed result with needed data for analytics handlers
  def initialize(lead)
      customer = lead['customer']
      cleaner = lead['cleaner']
      @phone = lead['phone']
      @created_at = lead['created_at']
      @subbed_created_at = @unix_created_at.sub(' ', '_')
      @cost = lead['cost']
      @cleaner_phones = 'cleaner_phones_' + cleaner.map { |c| c['phone'] }.compact.join('_')
      @lead_status = lead['status']
      @customer_first_name = customer['first_name']
      @user_id = if (u = [@customer_first_name, @phone].compact.join('_')).empty?
                   nil
                 else
                   u
      end ####customer['id'] !!!
      @roi_id = '100002' # #customer['roistat_first_visit']
      @lead_id = [@created_at, @phone, @cost, @customer_first_name].compact.join('_')##lead['id'] # #trans_indif TODO: подумать,что выбрать для id
      @lead_name = # take from options
  end
end
