require_relative 'database/drop_database'
require_relative 'database/create_database'
require_relative 'decompose'
require 'csv'

def upload()
    conn = PG.connect(:dbname => 'task_1', :password => 'admin', :port => 5432, :user => 'postgres')
    input = CSV.read("./data.csv", headers: true)
    drop_database(conn)
    create_database(conn)
    decompose(input, conn)
end

upload()