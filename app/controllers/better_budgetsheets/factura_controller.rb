class BetterBudgetsheets::FacturaController < ApplicationController

  def create
    @time_entries = TimeEntry.where(id: params[:time_entry_ids])
    @column_names = params[:columns]
    @query_name   = params[:query_name] || "Budgetsheet"

    @time_range = {
      from: @time_entries.pluck(:spent_on).min.strftime("%d.%m.%Y"),
      to: @time_entries.pluck(:spent_on).max.strftime("%d.%m.%Y")
    }

    @time_entry_groups = BetterBudgetsheets::TimeEntryGroupingService.new(@time_entries)
    @time_entry_groups.load_root_set

    render template: "better_budgetsheets/sheet"
  end

end