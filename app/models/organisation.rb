# == Schema Information
#
# Table name: organisation
#
#  id     :integer          not null, primary key
#  name   :text
#  org_id :text
#

class Organisation < ApplicationRecord
  has_many :organisation_users

  # dependent destroy because https://stackoverflow.com/questions/34073757/removing-relations-is-not-being-audited-by-audited-gem/34078860#34078860
  has_many :users, through: :organisation_users, dependent: :destroy

  has_and_belongs_to_many :providers

  validates :name, presence: true

  has_associated_audits
  audited

  def add_user(user)
    users << user
  end
end
