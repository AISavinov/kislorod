# frozen_string_literal: true

require_relative 'analytics_service_base'
require 'securerandom'
require 'time'
class RoiStat < AnalyticsServiceBase
  def initialize
    @user_body = []
    @lead_body = []
    @project_id = '129403'
    @key = '5ddaf5cff35c9ffb2454485905f37ccd'
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
  end

  def send_users
    url = URI("https://cloud.roistat.com/api/v1/project/clients/import?key=#{@key}&project=#{@project_id}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request['content-type'] = 'application/json'
    request.body = create_users_body ## что делать если phone = nil???
    response = http.request(request)
    puts response.read_body
  end

  def send_leads
    url = URI("https://cloud.roistat.com/api/v1/project/add-orders?key=#{@key}&project=#{@project_id}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request['content-type'] = 'application/json'
    body = create_leads_body ## не кидать если больше одного клинера
    request.body = body
    response = http.request(request)
    puts response.read_body
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
    send_users
    send_leads
  end

  def get_data_from_lead(lead)
    customer = lead['customer']
    cleaner = lead['cleaner']
    if cleaner.size > 1
      nil
    else
      cleaner = cleaner.first
      @cleaner_name = ['cleaner', cleaner['first_name'], cleaner['last_name'], cleaner['phone']].compact.join('_')
    end
    @status = lead['status']
    @cost = lead['cost']
    @date_create = lead['created_at']
    @created_at = @date_create.sub(' ', '_')
    @phone = customer['phone']
    @name = customer['first_name']
    @user_id = if (u = [@name, @phone].compact.join('_')).empty?
                 nil
               else
                 u
    end
    @roi_id = '100002' # #customer['roistat_first_visit']
    @tr = lead['cost'] # #доход
    @lead_id = [@created_at, @phone, @cost, @name].compact.join('_') # #trans_indif TODO: подумать,что выбрать для id
  end

  def collect_bodies(lead)
    get_data_from_lead(lead)
    p @user_body.append("{\"id\":\"#{@user_id}\",\"name\":\"#{@name}\",\"phone\":\"#{@phone}\"}")
    roi_status = if (st = @statuses.find { |s| s[:lead_status] == @status })
                   st[:id]
                 end
    p @lead_body.append("{\"id\":\"#{@lead_id}\"," \
          "\"name\":\"#{[@user_id, @cost, @created_at].compact.join('_')}\"," \
          "\"date_create\":\"#{Time.parse(@date_create).to_i}\"," \
          "\"status\":\"#{roi_status}\"," \
          "\"roistat\":\"#{@roi_id}\"," \
          "\"price\":\"#{@cost}\"," \
          '"cost":"0",' \
          "\"client_id\":\"#{@user_id}\"," \
          "\"fields\":{\"cleaner\":\"#{@cleaner_name}\"}}")
  end
end
