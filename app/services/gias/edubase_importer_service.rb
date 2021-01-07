module GIAS
  class EdubaseImporterService
    include ServicePattern

    def initialize(file: nil)
      @local_file = file
    end

    def call
      import_establishments(establishments_csv_contents)
    end

    def import_establishments(csv_data)
      establishments_csv = CSV.new(
        csv_data,
        headers: true,
        encoding: "Windows-1252",
      )

      GIASEstablishment.transaction do
        GIASEstablishment.delete_all

        establishments_csv.each do |record|
          next if record["EstablishmentStatus (name)"] == "Open"

          GIASEstablishment.create!(
            urn: record["URN"],
            name: record["EstablishmentName"],
            postcode: record["Postcode"],
          )
        end
      end

      # establishment_links_csv = download_establishments_links_csv
    end

    def establishments_filename
      Date.today.strftime(Settings.gias.all_establishments_csv_file)
    end

    def local_establishments_path
      File.join(Dir.tmpdir, establishments_filename)
    end

    def establishments_csv_contents
      @establishments_csv ||=
        if File.exists? local_establishments_path
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

    def update_postcode_matches
      GIASEstablishment.transaction do
        GIASEstablishment.connection.execute(<<~EOSQL)
          TRUNCATE gias_establishment_provider_postcode_matches;
        EOSQL

        GIASEstablishment.connection.execute(<<~EOSQL)
          INSERT INTO gias_establishment_provider_postcode_matches (provider_id, establishment_id)
                 SELECT p.id AS provider_id, e.id AS establishment_id
                        FROM provider AS p
                        JOIN gias_establishment AS e
                             ON p.postcode != '' AND UPPER(TRIM(e.postcode))=UPPER(TRIM(p.postcode));
        EOSQL
      end
    end

    # def download_establishment_links_csv
    #   url = Date.today.strftime(Settings.gias.all_establishment_links_csv_base)
    #   response = Faraday.get(url)
    #   response.body
    # end
  end
end
