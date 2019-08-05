# frozen_string_literal: true

require 'json'

class ResponseHandler
  attr_accessor :response, :data, :leads, :count
  def initialize(response)
    @response = JSON.parse(response)
    data = @response['data'].first
    @leads = data['leads']
    @count = data['count']
  end

  def is_success_response
    @response['success']
  end
end
