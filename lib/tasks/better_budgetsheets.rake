namespace :better_budgetsheets do

  desc "Copy empty config file for defining grouped columns/fields"
  task :setup_config => :environment do
    unless File.exists?(BetterBudgetsheets::CONFIG_FILE_PATH)
      File.open(BetterBudgetsheets::CONFIG_FILE_PATH, "w") do |f|
        f.puts YAML::dump({
          'grouped_fields' => []
        })
      end
    else
      puts "Config file already exists under #{BetterBudgetsheets::CONFIG_FILE_PATH}"
    end

  end

end