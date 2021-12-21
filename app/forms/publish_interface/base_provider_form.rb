module PublishInterface
  class BaseProviderForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    attr_accessor :provider, :params, :fields

    delegate :id, :persisted?, to: :provider

    def initialize(provider, params: {})
      @provider = provider
      @params = params
      @fields = compute_fields
      assign_attributes(fields)
    end

    def save!
      if valid?
        assign_attributes_to_provider
        provider.save!
      else
        false
      end
    end

  private

    def assign_attributes_to_provider
      provider.assign_attributes(fields.except(*fields_to_ignore_before_save))
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
