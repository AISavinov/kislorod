# frozen_string_literal: true

require_relative 'analytics_service_base'
require 'securerandom'
require 'time'
class RoiStat < AnalyticsServiceBase
  attr_reader :user_body, :lead_body
  def initialize
    @user_body = []
    @lead_body = []
    @project_id = '136717'
    @key = '07bda2e3ed839dcf1dc2cefa18a9963d'
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
