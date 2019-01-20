module BetterBudgetsheets
  class Hooks < Redmine::Hook::ViewListener

    def view_time_entries_context_menu_end(context = {})
      # try getting column names from query url of given query
      parsed_query_params = Rack::Utils.parse_query(
      URI(context[:controller].request.env['HTTP_REFERER']).query
      )

      additional_params = {}
      query = nil
      
      if parsed_query_params['query_id']
        query = EasyQuery.find(parsed_query_params['query_id'])
        additional_params[:query_name] = query.name
        additional_params[:columns]    = query.column_names
      elsif parsed_query_params["[column_names][]"]
        additional_params[:columns] = parsed_query_params["[column_names][]"]
      end

      if parsed_query_params['group_by[]']
        additional_params[:groups] = parsed_query_params['group_by[]']
      elsif query
        additional_params[:groups] = query.group_by
      end
      
      additional_params[:sort] = parsed_query_params['sort'] || query.try(:sort_criteria)
      
      # js for opening factura and reload parent page
      factura_js = "window.open('#{better_budgetsheets_factura_print_path(additional_params.merge(:time_entry_ids => context[:time_entries].collect(&:id)))}', '_blank');window.focus();location.reload();"
      links = []
      if additional_params[:columns] && additional_params[:groups]
        
        additional_params[:sort] = additional_params[:sort].to_json if additional_params[:sort].present?

        links << content_tag(:li, context[:hook_caller].context_menu_link(l(:button_better_budgetsheet_preview_factura),
        better_budgetsheets_factura_new_path(additional_params.merge(:time_entry_ids => context[:time_entries].collect(&:id))),
        :class => 'icon icon-table'
        ))
        
        
        links << content_tag(:li, context[:hook_caller].context_menu_link(l(:button_better_budgetsheet_create_factura), '#', :class => 'icon icon-print', onclick: factura_js)) 
        
      end
      
      
      # TODO: Take care for restrictions (billable, locked etc...)  
      # TODO: Filter only projects qith invoicing module enabled
      context[:time_entries].map(&:project).uniq.each do |project|
        if project.module_enabled?('easy_invoicing')
          links << content_tag(:li, context[:hook_caller].context_menu_link(l(:button_better_budgetsheet_create_invoice, project_name: project.name),
          better_budgetsheets_invoices_new_path(additional_params.merge(project_id: project.id, :time_entry_ids => context[:time_entries].collect(&:id))),
          :class => 'icon icon-table'
          ))
        end  
      end

      links.flatten.join("").html_safe
    end
    
    def easy_invoicing_invoice_details_bottom(context = {})
      context[:hook_caller].render "/easy_invoices/query_and_line_item_settings", f: context[:f], invoice: context[:invoice]
    end
    
    def edit_easy_invoice_line_item_first_td(context = {})
      context[:hook_caller].render "/easy_invoices/line_items_first_td", f: context[:f]
    end
  end
end