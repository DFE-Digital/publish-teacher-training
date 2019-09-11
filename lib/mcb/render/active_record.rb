module MCB
  module Render
    module ActiveRecord
      class << self
        include MCB::Render

        def course(course)
          super(
            course.attributes,
            provider:             course.provider,
            accrediting_provider: course.accrediting_provider,
            ucas_subjects:             course.ucas_subjects,
            site_statuses:        course.site_statuses,
            enrichments:          course.enrichments,
            recruitment_cycle:    course.recruitment_cycle,
          )
        end

        def user(user)
          super(
            user.attributes,
            providers: user.providers,
          )
        end

        def provider(provider)
          super(
            provider.attributes,
            contacts:      provider.contacts,
            organisations: provider.organisations,
          )
        end
      end
    end
  end
end
