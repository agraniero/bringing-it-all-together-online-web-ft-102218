require 'pry'
require_relative "../config/environment.rb"

class Dog
  attr_accessor :name, :breed, :id
  
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end
  
  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
      SQL
      
    DB[:conn].execute(sql)
  end
  
  def self.find_or_create_by(name:, breed:)
    
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    
      if !dog.empty?
        dog_data = dog[0]
        dog = self.new(dog_data[0], dog_data[1], dog_data[2])
      else
        dog = self.create(name: name, breed: breed)
      end
    dog 
  end 
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
      
    DB[:conn].execute(sql)  
  end
  
end 