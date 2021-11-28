require 'pg'

conn = PG.connect(:dbname => 'task_1', :password => 'admin', :port => 5432, :user => 'postgres')

conn.exec (
    'CREATE TABLE IF NOT EXISTS "offices" (
      "id" SERIAL PRIMARY KEY,
      "title" varchar UNIQUE,
      "address" varchar,
      "city" varchar,
      "state" varchar,
      "phone" varchar,
      "lob" varchar,
      "type" varchar
    );'
)

conn.exec(
    'CREATE TABLE IF NOT EXISTS "zones" (
        "id" SERIAL PRIMARY KEY,
        "name" varchar,
        "office_id" int NOT NULL
    );
    ALTER TABLE "zones" ADD FOREIGN KEY ("office_id") REFERENCES "offices" ("id") ON DELETE CASCADE;'
)

conn.exec(
    'CREATE TABLE IF NOT EXISTS "rooms" (
        "id" SERIAL PRIMARY KEY,
        "name" varchar,
        "area" int,
        "max_people" int,
        "office_id" int NOT NULL,
        "zone_id" int NOT NULL
    );
    ALTER TABLE "rooms" ADD FOREIGN KEY ("office_id") REFERENCES "offices" ("id") ON DELETE CASCADE;
    ALTER TABLE "rooms" ADD FOREIGN KEY ("zone_id") REFERENCES "zones" ("id") ON DELETE CASCADE;'
)

conn.exec(
    'CREATE TABLE IF NOT EXISTS "fixtures" (
        "id" SERIAL PRIMARY KEY,
        "name" varchar,
        "room_id" int NOT NULL,
        "type" varchar
    );
    ALTER TABLE "fixtures" ADD FOREIGN KEY ("room_id") REFERENCES "rooms" ("id") ON DELETE CASCADE;'
)

conn.exec(
    'CREATE TABLE IF NOT EXISTS "marketing_materials" (
        "id" SERIAL PRIMARY KEY,
        "name" varchar,
        "fixture_id" int NOT NULL,
        "type" varchar,
        "cost" int
    );
    ALTER TABLE "marketing_materials" ADD FOREIGN KEY ("fixture_id") REFERENCES "fixtures" ("id") ON DELETE CASCADE;'
)