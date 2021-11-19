module API
  module V2
    class ProvidersController < API::V2::ApplicationController
      before_action :get_user, if: -> { params[:user_id].present? }
      before_action :build_recruitment_cycle
      before_action :build_provider, except: %i[index suggest suggest_any]

      deserializable_resource :provider,
                              only: :update,
                              class: API::V2::DeserializableProvider

      def index
        authorize Provider

        providers = policy_scope(@recruitment_cycle.providers)
                      .include_courses_counts
                      .includes(:recruitment_cycle)
                      .by_name_ascending

        providers = providers.where(id: @user.providers) if @user.present?

        render jsonapi: paginate(providers, per_page: 10),
               meta: { count: providers.count(:provider_code) },
               fields: { providers: %i[provider_code
                                       provider_name
                                       courses
                                       recruitment_cycle_year] }
      end

      def show
        authorize @provider, :show?

        render jsonapi: @provider, include: params[:include]
      end

      # This endpoint ignores the policy and allows anyone to see the provider
      # This used by allocations, as any training provider can be used
      def show_any
        authorize @provider, :show_any?

        render jsonapi: @provider, include: params[:include]
      end

      def update
        authorize @provider, :update?

        update_provider
        update_accrediting_enrichment
        update_ucas_contacts
        update_ucas_preferences

        if @provider.valid?
          render jsonapi: @provider.reload, include: params[:include]
        else
          render jsonapi_errors: @provider.errors, status: :unprocessable_entity, include: params[:include]
        end
      end

      def suggest
        authorize Provider

        return render(status: :bad_request) if params[:query].nil? || params[:query].length < 2
        return render(status: :bad_request) unless begins_with_alphanumeric(params[:query])

        found_providers = policy_scope(@recruitment_cycle.providers)
          .search(params[:query])
          .limit(5)

        render(
          jsonapi: found_providers,
          class: { Provider: SerializableProviderSuggestion },
        )
      end

      # Suggest any provider from the current recruitment cycle
      def suggest_any
        authorize Provider

        return render(status: :bad_request) if params[:query].nil? || params[:query].length < 2
        return render(status: :bad_request) unless begins_with_alphanumeric(params[:query])

        scope = @recruitment_cycle.providers
                                  .search(params[:query])
                                  .limit(5)

        scope = scope.accredited_body if only_accredited_body_filter?

        render(
          jsonapi: scope,
          class: { Provider: SerializableProviderSuggestion },
        )
      end

    private

      def only_accredited_body_filter?
        params.dig(:filter, :only_accredited_body) == "true"
      end

      def begins_with_alphanumeric(string)
        string.match?(/^[[:alnum:]].*$/)
      end

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end

      def build_provider
        code = params.fetch(:code, params[:provider_code])
        @provider = @recruitment_cycle.providers
                      .find_by!(
                        provider_code: code.upcase,
                      )
      end

      def get_user
        @user = User.find(params[:user_id])
      end

      def update_accrediting_enrichment
        return if accredited_bodies_params.values.none?

        @provider.accrediting_provider_enrichments =
          accredited_bodies_params["accredited_bodies"].map do |accredited_body|
            {
              UcasProviderCode: accredited_body["provider_code"],
              Description: accredited_body["description"],
            }
          end

        @provider.save
      end

      def update_provider
        return if provider_params.values.all?(&:nil?)

        @provider.assign_attributes(provider_params)
        @provider.save
      end

      def update_ucas_contacts
        return if ucas_contact_params.blank?

        ucas_contact_params.each_key do |type|
          contact = @provider.contacts.find_or_initialize_by(type: type.gsub(/_contact$/, ""))
          contact.assign_attributes(ucas_contact_params[type])
          contact.save
        end
      end

      def update_ucas_preferences
        return if ucas_preferences_params.blank?

        if @provider.ucas_preferences.nil?
          @provider.ucas_preferences = ProviderUCASPreference.new
        end
        @provider.ucas_preferences.assign_attributes(ucas_preferences_params)
        @provider.ucas_preferences.save
      end

      def accredited_bodies_params
        params
          .fetch(:provider, {})
          .except(
            :train_with_us,
            :train_with_disability,
            :provider_name,
            :email,
            :telephone,
            :website,
            :address1,
            :address2,
            :address3,
            :address4,
            :postcode,
            :region_code,
            :admin_contact,
            :utt_contact,
            :web_link_contact,
            :fraud_contact,
            :finance_contact,
            :type_of_gt12,
            :gt12_contact,
            :application_alert_contact,
            :send_application_alerts,
            :ukprn,
            :urn,
            :can_sponsor_skilled_worker_visa,
            :can_sponsor_student_visa,
          )
          .permit(accredited_bodies: %i[provider_code provider_name description])
      end

      def provider_params
        params
          .fetch(:provider, {})
          .except(
            :accredited_bodies,
            :admin_contact,
            :utt_contact,
            :web_link_contact,
            :fraud_contact,
            :finance_contact,
            :type_of_gt12,
            :gt12_contact,
            :application_alert_contact,
            :send_application_alerts,
          ).permit(policy(@provider).permitted_provider_attributes)
      end

      def ucas_contact_params
        params
          .fetch(:provider, {})
          .except(
            :train_with_us,
            :train_with_disability,
            :provider_name,
            :email,
            :telephone,
            :website,
            :address1,
            :address2,
            :address3,
            :address4,
            :postcode,
            :region_code,
            :accredited_bodies,
            :type_of_gt12,
            :gt12_contact,
            :application_alert_contact,
            :send_application_alerts,
            :ukprn,
            :urn,
            :can_sponsor_skilled_worker_visa,
            :can_sponsor_student_visa,
          )
          .permit(
            admin_contact: %w[name email telephone permission_given],
            utt_contact: %w[name email telephone permission_given],
            web_link_contact: %w[name email telephone permission_given],
            fraud_contact: %w[name email telephone permission_given],
            finance_contact: %w[name email telephone permission_given],
          )
      end

      def ucas_preferences_params
        params
          .fetch(:provider, {})
          .except(
            :accredited_bodies,
            :admin_contact,
            :utt_contact,
            :web_link_contact,
            :fraud_contact,
            :finance_contact,
            :train_with_us,
            :train_with_disability,
            :provider_name,
            :email,
            :telephone,
            :website,
            :address1,
            :address2,
            :address3,
            :address4,
            :postcode,
            :region_code,
            :ukprn,
            :urn,
            :can_sponsor_skilled_worker_visa,
            :can_sponsor_student_visa,
          )
          .permit(
            :type_of_gt12,
            :gt12_contact,
            :application_alert_contact,
            :send_application_alerts,
          )
      end
    end
  end
end
