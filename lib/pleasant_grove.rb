require "pg"
require "pleasant_grove/result.rb"
require "pleasant_grove/column.rb"
require "pleasant_grove/table.rb"

$Verbose ||= 0;

module PleasantGrove
  class Connection
    attr_reader :host_name, :database_name;

    def die(msg)
      throw msg
    end

    def initialize(host_name: nil, database_name: nil, verbose: false)
      @host_name = host_name || ENV['PGHOST'] ||
        die("host_name required");
      @database_name = database_name || ENV['PGDATABASE'] ||
        die("database_name required");

      @conn = ::PG::Connection.open(:dbname => database_name);
      if verbose
        puts "Talking to #{@database_name} on #{@host_name} " +
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

    def table(table_name)
      tables.by_name[table_name];
    end

    def has_table?(table_name)
      tables.by_name.key? table_name;
    end

    def show(grid, numbered: false, title: nil)
      PleasantGrove.show(grid, numbered: numbered, title: title);
    end

    # Display a table of data.
    # Expects grid to be a list of hashes.
    # The column names are taken from the first hash.
    def PleasantGrove.show(grid, numbered: false, title: nil)
      puts "===== #{title} =====" unless title.nil?
      return if grid.empty?

      out = ElasticTabstops::make_stream($stdout);
      field_names = grid[0].keys;

      out.print "Seq\t" if numbered;
      out.puts field_names.join("\t");

      out.print "---\t" if numbered;
      out.puts field_names.map { |name| "-" * name.size }.join("\t");

      row_number = 0;
      grid.each do |row|
        row_number = row_number + 1;
        out.print row_number, "\t" if numbered;
        out.puts "#{row.values_at(*field_names).join("\t")}";
      end
      out.flush;
    end
  end
end
