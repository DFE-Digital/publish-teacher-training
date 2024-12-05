# frozen_string_literal: true

class CourseSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :can_sponsor_visa, :boolean

  def search_params
    attributes.symbolize_keys.slice(*filters).compact
  end

  private

  def filters
    %i[
      can_sponsor_visa
    ]
  end
end
