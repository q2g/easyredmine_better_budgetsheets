class BetterBudgetsheetsFacturaController < ApplicationController

  include BetterBudgetsheetsHelper
  helper :better_budgetsheets

  def new
    @time_entries = TimeEntry.where(id: params[:time_entry_ids])
    @column_names = params[:columns]
    @query_name   = params[:query_name] || "Budgetsheet"

    @time_range = {
      from: @time_entries.pluck(:spent_on).min.strftime("%d.%m.%Y"),
      to: @time_entries.pluck(:spent_on).max.strftime("%d.%m.%Y")
    }

    @time_entry_groups = BetterBudgetsheets::TimeEntryGroupingService.new(@time_entries, columns: @column_names)
    @time_entry_groups.load_root_set

    render template: "/better_budgetsheets_factura/sheet"
  end

end