module BetterBudgetsheetsHelper
  
  include SortHelper
  
  def bugdet_sheet_display_value_for(time_entry, col, options = {})
    value = nil
    puts "bugdet_sheet_display_value_for\nbefore:\ne/x:"
    puts time_entry
    puts "\ncol/s:"
    puts col
    @summed_up_values ||= {}

    # assignment, not comparing
    if cf = budget_sheet_cf_from_col_name(col)

      case cf.type
      when 'IssueCustomField' 
        value = time_entry.issue.custom_field_value(cf.id)
      when 'ProjectCustomField'
        value = time_entry.project.custom_field_value(cf.id)
      when 'TimeEntryCustomField'
        value = time_entry.custom_field_value(cf.id)
      end
      case cf.field_format
      when 'user'
        value = User.find_by(id: value)
      when 'int'
        value = value.to_i
      when 'date'
        value =  Date.parse(value)
      when 'datetime'    
        value =  DateTime.parse(value)
      end
      puts "value:"
      puts value
      puts "Breakpoint"

    else
      puts "col:"
      puts col
      #col = col == "asc"? "activity" : col #overwrite col if value is asc; just for testing
      puts "col:"
      puts col
      if(col=="asc")
        puts "col IS_ASC"
      #else
      	#value = time_entry.send(col)
      end
      value = time_entry.send(col)
      #value = time_entry.send("asc") #for debugging, remove later
      #value = time_entry.send("activity") #for debugging, remove later
      #value = time_entry.send("") #for debugging, remove later
      #value = time_entry.send("wrongvalue") #for debugging, remove later
      puts "value:"
      puts value
      puts "Breakpoint"
    end
    
    if options[:value_only] == true
      value
    else
      if value.is_a?(Date) || value.is_a?(DateTime)
        value.to_de
      elsif value.is_a?(ActiveSupport::TimeWithZone)
        value.localtime.to_de
      elsif value.is_a?(Numeric)
        @summed_up_values[col] ||= {}
        suffix = budget_sheet_number_suffix(col, time_entry)
        @summed_up_values[col][suffix] ||= 0
        # grouping for different units

        @summed_up_values[col][suffix] += value
        puts "bugdet_sheet_display_value_for\nvalue:"
        puts value
        value
      else
        puts "bugdet_sheet_display_value_for\nvalue:"
        puts value
        value
      end
    end
    puts "after:\ne/x:"
    puts time_entry
    puts "\ncol/s:"
    puts col
    puts "Breakpoint"
  end
  
  def sorted_entries(entries, sorting = nil)
    if sorting.present?
      puts "sorting unsorted"
      puts sorting
      sorting = Array.wrap(sorting)
      puts "sorting sorted"
      puts sorting
      puts "breakpoint"

      #puts "sorted_entries\nbefore loops:\ne:\n"
      #puts e
      entries.sort_by do |e|
        sorting.map do |s|
          current_value = if s.is_a?(Array)
            x = bugdet_sheet_display_value_for(e, s[0], value_only: true)
            #s[1]=nil #for testing purposes, has to be removed later
            if x.is_a?(Numeric) || x.is_a?(Date) || x.is_a?(DateTime) || x.is_a?(ActiveSupport::TimeWithZone)
              puts "sorted_entries\nbefore asc:\ns:\n"
              puts s #show array content
              puts "x:"
              puts x
              if(s[1] == 'asc')
                puts "X_STRING:"
                puts x
                puts "X_INT:"
                puts x.to_i
                puts "s[1] IS_ASC"
              else
                puts "s[1] NOT_ASC"
              end
              s[1] == 'asc' ? x : x.to_i * -1 #asc might cause an error
              puts "after asc:\ns:"
              puts s #show array content
              puts "x:"
              puts x
              puts "Breakpoint\n"
            else
              puts "sorted_entries-else\nbefore x:\ns:\n"
              puts s #show array content
              puts "x:"
              puts x
              x
            end
          else
            bugdet_sheet_display_value_for(e,s, value_only: true)
          end
        end
      end
    else
      entries
    end
  end

  def bugdet_sheet_column_for(time_entry, col)
    v = bugdet_sheet_display_value_for(time_entry, col)
    css = ""
    if v.is_a?(Numeric)

      if budget_sheet_cf_from_col_name(col).try(:field_format) == 'int'
        v = v.to_de
      else  
        v = v.to_euro(budget_sheet_number_suffix(col, time_entry))
      end  
      css = "text-right"
    end

    content_tag :td, v.to_s.replace_entities, class: css
  end

  def budget_sheet_number_suffix(col, time_entry)
    if is_money_value?(col)
      if time_entry.project.easy_currency
        time_entry.project.easy_currency.symbol.presence || time_entry.project.easy_currency.iso_code.presence
      else
        ""
      end
    elsif col.match(/hour/)
      "h"
    else
      ""
    end
  end

  def is_money_value?(col)
    col.match(/rate|money/)
  end

  def budget_sheet_header_label(col)
    # first, checking if column in yaml file is present
    I18n.t(col, 
      scope: 'better_budgetsheets_columns',
      default: (budget_sheet_cf_from_col_name(col).try(:name) || I18n.t("field_#{col}"))
    ).replace_entities  
  end

  def budget_sheet_cf_from_col_name(col)
    @_cfs_from_cols ||= {}
    if col.to_s.match(/cf_/)
      @_cfs_from_cols[col] ||= CustomField.find(col.to_s.match(/[0-9]{1,}/).to_s)
    end
    @_cfs_from_cols[col]
  end

end
