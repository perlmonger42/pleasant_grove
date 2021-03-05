require 'elastic_tabstops'

module PostgreSQL

  # A Table is a result-row hash extended with TableExtension.
  #
  # For a given Table t, t == t.postgresql.tables[t['table_name']].
  #
  # For the most part, it looks just like a Result row for the query
  # that accesses metadata about tables in a database, extended with:
  #
  #   @postgresql: refers to the PostgreSQL object that ran the query.
  #   columns: method that gets the Table's Columns.
  #
  module TableExtension
    attr_accessor :postgresql

    def columns
      @columns ||= Columns.new(self);
    end
  end

  # A Tables is a Result containing a list of hashes of table metadata.
  # Each @row[i] is a Table: a result-row hash extended with TableExtension.
  #
  # It is a Result set for the query that accesses metadata about the tables
  # of a database, extended with:
  #
  #   @by_name: a hash mapping table names to Table objects.
  #   self[name]: returns the Table object for the named table.
  #
  class Tables < Result
    def initialize(postgresql)
      super(postgresql.exec_params <<~'EOF');
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
        table = table_data.clone.tap do |t|
          t.extend(TableExtension);
          t.postgresql = postgresql;
        end
        all_tables[table_data['table_name']] = table;
        all_tables
      end
    end

    def [](index)
      @by_name.fetch(index)
    end
  end
end
