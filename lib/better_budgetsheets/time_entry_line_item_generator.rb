class BetterBudgetsheets::TimeEntryLineItemGenerator

  attr_accessor :project, :projects, :entries, :line_items
  
  def initialize(entry_ids, project_id)
    @project = Project.find(params[:id])
    @entries = TimeEntry.where(id: entry_ids)
    
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
          unit_rate = EasyMoneyRate.get_unit_rate_for_time_entry(entry, current_project.calculation_rate_id)
          @projects[current_project][activity_entry.activity][unit_rate] ||= 0
          @projects[current_project][activity_entry.activity][unit_rate] += entry.hours
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
            quantity: rate_entry.values.first,
            # TODO: where to get vat rate settings
            vat_rate: 19.0
          })
        end
      end  
    end
    
    return result
  end
    
end