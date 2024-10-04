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
  
  @logger = Logger.new

  def self.pool
    @pool
  end

  def self.logger
    @logger
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
    query = "INSERT INTO #{table_name} (#{columns}) VALUES (#{values}) RETURNING *"
    begin
      result = execute(query)
      result.first
    rescue PG::Error => e
      @logger.log('Database', "Error inserting into table #{table_name}: #{e.message}")
    end
  end

  def self.get_one_element_from_table(table_name, conditions)
    where_clauses = conditions.map { |column, value| "#{column} = '#{value}'" }.join(' AND ')
    query = "SELECT * FROM #{table_name} WHERE #{where_clauses}"
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
      @logger.log('Database', "Error updating table #{table_name}: #{e.message}")
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

end
