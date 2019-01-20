class AddQueryIdToEasyInvoice < ActiveRecord::Migration

  def change
    add_column :easy_invoices, :easy_budget_sheet_query_id, :integer
  end

end