module API
  module V2
    class SerializableSubject < JSONAPI::Serializable::Resource
      type "subjects"

      attributes :subject_name, :subject_code

      attribute :bursary_amount do
        @object.financial_incentive&.bursary_amount
      end

      attribute :early_career_payments do
        @object.financial_incentive&.early_career_payments
      end

      attribute :scholarship do
        @object.financial_incentive&.scholarship
      end
    end
  end
end
