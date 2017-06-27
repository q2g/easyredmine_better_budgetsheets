module BetterBudgetsheets
  class Hooks < Redmine::Hook::ViewListener

    def view_time_entries_context_menu_end(context = {})
      # try getting column names from query url of given query
      parsed_query_params = Rack::Utils.parse_query(
        URI(context[:controller].request.env['HTTP_REFERER']).query
      )

      additional_params = {}

      if parsed_query_params['query_id']
        query = EasyQuery.find(parsed_query_params['query_id'])
        additional_params[:query_name] = query.name
        additional_params[:columns]    = query.column_names
      elsif parsed_query_params["[column_names][]"]
        additional_params[:columns] = parsed_query_params["[column_names][]"]
      end


      if additional_params[:columns]

        content_tag(:li, context[:hook_caller].context_menu_link(l(:button_better_budgetsheet_create_factura),
            better_budgetsheets_factura_create_path(
              context[:project], :time_entry_ids => context[:time_entries].collect(&:id)
            ).merge(additional_params),
            :class => 'icon icon-print'
          ))
      end
    end

  end
end