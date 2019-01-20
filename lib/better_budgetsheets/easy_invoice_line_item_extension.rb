module BetterBudgetsheets::EasyInvoiceLineItemExtension
  
  extend ActiveSupport::Concern
  
  included do
    after_save :store_line_item_time_entries
    has_many :easy_invoice_line_items_time_entries, dependent: :destroy
  end
  
  def time_entry_ids
    @time_entry_ids ||= EasyInvoiceLineItemsTimeEntry.where(easy_invoice_line_item_id: self.id).pluck(:time_entry_id)
  end
  
  def time_entry_ids=(val)
    @time_entry_ids = val.is_a?(Array) ? val : val.split(" ")
  end
  
  def store_line_item_time_entries
    # cleanup existing entries
    easy_invoice_line_items_time_entries.delete_all
    time_entry_ids.each do |i|
      EasyInvoiceLineItemsTimeEntry.create(easy_invoice_id: self.easy_invoice_id, easy_invoice_line_item_id: self.id, time_entry_id: i)
    end
  end
  
end