Redmine::Plugin.register :easyredmine_better_budgetsheets do
  name 'BetterBudgetsheets for EasyRedmine'
  author 'Florian Eck for akquinet'
  description 'Improve handling and output of easyredmine budgetsheets'
  version '1.0'

end

require 'easyredmine_better_budgetsheets'


Rails.application.config.after_initialize do
  view_path = File.expand_path("../app/views", __FILE__)
  ActionController::Base.prepend_view_path(view_path)
end
