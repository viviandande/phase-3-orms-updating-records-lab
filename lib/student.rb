require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  # with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      self.id = DB[:conn].last_insert_row_id()
    end
  end

  def self.create(name, grade)
    newStudent = Student.new(name, grade)
    newStudent.save

  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, grade FROM students WHERE name =?
    SQL

    Student.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE students SET grade = ?, name = ? WHERE id =?
    SQL
    DB[:conn].execute(sql, self.grade, self.name, self.id)
  end
end