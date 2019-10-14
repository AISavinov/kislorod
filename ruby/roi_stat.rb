# frozen_string_literal: true

require_relative 'analytics_service_base'
require 'securerandom'
require 'time'
require 'openssl'
class RoiStat < AnalyticsServiceBase
  attr_reader :user_body, :lead_body
  def initialize
    @user_body = []
    @lead_body = []
    @project_id = '139716'
    @key = 'b167f04eccd8b81d9cd58078fe33af06'
    @statuses = [
      {
        "id": '1',
        "roi": 'progress',
        "lead_status": 'pending'
      },
      {
        "id": '2',
        "roi": 'progress',
        "lead_status": 'assigned'
      },
      {
        "id": '3',
        "roi": 'progress',
        "lead_status": 'active'
      },
      {
        "id": '4',
        "roi": 'progress',
        "lead_status": 'finished'
      },
      {
        "id": '5',
        "roi": 'paid',
        "lead_status": 'paid'
      },
      {
        "id": '6',
        "roi": 'canceled',
        "lead_status": 'deleted'
      }
    ]
    @logger = Logger.new('roi_log')
  end

  def get_utm_content(lead_id) # #TODO: get utm content not for one lead but for all needed leads by one request
    parsed_response = get_roi_order(lead_id)
    status = parsed_response['status']
    if status == 'error' && parsed_response['error'] == 'request_limit_error'
      sleep(10)
      get_utm_content(lead_id)
    elsif status != 'success'
      @logger.error("Could not get utm content from roi with roi id: #{lead_id}\n#{parsed_response}")
      nil
    elsif parsed_response['data'].size != 1
      @logger.error("Two more or no leads with id while getting utm content: #{lead_id}\n#{parsed_response}")
      nil
    else
      data = parsed_response['data'].first
      visit = data['visit']
      unless visit.nil?
        utm = visit['utm_content']
        @logger.info("Got lead with utm content: #{utm}") unless utm.nil?
        utm
      end

    end
  end

  def get_roi_order(lead_id)
    url = URI("https://cloud.roistat.com/api/v1/project/integration/order/list?key=#{@key}&project=#{@project_id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request['content-type'] = 'application/json'
    request.body = "{\"filters\":[{\"field\":\"id\",\"operator\":\"=\",\"value\":\"#{lead_id}\"}],\"extend\":[\"visit\"]}"
    response = http.request(request)
    JSON.parse(response.read_body)
  end

  def send_users
    url = URI("https://cloud.roistat.com/api/v1/project/clients/import?key=#{@key}&project=#{@project_id}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request['content-type'] = 'application/json'
    request.body = create_users_body
    response = http.request(request)
    @logger.info("Roi users response:\n" + response.read_body)
  end

  def send_leads
    url = URI("https://cloud.roistat.com/api/v1/project/add-orders?key=#{@key}&project=#{@project_id}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request['content-type'] = 'application/json'
    body = create_leads_body
    request.body = body
    response = http.request(request)
    @logger.info("Roi leads response:\n" + response.read_body)
  end

  def create_users_body
    create_body(@user_body)
  end

  def create_leads_body
    create_body(@lead_body)
  end

  def create_body(body)
    '[' + body.join(',') + ']'
  end

  def send_roistat
    @logger.info("User body:\n" + @user_body.to_s)
    send_users
    @logger.info("Leads body:\n" + @lead_body.to_s)
    send_leads
  end

  def collect_bodies(parsed_lead)
    @user_body.append("{\"id\":\"#{parsed_lead.user_id}\",\"name\":\"#{parsed_lead.customer_first_name}\",\"phone\":\"#{parsed_lead.phone}\"}")
    roi_status = if (st = @statuses.find { |s| s[:lead_status] == parsed_lead.lead_status })
                   st[:id]
                 end
    @lead_body.append("{\"id\":\"#{parsed_lead.lead_id}\"," \
          "\"name\":\"#{parsed_lead.lead_name}\"," \
          "\"date_create\":\"#{Time.parse(parsed_lead.created_at).to_i}\"," \
          "\"status\":\"#{roi_status}\"," \
          "\"roistat\":\"#{parsed_lead.roi_id}\"," \
          "\"price\":\"#{parsed_lead.cost}\"," \
          '"cost":"0",' \
          "\"client_id\":\"#{parsed_lead.user_id}\"," \
          "\"fields\":{\"cleaner\":\"#{parsed_lead.cleaner_phones}\"}}")
        end
end
