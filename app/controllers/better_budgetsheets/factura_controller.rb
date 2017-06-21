class BetterBudgetsheets::FacturaController < ApplicationController

  def create
    @time_entries = TimeEntry.where(id: params[:time_entry_ids])


    groups = BetterBudgetsheets::TimeEntryGroupingService.new(@time_entries)



    binding.pry
  end

end