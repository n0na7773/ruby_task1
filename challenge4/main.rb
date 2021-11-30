require_relative 'database/upload_to_database'
require './src/states_report'

class Main
    def initialize()
        conn = upload()
        StatesReport.new(conn)
    end
end

Main.new()