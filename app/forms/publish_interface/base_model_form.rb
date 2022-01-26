module PublishInterface
  class BaseModelForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    attr_accessor :model, :params, :fields

    delegate :id, :persisted?, to: :model

    def initialize(model, params: {})
      @model = model
      @params = params
      @fields = compute_fields
      assign_attributes(fields)
    end

    def save!
      if valid?
        assign_attributes_to_model
        model.save!
      else
        false
      end
    end

  private

    def assign_attributes_to_model
      model.assign_attributes(fields.except(*fields_to_ignore_before_save))
    end

    def compute_fields
      raise(NotImplementedError)
    end

    def fields_to_ignore_before_save
      []
    end

    def new_attributes
      params
    end
  end
end
