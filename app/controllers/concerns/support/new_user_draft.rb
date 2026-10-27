# frozen_string_literal: true

module Support
  module NewUserDraft
    DRAFT_KEY = :support_new_user

  private

    def stash_new_user(attributes)
      session[DRAFT_KEY] = attributes.to_h.stringify_keys
    end

    def new_user_draft
      draft = session[DRAFT_KEY]
      return {} if draft.blank?

      draft.symbolize_keys.tap do |attributes|
        attributes[:email] = attributes[:email].to_s.strip.downcase
        attributes[:admin] = ActiveModel::Type::Boolean.new.cast(attributes[:admin])
      end
    end

    def clear_new_user_draft
      session.delete(DRAFT_KEY)
    end

    def new_user_params
      permitted = params.expect(user: %i[first_name last_name email])
      permitted[:email] = permitted[:email].to_s.strip.downcase
      permitted[:admin] = ActiveModel::Type::Boolean.new.cast(params.dig(:user, :admin))
      permitted
    end
  end
end
