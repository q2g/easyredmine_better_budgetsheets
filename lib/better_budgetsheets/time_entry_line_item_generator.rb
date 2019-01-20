class BetterBudgetsheets::TimeEntryLineItemGenerator

  attr_accessor :project, :projects, :entries, :line_items, :performance_from, :performance_to, :client
  
  def initialize(entry_ids, project_id)
    @project = Project.find(project_id)
    @entries = TimeEntry.where(id: entry_ids)
    
    @performance_from = @entries.pluck(:spent_on).min
    @performance_to   = @entries.pluck(:spent_on).max
    
    @client = EasyContact.find_by(id: EasySetting.value(:easy_invoicing_client_id, @project))
    @locale = EasySetting.value(:easy_invoicing_default_invoice_locale, @project)
    
    count_cf = CustomField.find_by(internal_name: 'time_entry_count')
      
    # group by projects and activities, and rate
    @projects = {}
    @entries.group(:project_id).each do |project_entry|
      current_project = project_entry.project
      
      @projects[current_project] = {}
      @entries.where(project_id: current_project.id).group(:activity_id).each do |activity_entry|
        @projects[current_project][activity_entry.activity] = {}
        
        @entries.where(project_id: current_project.id, activity_id: activity_entry.activity_id).each do |entry|
          # determine the unit rate and sum up total spent hours
          unit_rate = EasyMoneyRate.get_unit_rate_for_time_entry(entry, EasySetting.value(:easy_invoicing_rate_type_id, @project))

          @projects[current_project][activity_entry.activity][unit_rate] ||= { value: 0, entry_ids: [], fix: true}
          @projects[current_project][activity_entry.activity][unit_rate][:value] += (entry.hours.zero? ? entry.custom_field_value(count_cf).to_f : entry.hours)
          if @projects[current_project][activity_entry.activity][unit_rate][:fix] == true
            @projects[current_project][activity_entry.activity][unit_rate][:fix] = false if entry.hours > 0
          end
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
  
  def footer_note
    [EasySetting.value(:easy_invoicing_footer_note, @project).presence, periode_of_performance_note].compact.join("\ns")
  end
  
  def periode_of_performance_note
    I18n.t("note_periode_of_perfomance", locale: @locale, from: @performance_from.to_s, to: @performance_to.to_s)
  end
  
  def build_line_items
    result = []

    @projects.each do |project, activities|
      activities.each do |activity, values|
        
        # If hours is zero - we have a fixed value, 
        # count is total / unit_rate
        values.each do |rate, rate_entry|
          result << EasyInvoiceLineItem.new({
            name: "#{project.name} - #{activity.easy_translated_name(locale: @locale)}",
            unit_price: rate,
            quantity: rate_entry[:value],
            unit_name: I18n.t(rate_entry[:fix] ? "label_pcs" : "label_hours", locale: @locale),
            vat_rate: EasySetting.value('easy_invoicing_default_vat_rate', project),
            time_entry_ids: rate_entry[:entry_ids]
            # TODO store entry_ids for line itemn JOIN TABLE to build invoice-entry  association after saving the invoice
          })
        end
      end  
    end
    
    return result
  end
    
end