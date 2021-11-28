require 'pg'

conn = PG.connect(:dbname => 'task_1', :password => 'admin', :port => 5432, :user => 'postgres')

conn.exec(
    'DROP TABLE IF EXISTS offices, zones, rooms, fixtures, marketing_materials cascade;'
)