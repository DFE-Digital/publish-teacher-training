# frozen_string_literal: true

module Find
  module V2
    module Subjects
      class Form
        include ActiveModel::Model

        attr_accessor :subjects, :context

        validates :subjects, presence: { message: ->(form, _data) { I18n.t('.find.v2.subjects.form.blank', type: form.context) } }

        def initialize(params = {})
          @subjects = Array(params[:subjects]).compact_blank
          @context = params[:context]
        end
      end
    end
  end
end
