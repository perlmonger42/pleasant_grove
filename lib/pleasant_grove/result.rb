require 'forwardable'

module PleasantGrove

  # A Result contains a list of rows representing the result of an SQL query.
  class Result
    include Enumerable
    extend Forwardable
    def_delegators :@rows, :each, :<<
    attr_reader :status, :row_count, :col_count, :field_names, :rows

    def initialize(query_result)
      r = query_result;
      @status = r.result_status;
      @row_count = r.num_tuples;
      @col_count = r.num_fields;
      @field_names = r.fields;
      @rows = r.map { |row| row.clone  }
    end

    def show(numbered: false, title: nil, max_rows: nil)
      if $PleasantGroveVerbosity > 0
        puts "Response: status = #{@status}, " +
             "row-count = #{@row_count}, " +
             "column-count = #{@col_count}";
      end
      PleasantGrove::show(@rows, numbered: numbered, title: title, max_rows: max_rows);
    end
  end
end

# pry> ls query_result
#  ls r
#  Enumerable#methods:
#    all?            drop              find_all    map        partition     sum
#    any?            drop_while        find_index  max        reduce        take
#    chain           each_cons         first       max_by     reject        take_while
#    chunk           each_entry        flat_map    member?    reverse_each  to_a
#    chunk_while     each_slice        grep        min        select        to_h
#    collect         each_with_index   grep_v      min_by     slice_after   to_set
#    collect_concat  each_with_object  group_by    minmax     slice_before  uniq
#    count           entries           include?    minmax_by  slice_when    zip
#    cycle           filter            inject      none?      sort
#    detect          find              lazy        one?       sort_by
#  PG::Result#methods:
#    []                field_values  num_tuples
#    autoclear?        fields        oid_value
#    check             fmod          paramtype
#    check_result      fname         res_status
#    clear             fnumber       result_error_field
#    cleared?          fsize         result_error_message
#    cmd_status        ftable        result_status
#    cmd_tuples        ftablecol     result_verbose_error_message
#    cmdtuples         ftype         stream_each
#    column_values     getisnull     stream_each_row
#    each              getlength     stream_each_tuple
#    each_row          getvalue      tuple
#    error_field       inspect       tuple_values
#    error_message     map_types!    type_map
#    fformat           nfields       type_map=
#    field_name_type   nparams       values
#    field_name_type=  ntuples       verbose_error_message
#    field_names_as    num_fields
