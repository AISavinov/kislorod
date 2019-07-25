require 'json'

class ResponseHandler

  def initialize(response)
    @response = JSON.parse(response)
  end

  def is_success_response
    @response['success']
  end
end