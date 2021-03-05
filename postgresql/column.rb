require 'elastic_tabstops'

module PostgreSQL

  # A Column is a result-row hash extended with ColumnExtension.
  #
  # For a given Column c, c == c.table.columns[c['column_name']].
  #
  # For the most part, it looks just like a Result row for the query
  # that accesses metadata about the columns of a table, extended with:
  #
  #   @table: refers to the Table owning this Column.
  #
  module ColumnExtension
    attr_accessor :table
  end

  # A Columns is a Result containing a list of hashes of column metadata.
  # Each @row[i] is a Column: a result-row hash extended with ColumnExtension.
  #
  # It is a Result set for the query that accesses metadata about the columns
  # of a Table, extended with:
  #
  #   @by_name: a hash mapping column names to Column objects.
  #   self[name]: returns the Column object for the named column.
  #
  class Columns < Result
    def initialize(table)
      puts "initializing Columns";
      super(table.postgresql.exec_params <<~"EOF");
        SELECT
          column_name,
          is_nullable as nullable,
          data_type as type
        FROM information_schema.columns
        WHERE table_name = '#{table['table_name']}';
      EOF

      @by_name = @rows.inject({}) do |all_columns, column_data|
        column = column_data.clone.tap do |c|
          c['nullable'] = c['nullable'] == 'YES' ? true : false;
          c.extend(ColumnExtension);
          c.table = table;
        end;
        all_columns[column_data['column_name']] = column;
        all_columns
      end
      puts "by_name: #{@by_name.inspect}"
    end

    def [](index)
      @by_name.fetch(index)
    end
  end
end
