require_relative 'database/upload_to_database'
require './src/fixtures_report'

class Main
    def initialize()
        conn = upload()
        FixturesReport.new(conn)
    end
end

Main.new()