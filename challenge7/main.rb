require_relative 'database/upload_to_database'
require './src/installation_report'

class Main
    def initialize()
        conn = upload()
        InstallationReport.new(conn)
    end
end

Main.new()