# frozen_string_literal: true

desc "Create subject areas and populate subjects"
task populate_design_technology_subjects: :environment do
  Subjects::DesignTechnologySubjectCreatorService.new.execute

  puts "All Design & Technology subjects populated successfully!"
end
