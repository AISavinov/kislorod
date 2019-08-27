# frozen_string_literal: true

require 'json'

class LeadsParser
  attr_accessor :is_cyclic, :ym_id, :phone, :created_at, :subbed_created_at, :cost, :cleaner_phones, :lead_status, :customer_first_name, :user_id, :roi_id, :ga_id, :lead_id, :lead_name
  # #TODO: make parsed result with needed data for analytics handlers
  def parse(lead)
    customer = if true
      puts 'S___________________________________________S'
      puts lead##lead['customer']
      puts 'E___________________________________________E'
      lead['customer']
    end
    cleaner = lead['cleaner']
    options = lead['options']
    @phone = lead['phone']
    @created_at = lead['created_at']
    @subbed_created_at = @created_at.sub(' ', '_')
    @cost = lead['cost']
    phones = if cleaner.is_a? Array
               cleaner.map { |c| c['phone'] }.compact.join('_')
             elsif cleaner.is_a? Hash
               cleaner['phone']
             else
               ''
    end
    @cleaner_phones = 'cleaner_phones_' + phones
    @lead_status = lead['status']
    @customer_first_name = customer['first_name']
    @user_id = customer['id']
    @roi_id = customer['roistat_first_visit']
    @ga_id = customer['ga_cid']
    @ym_id = customer['ym_id']
    @lead_id = lead['id']
    @lead_name = options.map do |k, v|
      k + '-' + v if v.to_i > 0
    end.compact.join(';')
    @is_cyclic = lead['period_type'] != 'once'
  end
end
