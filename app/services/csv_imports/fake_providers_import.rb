require "csv"

module CSVImports
  class FakeProvidersImport
    attr_reader :results

    def initialize(path_to_csv)
      @results = []
      @path_to_csv = path_to_csv
    end

    def execute
      CSV.foreach(@path_to_csv, headers: true) do |row|
        provider_name = row["name"]
        provider_code = row["code"]
        provider_type = row["type"]
        is_accredited_body = ActiveModel::Type::Boolean.new.cast(row["accredited_body"])

        service = Providers::CreateFakeProviderService.new(
          recruitment_cycle: RecruitmentCycle.current,
          provider_name: provider_name,
          provider_code: provider_code,
          provider_type: provider_type,
          is_accredited_body: is_accredited_body,
        )

        @results << if service.execute
                      "Created provider #{provider_name}."
                    else
                      service.errors.join(" ")
                    end
      end
    end
  end
end
