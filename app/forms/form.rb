# frozen_string_literal: true

class Form
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :user, :model, :params, :fields

  def initialize(user, model, params: {})
    @user = user
    @model = model
    @params = params
    @fields = compute_fields
    assign_attributes(fields)
  end

  def save!
    if valid?
      assign_attributes_to_model
      model.save!
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

  def store
    @store ||= UserStore.new(user)
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
