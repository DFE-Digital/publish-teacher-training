module GIAS
  class EdubaseImporterService
    include ServicePattern

    def initialize(file: nil)
      @local_file = file
    end

    def call
      import_establishments(establishments_csv_contents)
      update_provider_postcode_matches
      update_site_postcode_matches
      update_provider_name_matches
      update_site_name_matches
    end

    def import_establishments(csv_data)
      establishments_csv = CSV.new(
        csv_data,
        headers: true,
        encoding: "Windows-1252",
      )

      GIASEstablishment.transaction do
        GIASEstablishment.delete_all

        gias_establishments = establishments_csv.each.map do |record|
          next if record["EstablishmentStatus (name)"] == "Open"

          {
            urn: record["URN"].present? ? record["URN"] : nil,
            ukprn: record["UKPRN"].present? ? record["UKPRN"] : nil,
            name: record["EstablishmentName"],
            postcode: record["Postcode"].present? ? record["Postcode"] : nil,
          }
        end.compact

        GIASEstablishment.insert_all!(gias_establishments)
      end
    end

    def establishments_filename
      Date.today.strftime(Settings.gias.all_establishments_csv_file)
    end

    def local_establishments_path
      File.join(Dir.tmpdir, establishments_filename)
    end

    def establishments_csv_contents
      @establishments_csv ||=
        if File.exist? local_establishments_path
          File.binread(local_establishments_path)
        else
          csv = download_establishments_csv
          File.binwrite(local_establishments_path, csv)
          csv
        end
    end

    def download_establishments_csv
      url = URI.join(
        Settings.gias.establishments_csv_base,
        establishments_filename,
      )
      response = Faraday.get(url)
      response.body
    end

    def update_provider_postcode_matches
      GIASEstablishment.transaction do
        GIASEstablishment.connection.execute(<<~EOSQL)
          TRUNCATE gias_establishment_provider_postcode_matches;
        EOSQL

        year = Settings.current_recruitment_cycle_year
        GIASEstablishment.connection.exec_query(<<~EOSQL)
          INSERT INTO gias_establishment_provider_postcode_matches (provider_id, establishment_id)
                 SELECT p.id AS provider_id, e.id AS establishment_id
                        FROM provider AS p
                        JOIN gias_establishment AS e
                             ON UPPER(TRIM(e.postcode))=UPPER(TRIM(p.postcode))
                        JOIN recruitment_cycle AS rc
                             ON p.recruitment_cycle_id = rc.id
                        WHERE p.postcode != ''
                              AND rc.year = '#{year}'
        EOSQL
      end
    end

    def update_site_postcode_matches
      GIASEstablishment.transaction do
        GIASEstablishment.connection.execute(<<~EOSQL)
          TRUNCATE gias_establishment_site_postcode_matches;
        EOSQL

        year = Settings.current_recruitment_cycle_year
        GIASEstablishment.connection.execute(<<~EOSQL)
          INSERT INTO gias_establishment_site_postcode_matches (site_id, establishment_id)
                 SELECT s.id AS site_id, e.id AS establishment_id
                        FROM site AS s
                        JOIN gias_establishment AS e
                             ON UPPER(TRIM(e.postcode))=UPPER(TRIM(s.postcode))
                        JOIN provider AS p
                             ON p.id = s.provider_id
                        JOIN recruitment_cycle AS rc
                             ON p.recruitment_cycle_id = rc.id
                        WHERE s.postcode != ''
                              AND rc.year = '#{year}'
        EOSQL
      end
    end

    def update_provider_name_matches
      GIASEstablishment.transaction do
        GIASEstablishment.connection.execute(<<~EOSQL)
          TRUNCATE gias_establishment_provider_name_matches;
        EOSQL

        year = Settings.current_recruitment_cycle_year
        GIASEstablishment.connection.execute(<<~EOSQL)
          INSERT INTO gias_establishment_provider_name_matches (provider_id, establishment_id)
                 SELECT p.id AS provider_id, e.id AS establishment_id
                        FROM provider AS p
                        JOIN recruitment_cycle AS rc
                             ON p.recruitment_cycle_id = rc.id
                        JOIN gias_establishment AS e
                             ON LOWER(TRIM(e.name))=LOWER(TRIM(p.provider_name))
                        WHERE rc.year = '#{year}'
        EOSQL
      end
    end

    def update_site_name_matches
      GIASEstablishment.transaction do
        GIASEstablishment.connection.execute(<<~EOSQL)
          TRUNCATE gias_establishment_site_name_matches;
        EOSQL

        year = Settings.current_recruitment_cycle_year
        GIASEstablishment.connection.execute(<<~EOSQL)
          INSERT INTO gias_establishment_site_name_matches (site_id, establishment_id)
                 SELECT s.id AS site_id, e.id AS establishment_id
                        FROM site AS s
                        JOIN gias_establishment AS e
                             ON LOWER(TRIM(e.name))=LOWER(TRIM(s.location_name))
                        JOIN provider AS p
                             ON p.id = s.provider_id
                        JOIN recruitment_cycle AS rc
                             ON p.recruitment_cycle_id = rc.id
                        WHERE rc.year = '#{year}'
        EOSQL
      end
    end
  end
end
