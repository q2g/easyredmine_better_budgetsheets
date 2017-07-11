module BetterBudgetsheetsHelper

  def bugdet_sheet_display_value_for(time_entry, col)
    value = nil

    @summed_up_values ||= {}

    # assignment, not comparing
    if cf = budget_sheet_cf_from_col_name(col)

      case cf.type
      when 'IssueCustomField'
        value =time_entry.issue.custom_field_value(cf.id)
      when 'ProjectCustomField'
        value = time_entry.project.custom_field_value(cf.id)
      when 'TimeEntryCustomField'
        value = time_entry.custom_field_value(cf.id)
      end
    else
      value = time_entry.send(col)
    end

    if value.is_a?(Date) || value.is_a?(DateTime)
      value.to_de
    elsif value.is_a?(ActiveSupport::TimeWithZone)
      value.localtime.to_de
    elsif value.is_a?(Numeric)
      @summed_up_values[col] ||= 0
      @summed_up_values[col] += value
      value
    elsif (Date.parse(value) rescue nil).is_a?(Date)
      Date.parse(value).to_de
    else
      value
    end

  end

  def bugdet_sheet_column_for(time_entry, col)
    v = bugdet_sheet_display_value_for(time_entry, col)
    css = ""
    if v.is_a?(Numeric)

      v = v.to_euro(budget_sheet_number_suffix(col))
      css = "text-right"
    end

    content_tag :td, v, class: css
  end

  def budget_sheet_number_suffix(col)
    if col.match(/rate|money/)
      'EUR'
    elsif col.match(/hour/)
      "h"
    else
      nil
    end
  end

  def budget_sheet_header_label(col)
    budget_sheet_cf_from_col_name(col).try(:name) || I18n.t(col, scope: 'better_budgetsheets.columns')
  end

  def budget_sheet_cf_from_col_name(col)
    @_cfs_from_cols ||= {}
    if col.to_s.match(/cf_/)
      @_cfs_from_cols[col] ||= CustomField.find(col.to_s.match(/[0-9]{1,}/).to_s)
    end
    @_cfs_from_cols[col]
  end

end