class BetterBudgetsheets::TimeEntryGroupingService

  attr_reader :entries, :columns, :groups

  attr_accessor :groups, :root_sets

  def initialize(entries, columns: [:comments, :hours, :spent_on], groups: [:project_id, :cf_25, :user_id, :cf_26, :cf_27])
    @entries = entries
    @columns = columns.map(&:to_sym)
    @groups  = groups.map(&:to_sym)
    load_root_set
  end

  def load_root_set
    field_name = groups[0]
    grouped_entries = query_grouped_entries(@entries, field_name)

    @root_sets = grouped_entries[:values].map do |id|
      EntrySet.new(
        self,
        grouped_field_label_name_for(field_name, id),
        grouped_entries[:entries].where(grouped_entries[:field_name] => id),
        0
      )
    end
  end

  def colspan_at_index(index)
    (@columns.size + @groups.size) - index
  end

  # name for grouped columns
  def grouped_field_label_name_for(field_name, id)
    case field_name.to_sym
    when :project_id
      Project.find(id).name
    when :user_id
      User.find(id).name
    when :issue_id
      Issue.find(id).subject
    when :activity_id
      TimeEntryActivity.find(id).name
    else
      if field_name.to_s.match("cf_")
        cf_from_field_name(field_name).name
      end
    end
  end

  def query_grouped_entries(entries, field_name)
    if field_name.to_s.match("cf_")
      sql = custom_field_query(entries, field_name)
      entries = TimeEntry.find_by_sql(sql)

      {
        entries: entries,
        values: entries.group("custom_values.value").pluck("custom_values.value")
        field_name: "custom_values.value"
      }
    else
      {
        entries: entries,
        values: entries.group(field_name).pluck(field_name),
        field_name: field_name
      }

    end
  end

  def cf_from_field_name(cf_field_name)
    CustomField.find(cf_field_name.to_s.match(/[0-9]{1,}/).to_s)
  end

  def custom_field_query(entries, cf_field_name)
    cf = cf_from_field_name(cf_field_name)
    cf_type = cf.type.gsub('CustomField', '')
    cf_type_id = "#{cf_type.downcase}_id"

    query =   ["SELECT *, custom_values.value, custom_values.custom_field_id FROM time_entries"]
    query <<  ["LEFT JOIN custom_values ON time_entries.#{cf_type_id} = custom_values.customized_id WHERE custom_values.customized_type = '#{cf_type}'"]
    query <<  ["AND custom_values.custom_field_id = #{cf.id}"]
    query <<  ["AND time_entries.id IN (#{entries.pluck(:id).join(",")})"]
    query.join(" ")
  end

  class EntrySet

    attr_reader :entries, :sub_sets, :field_name, :index

    def initialize(grouping_service, field_name, entries, index)
      @entries          = entries
      @field_name = field_name
      @index = index

      next_group_column  = grouping_service.groups[index+1]

      if next_group_column
        grouped_entries = query_grouped_entries(@entries, next_group_column)

        @sub_sets = grouped_entries[:values].map do |id|
          EntrySet.new(
            grouping_service,
            grouping_service.grouped_field_label_name_for(next_group_column, id),
            grouped_entries[:entries].where(grouped_entries[:field_name] => id),
            @index+1
          )
        end
      end

    end

  end

end