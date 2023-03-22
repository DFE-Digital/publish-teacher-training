# frozen_string_literal: true

class Form < BaseForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :model

  def initialize(identifier_model, model, params: {})
    @model = model
    super(identifier_model, params:)
  end

  def save!
    if valid?
      assign_attributes_to_model
      model.save!
      after_save
      clear_stash
    else
      false
    end
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
    else
      Stores::ProviderStore
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
end
