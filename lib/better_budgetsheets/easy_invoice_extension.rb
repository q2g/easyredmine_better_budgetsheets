module BetterBudgetsheets::EasyInvoiceExtension
  
  extend ActiveSupport::Concern
  
  included do
    attr_accessor :easy_line_item_time_entry_settings
    has_many :easy_invoice_line_item_time_entries
    belongs_to :easy_budget_sheet_query
    
    safe_attributes *%w{performance_from performance_to easy_budget_sheet_query_id}
  end
  
  def query_params_for_factura_sheet
    url_params = {}
    url_params[:query_name] = easy_budget_sheet_query.name
    url_params[:columns]    = easy_budget_sheet_query.column_names
    url_params[:query_name] = easy_budget_sheet_query.name
    url_params[:columns]    = easy_budget_sheet_query.column_names
    url_params[:sort]       = easy_budget_sheet_query.try(:sort_criteria)
    
    return url_params
  end
  
  def load_and_assign_factura_sheet_file
    # TODO
  end
  
end