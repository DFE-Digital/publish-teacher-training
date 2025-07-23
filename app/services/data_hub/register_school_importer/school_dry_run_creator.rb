module DataHub
  module RegisterSchoolImporter
    class SchoolDryRunCreator < SchoolCreator
      # No-op: simulate creation only
      def create!(site, gias_school); end
    end
  end
end
