# frozen_string_literal: true

require 'json'

class LeadsParser
  # #TODO: make parsed result with needed data for analytics handlers
  def initialize(lead)
    customer = lead['customer']
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
    @roi_id = '100002' # #customer['roistat_first_visit']
    @ga_id = 'GA1.2.104555568.1565031104' # #customer['ga_cid']
    @lead_id = lead['id']
    @lead_name = options.map do |k, v|
      k + '-' + v if v.to_i > 0
    end.compact.join('_')
  end
end
