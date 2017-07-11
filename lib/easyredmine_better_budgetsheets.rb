module BetterBudgetsheets

  CONFIG_FILE_PATH = "#{Rails.root}/config/better_budgetsheets.yml"
  DEFAULT_GROUPED_FIELDS = [:project_id, :issue_id]
  DEFAULT_STYLES         = {
    header_color:         '#fff',
    header_background:    '#0093de',
    highlight_color:      '#000',
    highlight_background: '#b1e5ff',
    border_color:         '#000',
    row_background:       '#efefef',
    logo_url:             'https://www.easyredmine.com/images/Easy_Redmine_Logo_min.svg'
  }

  def self.config
    if File.exists?(CONFIG_FILE_PATH)
      YAML::load(File.open(CONFIG_FILE_PATH).read)
    else
      {}
    end
  end

  def self.grouped_fields
    if self.config['grouped_fields'] && self.config['grouped_fields'].any?
      self.config['grouped_fields']
    else
      DEFAULT_GROUPED_FIELDS
    end
  end


  def self.styles
    if self.config['style']
      self.config['style'].symbolize_keys
    else
      DEFAULT_STYLES
    end
  end



end

require "better_budgetsheets/hooks"
require "better_budgetsheets/time_entry_grouping_service"