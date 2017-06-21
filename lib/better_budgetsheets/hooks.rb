module BetterBudgetsheets
  class Hooks < Redmine::Hook::ViewListener

    def view_time_entries_context_menu_end(context = {})
      content_tag(:li, context[:hook_caller].context_menu_link(l(:button_better_budgetsheet_create_factura),
          better_budgetsheets_factura_create_path(context[:project], :time_entry_ids => context[:time_entries].collect(&:id)),
          :class => 'icon icon-print'
        ))
    end

  end
end