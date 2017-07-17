class BetterBudgetsheets::TimeEntryGroupingService

  attr_reader :entries, :columns, :groups, :project_names

  attr_accessor :groups, :root_sets

  def initialize(entries, columns: [:comments, :hours, :spent_on], groups: )
    @entries = entries

    @groups  = Array.wrap(groups).map do |g|
      if g.include?("cf_")
        g.to_sym
      else
        "#{g}_id".to_sym
      end
    end
    
    @columns = columns.map(&:to_sym)

    # clean up selcted and grouped fields
    @columns.reject! {|c| @groups.include?(c) }
    
    @project_names = Project.where(id: @entries.pluck(:project_id)).map do |project|
      #checking if easy_invoicing_client_id is set
      client_id = EasySetting.find_by(name: 'easy_invoicing_client_id', project_id: project.id).try(:value)
      if client_id
        c = EasyContact.find(client_id)
        [c.firstname.presence, c.lastname.presence].compact.join(" ")
      else
        project.name
      end
    end

    load_root_set
  end

  def load_root_set
    field_name = @groups[0]

    if field_name
      grouped_entries = query_grouped_entries(@entries, field_name)

      root_is_cf = field_name.to_s.include?("cf_")

      custom_field_entries = if root_is_cf
        self.custom_field_query(grouped_entries[:entries], field_name)
      end

      @root_sets = grouped_entries[:values].map do |id|
        EntrySet.new(
          self,
          grouped_field_label_name_for(field_name, id),
          (root_is_cf ? custom_field_entries : grouped_entries[:entries]).where(grouped_entries[:field_name] => id),
          0
        )
      end
    else
      @root_sets = []
    end
  end
  
  def set_locked_and_billed!(user)
    @entries.update_all(easy_billed: true, easy_locked: true, easy_locked_by_id: user.id, easy_locked_at: Time.now)
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
      id.to_s
    end
  end

  def query_grouped_entries(entries, field_name)
    data = {
      entries: entries
    }
    if field_name.to_s.match("cf_")
      data[:values] = custom_field_query(entries, field_name).group("custom_values.value").pluck("custom_values.value")
      data[:field_name] = "custom_values.value"
    else
      data[:values] = entries.group(field_name).pluck(field_name)
      data[:field_name] = field_name
    end

    return data
  end

  def cf_from_field_name(cf_field_name)
    CustomField.find(cf_field_name.to_s.match(/[0-9]{1,}/).to_s)
  end

  def custom_field_query(entries, cf_field_name)
    cf = cf_from_field_name(cf_field_name)

    if cf.type == 'TimeEntryCustomField'
      cf_type_id = 'id'
    else
      cf_type_id = "#{cf.type.gsub('CustomField', '').downcase}_id"
    end

    TimeEntry.select("time_entries.*, custom_values.value, custom_values.custom_field_id")
      .joins("LEFT JOIN custom_values ON time_entries.#{cf_type_id} = custom_values.customized_id")
      .where("custom_values.custom_field_id = #{cf.id}")
      .where("time_entries.id IN (#{entries.pluck(:id).join(",")})")

  end

  class EntrySet

    attr_reader :entries, :sub_sets, :field_name, :index

    def initialize(grouping_service, field_name, entries, index)
      @entries          = entries
      @field_name = field_name
      @index = index

      next_group_column  = grouping_service.groups[index+1]

      if next_group_column && @entries.any?
        @is_cf = next_group_column.to_s.include?("cf_")

        grouped_entries = grouping_service.query_grouped_entries(@entries, next_group_column)

        custom_field_entries = if @is_cf
          grouping_service.custom_field_query(grouped_entries[:entries], next_group_column)
        end

        @sub_sets = grouped_entries[:values].map do |id|
          EntrySet.new(
            grouping_service,
            grouping_service.grouped_field_label_name_for(next_group_column, id),

            (@is_cf ? custom_field_entries : grouped_entries[:entries]).where(grouped_entries[:field_name] => id),
            @index+1
          )
        end

        # scanning for blank entries

        @sub_sets << EntrySet.new(
            grouping_service,
            "-",
            (
              @is_cf ?
                grouped_entries[:entries].where.not(id: custom_field_entries.pluck(:id)) :
                  grouped_entries[:entries].where("#{grouped_entries[:field_name]} IS NULL OR #{grouped_entries[:field_name]} = ''")),
            @index+1
          )
      end

    end

    def root_set?
      index == 0
    end

  end

end