class BetterBudgetsheetsInvoicesController < ApplicationController
  
  helper :easy_invoices
  include EasyInvoicesHelper
  
  def new
    @line_item_generator = BetterBudgetsheets::TimeEntryLineItemGenerator.new(params[:time_entry_ids], params[:project_id])
    @project = @line_item_generator.project
    
    build_invoice
    
    unless User.current.allowed_to?(:easy_invoicing_edit_date_issued, @project)
      flash.now[:error] = l(:permission_easy_invoicing_edit_issued_at_message)
    end
    unless EasySetting.value(:easy_invoicing_easy_invoice_sequence_id, @project).present?
      flash[:warning] = l(:easy_invoicing_error_sequence_not_set)
    end

    @easy_invoice.note        ||= EasySetting.value :easy_invoicing_note, @project
    @easy_invoice.footer_note ||= EasySetting.value(:easy_invoicing_footer_note, @project)
    
    @easy_invoice.transferred_tax_liability_note ||= EasySetting.value :easy_invoicing_transferred_tax_liability_note, @project
    @easy_invoice.status         ||= EasyInvoiceStatus.default
    @easy_invoice.payment_method ||= EasyInvoicePaymentMethod.default

    if EasyInvoicing::easy_contacts_enabled?
      @easy_invoice.supplier  ||= EasyContact.find_by(id: EasySetting.value(:easy_invoicing_supplier_id, @project))
      @easy_invoice.client    ||= EasyContact.find_by(id: EasySetting.value(:easy_invoicing_client_id, @project))
    end
    
    render template: "/easy_invoices/new"
  end
  
  private
  def build_invoice
    @easy_invoice = EasyInvoice.new(:project => @project)
    @easy_invoice.footer_note = @line_item_generator.footer_note
    @easy_invoice.easy_invoice_line_items = @line_item_generator.line_items
    @easy_invoice.easy_line_item_time_entry_settings = @line_item_generator.line_items.map {|l| }
    @easy_invoice.performance_from  = @line_item_generator.performance_from
    @easy_invoice.performance_to    = @line_item_generator.performance_to
  end
  
end