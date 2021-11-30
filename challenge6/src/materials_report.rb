require 'quickchart'

class MaterialsReport
    def initialize(conn)
        template = '<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Challenge 6</title>
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
            <h1 style="display: flex; align-items:center; justify-content:center; font-weight: 500;">Materials Cost Report</h1>
        </div>
    </div>
    <div style="margin-top:40px">{BODY}
    </div>
</body>
</html>'
    
        generate_report(conn, template)
    end
  
    def generate_report(conn, template)
        materials = conn.exec('
            SELECT DISTINCT offices.title, marketing_materials.type AS "materials_type", SUM(marketing_materials.cost) as "total"
            FROM marketing_materials 
            JOIN fixtures on marketing_materials.fixture_id = fixtures.id 
            JOIN rooms on fixtures.room_id = rooms.id 
            JOIN zones on rooms.zone_id = zones.id 
            JOIN offices on zones.office_id = offices.id
            GROUP BY marketing_materials.type, offices.id
            ORDER BY offices.title, marketing_materials.type').entries()
        body = ''
        type = ''
        counter = 0

        materials.each do |material|
            if type != material['title']
                body = body.gsub('COUNTER', counter.to_s())
                counter = 0
                body += '
            </section>' if type != ''
        
            type = material['title']
        
                body += "
            <h2 style='display:flex; justify-content:space-between; width:60%; border-bottom:2px solid black;'>#{type} <span>COUNTER</span></h2>
            <section>
                <header style='font-weight: 600;'>
                    <div class='col'>Type</div>
                    <div class='col'>Total Cost</div>
                </header>"
            end
      
            row = "
                <div class='row'>
                    <div class='col'>#{material['materials_type']}</div>
                    <div class='col'>#{material['total']}</div>
                </div>"

            counter += material['total'].to_i()
            body += row
        end
        body = body.gsub('COUNTER', counter.to_s())
        body += '
            </section>'

        material_groups = {}
        material_types = {}
    
        materials.each do |material|
          material_groups[material["title"]] = [] unless material_groups.key?(material["title"])
          material_types[material["materials_type"]] = 0 unless material_types.key?(material["materials_type"])
    
          material_types[material["materials_type"]] += material["total"].to_i
          material_groups[material["title"]].push(material.slice("materials_type", "total"))
        end

        materials_data = [material_groups, material_types]

        chart = generate_chart(materials_data[1])

        body += "
        <h1 class='mt-5 text-center'>Marketing Material Costs By Type</h1>
        <p class='text-center'>
            <img src='#{chart.get_url}'/>
        </p>
        </div>"

        report = template.gsub('{BODY}', body)
    
        File.open('html/states.html', 'w') { |file| file.write(report) }
    end
    def generate_chart(materials_data)
        QuickChart.new(
          {
            type: 'doughnut',
            data: {
              labels: materials_data.keys,
              datasets: [
                data: materials_data.values
              ]
            }
          },
          width: 600,
          height: 300
        )
      end
end