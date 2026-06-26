# frozen_string_literal: true

class CourseWizard
  module Reviewable
    extend ActiveSupport::Concern

    RowSpec = Struct.new(
      :step_id,
      :label_key,
      :label_options,
      :value,
      :formatter,
      :show_when_blank,
      :changeable,
      keyword_init: true,
    ) do
      def changeable?
        changeable
      end
    end

    class_methods do
      def review(&block)
        @review_spec = block
      end

      def review_spec
        @review_spec
      end
    end

    def review_rows(draft)
      return [] unless self.class.review_spec

      RowSet.build(self.class.review_spec, self, draft)
    end

    class RowSet
      def self.build(spec, step, draft)
        collector = new(step, draft)
        spec.call(collector)
        collector.rows
      end

      attr_reader :rows

      def initialize(step, draft)
        @step = step
        @draft = draft
        @rows = []
      end

      def row(label:, value: nil, formatter: nil, label_options: {}, show_when_blank: false, changeable: true)
        @rows << CourseWizard::Reviewable::RowSpec.new(
          step_id: @step.step_id,
          label_key: label,
          label_options: resolve(label_options),
          value: resolve(value),
          formatter:,
          show_when_blank:,
          changeable: resolve(changeable),
        )
      end

    private

      def resolve(value)
        case value
        when Proc
          value.call(@draft)
        when Symbol
          @step.public_send(value)
        else
          value
        end
      end
    end
  end
end
