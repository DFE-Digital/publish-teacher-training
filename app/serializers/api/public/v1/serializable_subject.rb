module API
  module Public
    module V1
      class SerializableSubject < JSONAPI::Serializable::Resource
        type "subjects"

        attribute :name do
          @object.subject_name
        end

        attribute :code do
          @object.subject_code
        end

        attribute :bursary_amount do
          @object.financial_incentive&.bursary_amount
        end

        attribute :early_career_payments do
          @object.financial_incentive&.early_career_payments
        end

        attribute :scholarship do
          @object.financial_incentive&.scholarship
        end

        attribute :subject_knowledge_enhancement_course_available do
          @object.financial_incentive&.subject_knowledge_enhancement_course_available
        end
      end
    end
  end
end
