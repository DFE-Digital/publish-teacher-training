module Publish
  class ProviderSkilledWorkerVisaForm < BaseProviderForm
    FIELDS = %i[
      can_sponsor_skilled_worker_visa
    ].freeze

    attr_accessor(*FIELDS)

    validates :can_sponsor_skilled_worker_visa, inclusion: { in: [true, false], message: "Select if candidates can get a sponsored Skilled Worker visa" }

  private

    def compute_fields
      provider.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
