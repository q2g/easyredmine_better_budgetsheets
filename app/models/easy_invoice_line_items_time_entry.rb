class EasyInvoiceLineItemsTimeEntry < ActiveRecord::Base
  
  belongs_to :easy_invoice
  belongs_to :easy_invoice_line_item
  belongs_to :time_entry
  
  validates_presence_of :easy_invoice, :easy_invoice_line_item, :time_entry
  
  validates_uniqueness_of :time_entry
  
end