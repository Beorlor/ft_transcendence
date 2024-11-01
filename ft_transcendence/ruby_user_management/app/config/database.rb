require 'pg'
require 'connection_pool'

class Database
  @pool = ConnectionPool.new(size: 5, timeout: 5) do
    PG.connect(
      dbname: ENV['POSTGRES_DB'],
      user: ENV['POSTGRES_USER'],
      password: ENV['POSTGRES_PASSWORD'],
      host: 'postgres',
      port: 5432
    )
  end

  def self.pool
    @pool
  end

  def self.execute(query)
    pool.with do |conn|
      conn.exec(query)
    end
  end

  def self.get_all_from_table(table_name)
    query = "SELECT * FROM #{table_name}"
    result = execute(query)
    result.map { |row| row }
  end

  def self.insert_into_table(table_name, data)
    columns = data.keys.join(", ")
    values = data.values.map { |value| "'#{value}'" }.join(", ")
    query = "INSERT INTO #{table_name} (#{columns}) VALUES (#{values})"
    begin
      execute(query)
    rescue PG::Error => e
      puts("Error inserting into table #{table_name}: #{e.message}")
    end
  end

  def self.get_one_element_from_table(table_name, or_conditions = {}, and_conditions = {})
    or_where_clauses = or_conditions.map { |column, value| "#{column} = '#{value}'" }.join(' OR ') unless or_conditions.empty?
    and_where_clauses = and_conditions.map { |column, value| "#{column} = '#{value}'" }.join(' AND ') unless and_conditions.empty?
    
    where_clauses = []
    where_clauses << "(#{or_where_clauses})" if or_where_clauses
    where_clauses << and_where_clauses if and_where_clauses

    query = "SELECT * FROM #{table_name} WHERE #{where_clauses.join(' AND ')}"
    result = execute(query)
    result.map { |row| row }
  end

  def self.update_table(table_name, data, where_clause)
    set_clause = data.map { |key, value| "#{key} = '#{value}'" }.join(", ")
    query = "UPDATE #{table_name} SET #{set_clause} WHERE #{where_clause}"
    begin
      execute(query)
      true
    rescue PG::Error => e
      Logger.new.log('Database', "Error updating table #{table_name}: #{e.message}")
      false
    end
  end

  def self.get_paginated_element_from_table(table_name, page, per_page, order=nil)
    page = page.to_i
    offset = (page - 1) * per_page
    query = "SELECT * FROM #{table_name} "
    if order
      query += "ORDER BY #{order} "
    end
    query += "LIMIT #{per_page} OFFSET #{offset}"
    result = execute(query)
    result.map { |row| row }
  end

  def self.get_friendship_plus_information(user_id)
    query = <<-SQL
      SELECT 
        f.id AS friendship_id,
        f.status,
        f.created_at AS friendship_created_at,
        requester.id AS requester_id,
        requester.username AS requester_username,
        receiver.id AS receiver_id,
        receiver.username AS receiver_username
      FROM 
        _friendship AS f
      JOIN 
        _user AS requester ON f.requester_id = requester.id
      JOIN 
        _user AS receiver ON f.receiver_id = receiver.id
      WHERE 
        f.requester_id = $1 OR f.receiver_id = $1;
    SQL

    result = pool.with { |conn| conn.exec_params(query, [user_id]) }
    result.map do |row|
      {
        friendship_id: row["friendship_id"],
        status: row["status"],
        friendship_created_at: row["friendship_created_at"],
        requester_id: row["requester_id"],
        requester_username: row["requester_username"],
        receiver_id: row["receiver_id"],
        receiver_username: row["receiver_username"]
      }
    end
  end
end