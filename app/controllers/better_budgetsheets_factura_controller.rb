class BetterBudgetsheetsFacturaController < ApplicationController

  include BetterBudgetsheetsHelper
  helper :better_budgetsheets

  def new
    load_data

    render template: "/better_budgetsheets_factura/sheet"
  end

  def print
    load_data
    render  pdf: @query_name,
            template: "/better_budgetsheets_factura/sheet",
            layout: "pdf",
            orientation: 'Landscape',
            footer: { right: '[page] / [topage]', left: "#{@query_name} #{Time.now.to_date.to_de}" }
  end

  private

  def load_data
    @time_entries = TimeEntry.where(id: params[:time_entry_ids])
    @column_names = params[:columns]
    @query_name   = params[:query_name] || "Budgetsheet"

    @time_range = {
      from: @time_entries.pluck(:spent_on).min.strftime("%d.%m.%Y"),
      to: @time_entries.pluck(:spent_on).max.strftime("%d.%m.%Y")
    }

    @time_entry_groups = BetterBudgetsheets::TimeEntryGroupingService.new(@time_entries, columns: @column_names)
    @time_entry_groups.load_root_set
  end

end