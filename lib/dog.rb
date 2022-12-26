class Dog
    attr_accessor :name, :id, :breed

    @@all = []

    def initialize (name:, id: nil, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
         CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
         )  
         SQL

         DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        self
    end

    def self.create(name:, breed:)
        new_dog = self.new(name: name, breed: breed)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        sql = <<-SQL
        SELECT * FROM dogs;
        SQL

        data = DB[:conn].execute(sql)

        data.each do |row|
            @@all << self.new_from_db(row)
        end
        @@all
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1;
        SQL

        requested_dog = DB[:conn].execute(sql, name)[0]

        self.new_from_db(requested_dog)
    
    end

    def self.find(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1;
        SQL

        requested_dog = DB[:conn].execute(sql, id)[0]

        self.new_from_db(requested_dog)
    end
end
