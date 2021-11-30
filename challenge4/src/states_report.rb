class StatesReport
    def initialize(conn)
        template = '<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Challenge 4</title>
    <style>
        section {
            display: table;
            font-size:18px; width: 60%; border-collapse: collapse; text-align:left;
        }

        section > * {
            display: table-row;
            border-bottom: 1px solid #ddd;
        }

        section .col {
            display: table-cell;
            padding: 8px;
        }
    </style>
</head>'
        template += '
<body style="padding: 1em">
    <div style="display:flex">
        <div style="background-size: contain; background-image: url(\'../images/ruby.png\'); 
            width: 200px; height: 100px; border: 1px solid black; display: flex; align-items:center; justify-content:center;">
        </div>
        <div style="width:40%">
            <h1 style="display: flex; align-items:center; justify-content:center; font-weight: 500;">States Report</h1>
        </div>
    </div>'
        template += '
    <div style="margin-top:40px">{BODY}
    </div>
</body>
</html>'
    
        generate_report(conn, template)
    end
  
    def generate_report(conn, template)
        offices = conn.exec('SELECT * FROM offices ORDER BY state;')
    
        body = ''
        state = ''
    
        offices.each do |office|
            if state != office['state']
                body += '
            </section>' if state != ''
        
                state = office['state']
        
                body += "
            <h2 style='width:60%; border-bottom:2px solid black;'>#{state}</h2>
            <section>
                <header style='font-weight: 600;'>
                    <div class='col'>Office</div>
                    <div class='col'>Type</div>
                    <div class='col'>Address</div>
                    <div class='col'>LOB</div>
                </header>"
            end
      
            row = "
                <div class='row'>
                    <div class='col'>#{office['title']}</div>
                    <div class='col'>#{office['type']}</div>
                    <div class='col'>#{office['address']}</div>
                    <div class='col'>#{office['lob']}</div>
                </div>"
      
            body += row
        end
    
        body += '
            </section>
        </div>'
    
        report = template.gsub('{BODY}', body)
    
        File.open('html/states.html', 'w') { |file| file.write(report) }
    end
end