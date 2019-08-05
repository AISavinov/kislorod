require 'json'

class ResponseHandler
  attr_accessor :response
  def initialize(response)
    @response = JSON.parse(response)
  end

  def is_success_response
    @response['success']
  end
end
