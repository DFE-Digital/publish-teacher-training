# frozen_string_literal: true

class Form
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :identifier_model, :model, :params, :fields

  def initialize(identifier_model, model, params: {})
    @identifier_model = identifier_model
    @model = model
    @params = params
    @fields = compute_fields
    assign_attributes(fields)
  end

  def save!
    if valid?
      assign_attributes_to_model # TODO: override this method on course_funding_form.rb
      model.save!
      after_save
      clear_stash
    else
      false
    end
  end

  def clear_stash
    store.clear_stash(form_store_key)
  end

  def stash
    store.stash(form_store_key, fields.except(*fields_to_ignore_before_stash)) if valid?
  end

private

  def after_save; end

  def store
    @store ||= identifier_store.new(identifier_model)
  end

  def identifier_store
    if identifier_model.instance_of?(User)
      Stores::UserStore
    elsif identifier_model.instance_of?(Course) || identifier_model.instance_of?(CourseDecorator)
      Stores::CourseStore
    end
  end

  def assign_attributes_to_model
    model.assign_attributes(fields.except(*fields_to_ignore_before_save))
  end

  def compute_fields
    raise(NotImplementedError)
  end

  def fields_to_ignore_before_stash
    []
  end

  def fields_to_ignore_before_save
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
    self.class.name.underscore.chomp("_form").split("/").last.to_sym
  end
end
