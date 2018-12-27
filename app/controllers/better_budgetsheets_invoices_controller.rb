class BetterBudgetsheetsInvoicesController < ApplicationController
  
  def new
    build_invoice
    
    if @project
      unless User.current.allowed_to?(:easy_invoicing_edit_date_issued, @project)
        flash.now[:error] = l(:permission_easy_invoicing_edit_issued_at_message)
      end
      unless EasySetting.value(:easy_invoicing_easy_invoice_sequence_id, @project).present?
        flash[:warning] = l(:easy_invoicing_error_sequence_not_set)
      end

      @easy_invoice.note ||= EasySetting.value :easy_invoicing_note, @project
      @easy_invoice.footer_note ||= EasySetting.value :easy_invoicing_footer_note, @project
      @easy_invoice.transferred_tax_liability_note ||= EasySetting.value :easy_invoicing_transferred_tax_liability_note, @project
      @easy_invoice.status ||= EasyInvoiceStatus.default
      @easy_invoice.payment_method ||= EasyInvoicePaymentMethod.default

      if EasyInvoicing::easy_contacts_enabled?
        @easy_invoice.supplier ||= EasyContact.find_by(id: EasySetting.value(:easy_invoicing_supplier_id, @project))
        @easy_invoice.client ||= EasyContact.find_by(id: EasySetting.value(:easy_invoicing_client_id, @project))
      end
    else

      respond_to do |format|
        format.js
      end
    end
  end
  
  private
  def build_invoice
    @easy_invoice = new_easy_invoice_with_type
    set_variables_from_template
    @easy_invoice.safe_attributes = params[:easy_invoice]
    if @easy_invoice.easy_invoice_line_items.empty?
      if params[:time_entry_ids].present?
        return @easy_invoice.build_line_items_from_time_entries(TimeEntry.where(id: params[:time_entry_ids]))
      end

      if params[:issue_ids].present?
        @easy_invoice.build_line_items_from_issues(Issue.where(id: params[:issue_ids]))

        if EasyInvoicing::easy_money_enabled?(@project)
          @activity_rates = TimeEntryActivity.shared.sorted.map{|x| [x.name, EasyMoneyRate.get_unit_rate(EasySetting.value(:easy_invoicing_rate_type_id, @project).to_i, 'Enumeration', x.id, @project.try(:id))] }# unless unit_price
        end
        return
      end

      if params[:easy_crm_case_id].present? && EasyInvoicing::easy_crm_enabled?(@project)
        return @easy_invoice.build_from_easy_crm_case(EasyCrmCase.where(id: params[:easy_crm_case_id]).first)
      end

      default_vat_rate = EasySetting.value('easy_invoicing_default_vat_rate', @project)
      @easy_invoice.easy_invoice_line_items.build(
        vat_rate: default_vat_rate,
        quantity: 1,
        unit_price: ''
      )
    end
  end
  
  
end