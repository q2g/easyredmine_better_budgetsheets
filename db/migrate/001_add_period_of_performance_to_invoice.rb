class AddPeriodOfPerformanceToInvoice < ActiveRecord::Migration
  
  def change
    add_column :easy_invoices, :performance_from, :date
    add_column :easy_invoices, :performance_to, :date
  end
  
end