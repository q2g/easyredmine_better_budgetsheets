class BetterBudgetsheets::TimeEntryGroupingService

  attr_reader :entries, :columns, :groups

  attr_accessor :groups, :root_sets

  def initialize(entries, columns = [:comments, :hours, :spent_on], groups = [:project_id, :user_id, :issue_id])
    @entries = entries
    @columns = columns.map(&:to_sym)
    @groups  = groups.map(&:to_sym)
    load_root_set
  end

  def load_root_set
    field_name = groups[0]
    root_ids = @entries.group(field_name).pluck(field_name)
    @root_sets = root_ids.map do |id|
      EntrySet.new(
        self,
        field_label_name_for(field_name, id),
        @entries.where(field_name => id),
        0
      )
    end
  end

  def colspan_at_index(index)
    (@columns.size + @groups.size) - index
  end

  def field_label_name_for(field_name, id)
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
      ""
    end
  end

  class EntrySet

    attr_reader :entries, :sub_sets, :field_name, :index

    def initialize(grouping_service, field_name, entries, index)
      @entries          = entries
      @field_name = field_name
      @index = index

      next_group_column  = grouping_service.groups[index+1]

      if next_group_column
        @sub_sets = @entries.group(next_group_column).pluck(next_group_column).map do |id|
          EntrySet.new(
            grouping_service,
            grouping_service.field_label_name_for(next_group_column, id),
            @entries.where(next_group_column => id),
            @index+1
          )
        end
      end

    end

  end

end