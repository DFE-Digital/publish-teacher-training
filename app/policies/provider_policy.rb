# frozen_string_literal: true

class ProviderPolicy
  attr_reader :user, :provider

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.providers)
      end
    end
  end

  def initialize(user, provider)
    @user = user
    @provider = provider
  end

  def new?
    user.present?
  end

  def search?
    user.admin?
  end

  def show?
    user.admin? || user.providers.include?(provider)
  end

  def show_any?
    user.present?
  end

  def suggest?
    user.present?
  end

  def suggest_any?
    user.present?
  end

  def can_show_training_provider?
    return true if user.admin?

    accredited_bodies_codes = provider.accredited_bodies.map { |ab| ab[:provider_code] }
    user_provider_codes = user.providers.pluck(:provider_code)

    !(accredited_bodies_codes & user_provider_codes).compact.empty?
  end

  alias can_list_sites? show?
  alias can_create_sites? show?
  alias can_create_course? show?
  alias edit? show?
  alias update? show?
  alias destroy? show?
  alias build_new? show?
  alias can_list_training_providers? show?
  alias index? new?
  alias create? show?
  alias delete? show?

  def permitted_provider_attributes
    if user.admin?
      admin_provider_attributes
    else
      user_provider_attributes
    end
  end

  private

  def user_provider_attributes
    base_attributes = %i[
      train_with_us
      train_with_disability
      email
      telephone
      website
      address1
      address2
      address3
      address4
      postcode
      region_code
      ukprn
      can_sponsor_skilled_worker_visa
      can_sponsor_student_visa
    ]
    provider.lead_school? ? base_attributes << :urn : base_attributes
  end

  def admin_provider_attributes
    user_provider_attributes + [:provider_name]
  end
end
