class InstallationReport
    def initialize(conn)
        template = '<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Challenge 7</title>
    <style>
        section {
            display: table;
            font-size:18px; width: 60%; border-collapse: collapse; text-align:left;
        }

        section > * {
            display: table-row;
            border-bottom: 1px dashed grey;
        }

        section .col {
            display: table-cell;
            border-right: 1px dashed grey;
            padding: 8px;
        }
    </style>
</head>
<body style="padding: 1em">
    <div style="display:flex">
        <div style="background-size: contain; background-image: url(\'../images/ruby.png\'); 
            width: 200px; height: 100px; border: 1px solid black; display: flex; align-items:center; justify-content:center;">
        </div>
        <div style="display:flex; flex-flow:column; width:40%">
            <h1 style="display: flex; text-align: center; align-items:center; justify-content:center; font-weight: 500;">{TITLE}</h1>
            <h4 style="display: flex; text-align: center; align-items:center; justify-content:center; font-weight: 500;">{SUBTITLE}</h4>
        </div>
    </div>
    <div style="display:flex; flex-flow:column; width:60%">
            <h2 style="display: flex; text-align: center; align-items:center; justify-content:center; font-weight: 500;">Installation Instructions</h1>
    </div>
    <div style="margin-top:40px">{BODY}
    </div>
</body>
</html>'
    
        generate_report(conn, template)
    end
  
    def generate_report(conn, template)
        info = conn.exec('
            SELECT offices.*, zones.name AS "zone_name", 
            rooms.name AS "room_name", rooms.area AS "room_area", rooms.max_people AS "room_max_people",
            fixtures.name AS "fixtures_name",
            fixtures.type AS "fixtures_type", 
            marketing_materials.name AS "materials_name", 
            marketing_materials.type AS "materials_type"
            FROM offices 
            JOIN zones on offices.id = zones.office_id
            JOIN rooms on rooms.zone_id = zones.id 
            JOIN fixtures on fixtures.room_id = rooms.id 
            JOIN marketing_materials on marketing_materials.fixture_id = fixtures.id
            ORDER BY offices.title').entries()
        
        offices = divide_offices(info)
        offices.each do |office|
            body = get_office_info(office)
        
            report = template.gsub('{TITLE}', office[1]["office_data"]["title"])
                                .gsub('{SUBTITLE}', "#{office[1]["office_data"]["state"]}, #{office[1]["office_data"]["address"]}, #{office[1]["office_data"]["phone"]}, #{office[1]["office_data"]["type"]}<br />Area: #{office[1]['area']}<br />Max people: #{office[1]['max_people']}")
                                .gsub('{BODY}',     body)
        
            File.open("html/#{office[1]['office_data']['title']}.html", 'w') { |file| file.write(report) }
        end
    end
    def get_office_info(office)
        body = ''
    
        office[1]["zones"].each do |zone|
            row = "
        <h2 style='display:flex; justify-content:space-between; width:60%;'>Zone: #{zone.first}</h2>"
    
            zone[1].each do |room|
                row += "
                <h3 style='display:flex; justify-content:space-between; width:60%;'>Room: #{room.first}</h3>
                <section>
                    <header style='font-weight: 600;'>
                        <div class='col'>Material name</div>
                        <div class='col'>Material type</div>
                        <div class='col'>Fixture name</div>
                        <div class='col'>Fixture type</div>
                    </header>"
        
                room[1].each do |material|
                    row += "
                    <div class='row'>
                        <div class='col'>#{material['materials_name']}</div>
                        <div class='col'>#{material['materials_type']}</div>
                        <div class='col'>#{material['fixtures_name']}</div>
                        <div class='col'>#{material['fixtures_type']}</div>
                    </div>"
                end

                row += "
                </section>"
            end
        
            body += row
        end

        body
    end
    def divide_offices(info)
        offices = {}
    
        info.each do |office|
            unless(offices.key?(office["title"]))
                offices[office["title"]] = {}
                offices[office["title"]]["office_data"] = office.slice("title", "city", "address", "state", "phone", "lob", "type")
                offices[office["title"]]["zones"] = {}
                offices[office["title"]]["area"] = 0
                offices[office["title"]]["max_people"] = 0
            end
        
            unless(offices[office["title"]]["zones"].key?(office["zone_name"]))
                offices[office["title"]]["zones"][office["zone_name"]] = {}
            end
        
            unless(offices[office["title"]]["zones"][office["zone_name"]].key?(office["room_name"]))
                offices[office["title"]]["zones"][office["zone_name"]][office["room_name"]] = []
                offices[office["title"]]["area"] +=  office["room_area"].to_i
                offices[office["title"]]["max_people"] +=  office["room_max_people"].to_i
            end
    
          offices[office["title"]]["zones"][office["zone_name"]][office["room_name"]].append(office.slice("fixtures_name", "fixtures_type", "materials_name", "materials_type"))
        end
        offices
    end
end