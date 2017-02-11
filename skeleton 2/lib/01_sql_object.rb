require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    query = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    @columns = query.first.map(&:to_sym)
  end


  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes
        @attributes[column.to_sym]
      end

      define_method("#{column}=".to_sym) do |value|
        attributes
        @attributes[column.to_sym] = value
      end
    end


  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    return @table_name if @table_name
    @table_name = self.to_s.tableize
  end

  def self.all
    query = DBConnection.execute(<<-SQL)
      SELECT
        #{@table_name}.*
      FROM
        #{@table_name}
    SQL
    @all_items = self.parse_all(query)
  end

  def self.parse_all(results)
    output = []
    results.each do |hash|
      output << self.new(hash)
    end
    output
  end

  def self.find(id)
    # return @columns if @columns

    query = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    return nil if query.empty?
    self.new(query[0])
  end

  def initialize(params = {})
    params.each do |input_attr_name, input_value|
      if self.class.columns.include?(input_attr_name.to_sym)
        self.send("#{input_attr_name}=".to_sym, input_value)
      else
        raise "unknown attribute '#{input_attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column|
      self.send(column.to_sym)
    end
  end

  def insert
    col_names = self.class.columns.join(",")
    question_marks = (["?"] * attribute_values.length).join(",")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns.map do |attr_name|
      "#{attr_name} = ?"
    end.join(",")
    DBConnection.execute(<<-SQL, *attribute_values, @attributes[:id])
    UPDATE
      #{self.class.table_name}
    SET
      #{col_names}
    WHERE
      id = ?
    SQL
  end

  def save
    if @attributes.nil?
      insert
    else
      update
    end
  end
end
