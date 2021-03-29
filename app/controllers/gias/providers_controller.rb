module GIAS
  class ProvidersController < GIAS::ApplicationController
    before_action :build_filters, only: :index

    def index
      recruitment_cycle = RecruitmentCycle.current
      providers = recruitment_cycle.providers

      if @filters.provider == "name"
        providers = providers.that_match_establishments_by_name.distinct
      elsif @filters.provider == "postcode"
        providers = providers.that_match_establishments_by_postcode.distinct
      elsif @filters.provider == "name_and_postcode"
        providers = providers.that_match_establishments_by_name_and_postcode.distinct
      elsif @filters.provider == "name_or_postcode"
        providers = providers.where(id: providers.that_match_establishments_by_name.pluck(:id) \
                                        + providers.that_match_establishments_by_postcode.pluck(:id)).distinct
      end

      if @filters.site == "name"
        providers = providers.with_sites_that_match_establishments_by_name.distinct
      elsif @filters.site == "postcode"
        providers = providers.with_sites_that_match_establishments_by_postcode.distinct
      elsif @filters.site == "name_and_postcode"
        providers = providers.with_sites_that_match_establishments_by_name_and_postcode.distinct
      elsif @filters.site == "name_or_postcode"
        providers = providers.where(id: providers.with_sites_that_match_establishments_by_name.pluck(:id) \
                                        + providers.with_sites_that_match_establishments_by_postcode.pluck(:id)).distinct
      end

      providers = providers.search_by_code_or_name(@filters.search).distinct(false) if @filters.search.present?

      respond_to do |format|
        format.html do
          @provider_total_count = providers.count
          @csv_url_object = URI.parse(request.url)
          @csv_url_object.path = @csv_url_object.path + ".csv"
          @csv_url = @csv_url_object.to_s
          @pagy, @providers = pagy(providers.reorder(:id))

          render
        end

        format.csv do

          if @filters.site != "all"
            csv = generate_provider_sites_establishment_csv(providers)
            send_data csv, filename: "provider_sites_establishment_matches.csv"
          else
            csv = generate_provider_establishment_csv(providers)
            send_data csv, filename: "provider_establishment_matches.csv"
          end

        end
      end

    end

    def show
      @provider = Provider.find(params[:id])

      graph = GIAS::ProviderGraphGeneratorService.call(provider: @provider)
      graph.output(cmapx: cmapx_filename)
      @graph_cmapx = File.read(cmapx_filename)

    end

    def graph
      @provider = Provider.find(params[:id])

      # unless File.exist?(png_filename)
        @graph = GIAS::ProviderGraphGeneratorService.call(provider: @provider)
        @graph.output(png: png_filename)
      # end

      send_data File.read(png_filename), type: "image/png", disposition: "inline"
    end

  private

    def build_filters
      @filters = OpenStruct.new(
        provider: params.dig(:filters, :provider) || "",
        site:     params.dig(:filters, :site) || "",
        search:   params.dig(:filters, :search),
      )

      @filter_object = OpenStruct.new(
        provider: @filters.provider,
        site:     @filters.site,
        search:   @filters.search,
      )
    end

    def graph_filename
      @graph_filename ||= File.join(Dir.tmpdir, @provider.provider_name.underscore)
    end

    def png_filename
      "#{graph_filename}.png"
    end

    def cmapx_filename
      "#{graph_filename}.html"
    end

    def generate_provider_establishment_csv(providers)
      CSV.generate(force_quotes: true) do |csv|
        csv << %w{provider_code
                  provider_name
                  provider_postcode
                  establishment_ukprn
                  establishment_urn
                  establishment_name
                  establishment_postcode}
        providers.each do |provider|
          (provider.establishments_matched_by_name & provider.establishments_matched_by_postcode).each do |establishment|
            csv << [
              provider.provider_code,
              provider.provider_name,
              provider.postcode,
              establishment.ukprn,
              establishment.urn,
              establishment.name,
              establishment.postcode,
            ]
          end
        end
      end
    end

    def generate_provider_sites_establishment_csv(providers)
      CSV.generate(force_quotes: true) do |csv|
        csv << %w{provider_code
                  provider_name
                  provider_postcode
                  site_code
                  site_name
                  site_postcode
                  establishment_ukprn
                  establishment_urn
                  establishment_name
                  establishment_postcode}
        providers.each do |provider|
          provider.sites.that_match_establishments_by_name_and_postcode.each do |site|
            (site.establishments_matched_by_name & site.establishments_matched_by_postcode).each do |establishment|

              csv << [
                provider.provider_code,
                provider.provider_name,
                provider.postcode,
                site.code,
                site.location_name,
                site.postcode,
                establishment.ukprn,
                establishment.urn,
                establishment.name,
                establishment.postcode,
              ]
            end
          end
        end
      end
    end
  end
end
