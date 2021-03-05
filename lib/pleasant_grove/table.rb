require 'elastic_tabstops'

module PleasantGrove

  # A Table is a result-row hash extended with TableExtension.
  #
  # For a given Table t, t == t.db_connection.tables[t['table_name']].
  #
  # For the most part, it looks just like a Result row for the query
  # that accesses metadata about tables in a database, extended with:
  #
  #   @db_connection: refers to the PleasantGrove object that ran the query.
  #   columns: returns a list of the Table's Columns.
  #   column(name): returns the named Column object.
  #   has_column?(name): answers whether the named column exists.
  #
  module TableExtension
    attr_accessor :db_connection

    def columns
      @columns ||= Columns.new(self);
    end

    def column(column_name)
      columns.by_name[column_name];
    end

    def has_column?(column_name)
      columns.by_name.key? column_name;
    end
  end

  # A Tables is a Result containing a list of hashes of table metadata.
  # Each @row[i] is a Table: a result-row hash extended with TableExtension.
  #
  # It is a Result set for the query that accesses metadata about the tables
  # of a database, extended with:
  #
  #   by_name: a hash from table names to Table objects.
  #
  class Tables < Result
    attr_accessor :by_name;

    def initialize(db_connection)
      super(db_connection.exec_params <<~'EOF');
        SELECT
          table_catalog as database_name,
          table_schema as schema,
          table_name,
          table_type
        FROM information_schema.tables
        WHERE table_schema = 'public'
        ORDER BY table_name ASC;
      EOF

      @by_name = @rows.inject({}) do |all_tables, table_data|
        table_data.extend(TableExtension);
        table_data.db_connection = db_connection;
        all_tables[table_data['table_name']] = table_data;
        all_tables
      end
    end
  end
end
