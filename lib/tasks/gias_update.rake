# frozen_string_literal: true

require 'csv'

desc 'Upsert GIAS data into GiasSchool'
task :gias_update, [:csv_path] => [:environment] do |_, args|
  csv_path = args.csv_path
  CSVImports::GiasImport.new(csv_path).execute
end
