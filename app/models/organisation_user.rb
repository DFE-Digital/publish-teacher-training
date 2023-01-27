# frozen_string_literal: true

class OrganisationUser < ApplicationRecord
  belongs_to :organisation
  belongs_to :user

  audited associated_with: :organisation
end
