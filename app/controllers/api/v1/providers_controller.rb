module Api
  module V1
    class ProvidersController < ApplicationController
      # Potential edge case:
      # It is possible for older updated_at values to written to the database after this API has been queried for changes. This would mean that these changes are missed when the client makes a subsequent request using the next-link.
      # Possible causes of older updated_at values:
      # - delay between c# calculating datetime.UtcNow and value being written to postgres
      # - clock drift between servers
      def index
        page_size = params[:per_page] || 100
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.execute('LOCK provider, provider_enrichment, site IN SHARE UPDATE EXCLUSIVE MODE')
          @providers = Provider.changed_since(params[:changed_since]).limit(page_size)
        end
        last_provider = @providers.last

        response.headers['Link'] = if last_provider
                                     next_link((last_provider.updated_at + 1.second).utc.iso8601, last_provider.id, page_size)
                                   else
                                     next_link(params[:changed_since], "", page_size)
                                   end

        render json: @providers
      rescue ActiveRecord::StatementInvalid
        render json: { status: 400, message: 'Invalid changed_since value, the format should be a iso8601 timestamp' }.to_json, status: 400
      end

    private

      def next_link(changed_since, from_provider_id, per_page)
        current_url = request.base_url + request.path
        "#{current_url}?changed_since=#{changed_since}&from_provider_id=#{from_provider_id}&per_page=#{per_page}; rel=\"next\""
      end
    end
  end
end
