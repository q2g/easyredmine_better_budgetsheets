class BetterBudgetsheets::TimeEntryLineItemGenerator

  attr_accessor :project, :projects, :entries, :line_items, :performance_from, :performance_to
  
  def initialize(entry_ids, project_id)
    @project = Project.find(project_id)
    @entries = TimeEntry.where(id: entry_ids)
    
    @performance_from = @entries.pluck(:spent_on).min
    @performance_to = @entries.pluck(:spent_on).max
    
    
    # group by projects and activities, and rate
    @projects = {}
    @entries.group(:project_id).each do |project_entry|
      current_project = project_entry.project
      
      @projects[current_project] = {}
      @entries.where(project_id: current_project.id).group(:activity_id).each do |activity_entry|
        @projects[current_project][activity_entry.activity] = {}
        
        @entries.where(project_id: current_project.id, activity_id: activity_entry.activity_id).each do |entry|
          # determine the unit rate and sum up total spent hours
          # TODO: Verify where to get settings for internal/external rate
          unit_rate = EasyMoneyRate.get_unit_rate_for_time_entry(entry, 1)
          @projects[current_project][activity_entry.activity][unit_rate] ||= {value: 0, entry_ids: []}
          @projects[current_project][activity_entry.activity][unit_rate][:value] += entry.hours
          @projects[current_project][activity_entry.activity][unit_rate][:entry_ids] << entry.id
        end
        
      end
    end
  end
  
  def line_items
    @line_items ||= build_line_items
  end
  
  def inspect_result
    @projects.each do |project, activities|
      puts project.name
      activities.each do |activity, values|
        puts "== #{activity.name}"
        activities.values.each do |rate_entry|
          puts "==> #{rate_entry.values.first.to_f}x #{rate_entry.keys.first.to_f}"
        end
      end  
        
    end
  end

  
  def build_line_items
    result = []
    @projects.each do |project, activities|
      activities.each do |activity, values|
        activities.values.each do |rate_entry|
          result << EasyInvoiceLineItem.new({
            name: "#{project.name} - #{activity.name}",
            unit_price: rate_entry.keys.first,
            quantity: rate_entry[:value],
            unit_name: "Stunden",
            vat_rate: EasySetting.value('easy_invoicing_default_vat_rate', project),
          })
        end
      end  
    end
    
    return result
  end
    
end