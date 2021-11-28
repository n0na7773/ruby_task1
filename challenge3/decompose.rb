def upload_offices(file, conn)
    file.each do |row|
        data = {
            title: row['Office'].gsub('\'', '\\\''),
            address: row['Office address'].gsub('\'', '\\\''),
            city: row['Office city'],
            state: row['Office State'],
            phone: row['Office phone'],
            lob: row['Office lob'],
            type: row['Office type']
        }

        conn.exec(
            "INSERT INTO offices(title, address, city, state, phone, lob, type)
            VALUES('#{data[:title]}', '#{data[:address]}', '#{data[:city]}', '#{data[:state]}', '#{data[:phone]}', '#{data[:lob]}', '#{data[:type]}')
            ON CONFLICT(title) DO NOTHING;"
        )
    end

end

def upload_zones(file, conn)
    file.each do |row|
        data = { 
            name: row['Zone'].gsub('\'', '\\\'')
        }
  
        office_title = row['Office'].gsub('\'', '\\\'')
        data[:office_id] = conn.exec("SELECT (id) from offices WHERE title='#{office_title}'").getvalue(0, 0)
        is_unique = conn.exec("SELECT COUNT(*) from zones WHERE office_id=#{data[:office_id]} AND name='#{data[:name]}'").getvalue(0, 0)

        if(Integer(is_unique) == 0)
            conn.exec("INSERT INTO zones(name, office_id)
            VALUES('#{data[:name]}', '#{data[:office_id]}')")
        end
      end
end

def upload_rooms(file, conn)
    file.each do |row|
        data = { 
            name: row['Room'].gsub('\'', '\\\''),
            area: row['Room area'],
            max_people: row['Room max people']
        }
  
        zone_name = row['Zone'].gsub('\'', '\\\'')
        office_title = row['Office'].gsub('\'', '\\\'')

        data[:office_id] = conn.exec("SELECT (id) from offices WHERE title='#{office_title}'").getvalue(0, 0)
        data[:zone_id] = conn.exec("SELECT (id) from zones WHERE office_id='#{data[:office_id]}' and name='#{zone_name}'").getvalue(0, 0)

        is_unique = conn.exec("SELECT COUNT(*) from rooms WHERE zone_id=#{data[:zone_id]} AND name='#{data[:name]}'").getvalue(0, 0)

        if(Integer(is_unique) == 0)
            conn.exec("INSERT INTO rooms(name, area, max_people, office_id, zone_id)
            VALUES('#{data[:name]}', '#{data[:area]}', '#{data[:max_people]}', '#{data[:office_id]}', '#{data[:zone_id]}')")
        end
      end
end

def upload_fixtures(file, conn)
    file.each do |row|
        data = { 
            fixture_name: row['Fixture'].gsub('\'', '\\\''),
            fixture_type: row['Fixture Type'],
        }
  
        zone_name = row['Zone'].gsub('\'', '\\\'')
        office_title = row['Office'].gsub('\'', '\\\'')
        room_name = row['Room'].gsub('\'', '\\\'')

        office_id = conn.exec("SELECT (id) from offices WHERE title='#{office_title}'").getvalue(0, 0)
        zone_id = conn.exec("SELECT (id) from zones WHERE office_id='#{office_id}' and name='#{zone_name}'").getvalue(0, 0)
        data[:room_id] = conn.exec("SELECT (id) from rooms WHERE zone_id='#{zone_id}' and name='#{room_name}' and office_id='#{office_id}'").getvalue(0, 0)

        is_unique = conn.exec("SELECT COUNT(*) from fixtures WHERE room_id=#{data[:room_id]} AND name='#{data[:fixture_name]}'").getvalue(0, 0)

        if(Integer(is_unique) == 0)
            conn.exec("INSERT INTO fixtures(name, type, room_id)
            VALUES('#{data[:fixture_name]}', '#{data[:fixture_type]}', '#{data[:room_id]}')")
        end
      end
end

def upload_marketing_materials(file, conn)
    file.each do |row|
        data = { 
            marketing_materials_name: row['Marketing material'].gsub('\'', '\\\''),
            marketing_materials_type: row['Marketing material type'],
            marketing_materials_cost: row['Marketing material cost']
        }
  
        zone_name = row['Zone'].gsub('\'', '\\\'')
        office_title = row['Office'].gsub('\'', '\\\'')
        room_name = row['Room'].gsub('\'', '\\\'')
        fixture_name = row['Fixture'].gsub('\'', '\\\'')

        office_id = conn.exec("SELECT (id) from offices WHERE title='#{office_title}'").getvalue(0, 0)
        zone_id = conn.exec("SELECT (id) from zones WHERE office_id='#{office_id}' and name='#{zone_name}'").getvalue(0, 0)
        room_id = conn.exec("SELECT (id) from rooms WHERE zone_id='#{zone_id}' and name='#{room_name}' and office_id='#{office_id}'").getvalue(0, 0)
        data[:fixture_id] = conn.exec("SELECT (id) from fixtures WHERE room_id='#{room_id}' and name='#{fixture_name}'").getvalue(0, 0)
        is_unique = conn.exec("SELECT COUNT(*) from marketing_materials WHERE fixture_id=#{data[:fixture_id]} AND name='#{data[:marketing_materials_name]}'").getvalue(0, 0)

        if(Integer(is_unique) == 0)
            conn.exec("INSERT INTO marketing_materials(name, fixture_id, type, cost)
            VALUES('#{data[:marketing_materials_name]}', '#{data[:fixture_id]}', '#{data[:marketing_materials_type]}', '#{data[:marketing_materials_cost]}')")
        end
      end
end

def decompose(file, conn) 
    upload_offices(file, conn)
    # upload_zones(file, conn)
    # upload_rooms(file, conn)
    # upload_fixtures(file, conn)
    # upload_marketing_materials(file, conn);
end