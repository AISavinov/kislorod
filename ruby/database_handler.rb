# frozen_string_literal: true

require 'logger'

class DatabaseHandler
  attr_accessor :db

  def initialize
    @db = SQLite3::Database.new ':db:'
    @db.execute 'CREATE TABLE IF NOT EXISTS cyclic_leads(CUSTOMER_ID TEXT PRIMARY KEY, GA_CID TEXT, YM_ID TEXT, ROI_ID TEXT)'
    @db.execute 'CREATE TABLE IF NOT EXISTS parse_date(DATE TEXT PRIMARY KEY, CREATED_AT DEFAULT CURRENT_TIMESTAMP)'
    @db.execute 'CREATE TABLE IF NOT EXISTS undefind_users(USER_ID TEXT PRIMARY KEY, CREATED_AT DEFAULT CURRENT_TIMESTAMP)'
    @error_logger = Logger.new('stderr')
    @info_logger = Logger.new('stdout')
  end

  def write_cyclic_lead_info(customer_id, ga_cid, ym_id, roi_id)
    @db.execute "INSERT INTO cyclic_leads VALUES('#{customer_id}','#{ga_cid}','#{ym_id}','#{roi_id}')"
  rescue SQLite3::Exception => e
    @error_logger.error(e + "\n with input id: #{user_id}, ga_cid: #{ga_cid}, ym_id: #{ym_id}, roi_id: #{roi_id}")
  else
    @info_logger.info("inserted cyclic_lead_info id: #{customer_id}, ga_cid: #{ga_cid}, ym_id: #{ym_id}, roi_id: #{roi_id}")
  end

  def write_parse_date(date)
    @db.execute "INSERT INTO parse_date VALUES('#{date}',DATE('now'))"
  rescue SQLite3::Exception => e
    @error_logger.error(e + "\n with input date: #{date}")
  else
    @info_logger.info("inserted date: #{date}")
  end

  def get_last_parse_date
    @db.execute('SELECT * FROM parse_date ORDER BY CREATED_AT DESC LIMIT 1')
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
    @error_logger.error(e + "\n with input user_id: #{user_id}")
  else
    @info_logger.info("inserted undefined_user id: #{user_id}")
  end

  def undefind_user_already_exists(user_id)
    !@db.execute("SELECT * FROM undefind_users us WHERE us.USER_ID LIKE #{user_id}").empty?
  end

  def close
    @db.close
  end
end
