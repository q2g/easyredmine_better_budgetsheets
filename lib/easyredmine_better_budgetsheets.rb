module BetterBudgetsheets

  CONFIG_FILE_PATH = "#{Rails.root}/config/better_budgetsheets.yml"

  GROUPED_FIELDS = if File.exists?(CONFIG_FILE_PATH)
    YAML::load(File.open(CONFIG_FILE_PATH).read)['grouped_fields']
  else
    [:project_id]
  end

end

require "better_budgetsheets/hooks"
require "better_budgetsheets/time_entry_grouping_service"