module Publish
  class AcceptTermsForm < BaseModelForm
    alias_method :user, :model

    FIELDS = %i[
      terms_accepted
    ].freeze

    attr_accessor(*FIELDS)

    validates :terms_accepted, acceptance: true

  private

    def compute_fields
      { terms_accepted: user.accepted_terms? }.merge(new_attributes).symbolize_keys
    end

    def assign_attributes_to_model
      model.assign_attributes(accept_terms_date_utc: Time.zone.now)
    end
  end
end
