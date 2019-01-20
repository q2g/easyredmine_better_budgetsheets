module BetterBudgetsheets::EasyInvoiceExtension
  
  extend ActiveSupport::Concern
  
  included do
    attr_accessor :easy_line_item_time_entry_settings
    has_many :easy_invoice_line_item_time_entries
    belongs_to :easy_budget_sheet_query
  end
  
end