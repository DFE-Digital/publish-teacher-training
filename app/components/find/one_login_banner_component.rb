# frozen string_literal: true

module Find
  class OneLoginBannerComponent < ApplicationComponent
    attr_reader :reason

    DEFAULT_CLASS = "govuk-notification-banner".freeze

    def default_classes
      DEFAULT_CLASS
    end

    def initialize(reason: :general, **args)
      super(**args)
      @reason = reason
    end

    def message_after
      case reason
      when :save_course
        t("find.concerns.authentication.unauthenticated_message_after_save_a_course")
      else
        t("find.concerns.authentication.unauthenticated_message_after_general")
      end
    end

    def one_login_path
      Authentications::CandidateOmniAuth.sign_in_path
    end
  end
end
