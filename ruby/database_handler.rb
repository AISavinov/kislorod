# frozen_string_literal: true

class DatabaseHandler
  attr_accessor :db

  def initialize
    @db = SQLite3::Database.new ':db:'
    @db.execute "CREATE TABLE IF NOT EXISTS cyclic_leads(CUSTOMER_ID TEXT PRIMARY KEY, GA_CID TEXT, YM_ID TEXT, ROI_ID TEXT)"
    @db.execute 'CREATE TABLE IF NOT EXISTS parse_date(DATE TEXT PRIMARY KEY, CREATED_AT DEFAULT CURRENT_TIMESTAMP)'
    @db.execute 'CREATE TABLE IF NOT EXISTS undefind_users(USER_ID TEXT PRIMARY KEY, CREATED_AT DEFAULT CURRENT_TIMESTAMP)'
  end

  def write_cyclic_lead_info(customer_id, ga_cid, ym_id, roi_id)
    @db.execute "INSERT INTO cyclic_leads VALUES('#{customer_id.to_s}','#{ga_cid}','#{ym_id}','#{roi_id}')"
  rescue SQLite3::Exception => e
    # puts 'Exception occurred' # #TODO: LOG IT
    # puts '_______________________________'
    # puts customer_id.class, ga_cid.class, ym_id.class, roi_id.class
    # puts '_______________________________'
  end

  def write_parse_date(date)
    @db.execute "INSERT INTO parse_date VALUES('#{date}',DATE('now'))"
  rescue SQLite3::Exception => e
    # puts 'Exception occurred' # #TODO: LOG IT
    #     puts '_______________________________'
    # puts date
    #     puts '_______________________________'
  end

  def get_last_parse_date
    @db.execute('SELECT * FROM parse_date ORDER BY CREATED_AT LIMIT 1')
  end

  def exists_in_db(customer_id)
    !get_user_by_id(customer_id).empty?
  end

  def get_user_by_id(customer_id)
    @db.execute("SELECT * FROM cyclic_leads cl WHERE cl.CUSTOMER_ID LIKE #{customer_id}")
  end

  def write_undefind_user(user_id)
    @db.execute "INSERT INTO undefind_users VALUES('#{user_id}',DATE('now'))"
          rescue SQLite3::Exception => e
    # puts 'Exception occurred' # #TODO: LOG IT
    #     puts '_______________________________'
    # puts e, user_id
    #     puts '_______________________________'
  end

  def undefind_user_already_exists(user_id)
    !@db.execute("SELECT * FROM undefind_users us WHERE us.USER_ID LIKE #{user_id}").empty?
  end

  def close
    @db.close
  end
end

# cyclic_leads_log.execute "INSERT INTO cyclic_leads VALUES(123, 34234, 13241234, 12341234)"
# cyclic_leads_log.execute "SELECT * FROM cyclic_leads cl WHERE cl.ID LIKE 123"
