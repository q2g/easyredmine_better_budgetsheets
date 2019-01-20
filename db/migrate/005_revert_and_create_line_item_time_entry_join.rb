class RevertAndCreateLineItemTimeEntryJoin < ActiveRecord::Migration
  
  def change
    remove_column :easy_invoice_line_items, :time_entry_ids
    
    create_table :easy_invoice_line_items_time_entries do |t|
      t.integer :easy_invoice_line_item_id
      t.integer :time_entry_id
      t.integer :easy_invoice_id
      t.timestamps
    end
    
  end
  
end