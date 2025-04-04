# frozen_string_literal: true

# Extend BaseForm to accept an ActiveRecord object
#
# When calling save on the form, we assign the
# form attributes to the model and save the model
class Form < BaseForm
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

  def assign_attributes_to_model
    model.assign_attributes(fields.except(*fields_to_ignore_before_save))
  end

  def fields_to_ignore_before_save
    []
  end
end
