# frozen_string_literal: true

module Publish
  module Courses
    module Schools
      # The mandatory radio question on the bulk update options page: what
      # courses the placement school change applies to.
      #
      # The scopes the course offers decide both what the page renders and what
      # the form accepts, so an answer the provider was never shown - a hand
      # written scope, or one that stopped applying while they were deciding -
      # is rejected rather than quietly matching a set of courses nobody chose.
      class BulkUpdateScopeForm < ApplicationForm
        attr_reader :course

        attribute :scope, :string

        validates :scope, presence: true
        validates :scope, inclusion: { in: :scope_tokens }, allow_blank: true

        def initialize(course:, **)
          @course = course

          super(**)
        end

        def scopes
          @scopes ||= Publish::Schools::BulkUpdate::Scope.available(course)
        end

        def chosen_scope
          scopes.find { |available| available.token == scope }
        end

      private

        def scope_tokens
          scopes.map(&:token)
        end
      end
    end
  end
end
