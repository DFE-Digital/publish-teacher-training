# frozen_string_literal: true

require 'csv'

CSV_PATH = Rails.root.join('csv/edubasealldata20230306.csv').freeze

desc 'Upsert GIAS data into GiasSchool'
task :gias_update, [:csv_path] => [:environment] do |_, args|
  csv_path = args.csv_path || CSV_PATH
  CSVImports::GiasImport.call(csv_path)
end
