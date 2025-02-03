# frozen_string_literal: true

module Find
  module V2
    module Subjects
      class PrimarySubjectsForm
        include ActiveModel::Model

        attr_accessor :subjects

        validates :subjects, presence: true

        def initialize(params = {})
          @subjects = Array(params[:subjects]).compact_blank
        end
      end
    end
  end
end
