class FixturesReport
    def initialize(conn)
        template = '<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Challenge 5</title>
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
        <div style="width:40%">
            <h1 style="display: flex; align-items:center; justify-content:center; font-weight: 500;">Fixtures Report</h1>
        </div>
    </div>
    <div style="margin-top:40px">{BODY}
    </div>
</body>
</html>'
    
        generate_report(conn, template)
    end
  
    def generate_report(conn, template)
        fixtures = conn.exec('
            SELECT DISTINCT fixtures.type AS "fixtures_type", offices.id AS "office_id", COUNT(offices.id) as "total", offices.*
            FROM fixtures 
            JOIN rooms on fixtures.room_id = rooms.id 
            JOIN zones on rooms.zone_id = zones.id 
            JOIN offices on zones.office_id = offices.id
            GROUP BY fixtures.type, offices.id
            ORDER BY fixtures.type, offices.id').entries()
        body = ''
        type = ''
        counter = 0

        fixtures.each do |fixture|
            if type != fixture['fixtures_type']
                body = body.gsub('COUNTER', counter.to_s())
                counter = 0
                body += '
            </section>' if type != ''
        
            type = fixture['fixtures_type']
        
                body += "
            <h2 style='display:flex; justify-content:space-between; width:60%; border-bottom:2px solid black;'>#{type} <span>COUNTER</span></h2>
            <section>
                <header style='font-weight: 600;'>
                    <div class='col'>Office</div>
                    <div class='col'>Type</div>
                    <div class='col'>Address</div>
                    <div class='col'>LOB</div>
                    <div class='col'>Total Count</div>
                </header>"
            end
      
            row = "
                <div class='row'>
                    <div class='col'>#{fixture['title']}</div>
                    <div class='col'>#{fixture['type']}</div>
                    <div class='col'>#{fixture['address']}</div>
                    <div class='col'>#{fixture['lob']}</div>
                    <div class='col'>#{fixture['total']}</div>
                </div>"

            counter += fixture['total'].to_i()
            body += row
        end
        body = body.gsub('COUNTER', counter.to_s())
        body += '
            </section>
        </div>'
    
        report = template.gsub('{BODY}', body)
    
        File.open('html/states.html', 'w') { |file| file.write(report) }
    end
end