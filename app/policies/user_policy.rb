# frozen_string_literal: true

class UserPolicy
  attr_reader :user, :accessed_user

  def initialize(user, accessed_user)
    @user = user
    @accessed_user = accessed_user
  end

  def show?
    user == accessed_user
  end

  def remove_access_to?
    user.admin? || user == accessed_user
  end

  alias update? show?
  alias accept_transition_screen? update?
  alias accept_rollover_screen? update?
  alias accept_terms? update?
  alias index? show?
  alias create? update?
end
