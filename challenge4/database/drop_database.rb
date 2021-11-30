require 'pg'

def drop_database(conn) 
    conn.exec(
       'DROP TABLE IF EXISTS offices, zones, rooms, fixtures, marketing_materials cascade;'
    )
end