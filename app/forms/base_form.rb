# frozen_string_literal: true

class BaseForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :identifier_model, :params, :fields

  def initialize(identifier_model, params: {})
    @identifier_model = identifier_model
    @params = params
    @fields = compute_fields
    assign_attributes(fields)
  end

  def clear_stash
    store.clear_stash(form_store_key)
  end

  def stash
    store.stash(form_store_key, fields.except(*fields_to_ignore_before_stash)) if valid?
  end

  private

  def store
    @store ||= identifier_store.new(identifier_model)
  end

  def identifier_store
    {
      provider: Stores::ProviderStore,
      user: Stores::UserStore,
      course: Stores::CourseStore,
      course_decorator: Stores::CourseStore
    }[identifier_model.class.name.underscore.to_sym]
  end

  def compute_fields
    raise(NotImplementedError)
  end

  def fields_to_ignore_before_stash
    []
  end

  def new_attributes
    fields_from_store.merge(params).symbolize_keys
  end

  def validation_error_details
    errors.messages.map do |field, messages|
      [field, { messages:, value: public_send(field) }]
    end
  end

  def fields_from_store
    store.get(form_store_key).presence || {}
  end

  def form_store_key
    self.class.name.underscore.chomp('_form').split('/').last.to_sym
  end
end
