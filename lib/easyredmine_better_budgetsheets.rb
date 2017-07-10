module BetterBudgetsheets

  CONFIG_FILE_PATH = "#{Rails.root}/config/better_budgetsheets.yml"
  DEFAULT_GROUPED_FIELDS = [:project_id, :issue_id]

  GROUPED_FIELDS = if File.exists?(CONFIG_FILE_PATH)
    fields = YAML::load(File.open(CONFIG_FILE_PATH).read)['grouped_fields']
    fields.any? ? fields : DEFAULT_GROUPED_FIELDS
  else
    DEFAULT_GROUPED_FIELDS
  end

end

require "better_budgetsheets/hooks"
require "better_budgetsheets/time_entry_grouping_service"