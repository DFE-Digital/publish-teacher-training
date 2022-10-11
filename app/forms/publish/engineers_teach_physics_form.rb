module Publish
  class EngineersTeachPhysicsForm < BaseModelForm
    alias_method :course, :model

    FIELDS = %i[campaign_name].freeze

    attr_accessor(*FIELDS)

    validates :campaign_name, inclusion: { in: Course.campaign_names.keys }

  private

    def compute_fields
      course.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
