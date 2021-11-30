require_relative 'database/upload_to_database'
require './src/materials_report'

class Main
    def initialize()
        conn = upload()
        MaterialsReport.new(conn)
    end
end

Main.new()