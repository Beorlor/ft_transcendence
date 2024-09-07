db_config = {
  adapter: 'postgresql',
  encoding: 'unicode',
  pool: 5,
  timeout: 5000,
  database: ENV['POSTGRES_DB'],
  username: ENV['POSTGRES_USER'],
  password: ENV['POSTGRES_PASSWORD'],
  host: 'postgres'
}
