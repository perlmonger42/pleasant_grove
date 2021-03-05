require "pg"
require "postgresql/result.rb"
require "postgresql/column.rb"
require "postgresql/table.rb"

$Verbose ||= 0;

module PostgreSQL
  class Connection
    def initialize(host = nil, database_name = nil)
      host ||= ENV['PGHOST'] || ENV['PG_HOST'];
      database_name ||= ENV['PGDATABASE'] || ENV['PG_NAME'];

      @conn = ::PG::Connection.open(:dbname => database_name);
      if $Verbose > 0
        puts "Talking to #{database_name} on #{host} " +
             "(pg version #{@conn.server_version})";
        puts;
      end
      @tables = false;
    end

    def close
      @conn.close if @conn
      @conn = nil
    end

    def exec_params(str, args=[])
      if $Verbose > 0
        puts "Query: #{str.strip}"
        puts "Args: #{args.inspect}";
      end;
      @conn.exec_params(str, args);
    end

    def query(str, args=[])
      Result.new self.exec_params(str, args);
    end

    # Return a hash containing the tables in the public schema of the connected
    # database.  The response has this form:
    #   {
    #     DATABASE_NAME: {
    #       database_name: DATABASE_NAME,
    #       schema_name: SCHEMA_NAME,
    #       table_name: TABLE_NAME,
    #       table_type: ('VIEW' | 'BASE TABLE' | ...?),
    #     },
    #     ...
    #   }
    def tables
      @tables ||= Tables.new(self);
    end
  end
end
