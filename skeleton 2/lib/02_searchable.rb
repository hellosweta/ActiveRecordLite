require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map do |key|
      "#{key} = ?"
    end.join(" AND ")
    param_values = params.values
    query = DBConnection.execute(<<-SQL, *param_values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
      SQL
    output = []
    query.each do |instance|
      output << self.new(instance)
    end
    output 
  end
end

class SQLObject
  extend Searchable
end
