module Publish
  class GcseRequirementsForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :accept_pending_gcse, :accept_gcse_equivalency, :accept_english_gcse_equivalency,
                  :accept_maths_gcse_equivalency, :accept_science_gcse_equivalency, :additional_gcse_equivalencies, :level

    validates :accept_pending_gcse, inclusion: { in: [true, false], message: "Select if you consider candidates with pending GCSEs" }
    validates :accept_gcse_equivalency, inclusion: { in: [true, false], message: "Select if you consider candidates with pending equivalency tests" }
    validate :primary_or_secondary_equivalency_details_not_given, if: -> { equivalencies_not_selected? }
    validates :additional_gcse_equivalencies, presence: { message: "Enter details about equivalency tests" }, if: -> { equivalencies_not_selected? }
    validates :additional_gcse_equivalencies, words_count: { maximum: 200 }

    def save(course)
      return false unless valid?

      set_equivalency_values_to_false unless accept_gcse_equivalency

      course.update(
        accept_pending_gcse: accept_pending_gcse,
        accept_gcse_equivalency: accept_gcse_equivalency,
        accept_english_gcse_equivalency: accept_english_gcse_equivalency,
        accept_maths_gcse_equivalency: accept_maths_gcse_equivalency,
        accept_science_gcse_equivalency: accept_science_gcse_equivalency,
        additional_gcse_equivalencies: additional_gcse_equivalencies,
      )
    end

    def self.build_from_course(course)
      new(
        accept_pending_gcse: course.accept_pending_gcse,
        accept_gcse_equivalency: course.accept_gcse_equivalency,
        accept_english_gcse_equivalency: course.accept_english_gcse_equivalency,
        accept_maths_gcse_equivalency: course.accept_maths_gcse_equivalency,
        accept_science_gcse_equivalency: course.accept_science_gcse_equivalency,
        additional_gcse_equivalencies: course.additional_gcse_equivalencies,
        level: course.level,
      )
    end

  private

    def primary_or_secondary_equivalency_details_not_given
      if level == "primary"
        errors.add(:equivalencies, "Select if you accept equivalency tests in English, maths or science")
      else
        errors.add(:equivalencies, "Select if you accept equivalency tests in English or maths")
      end
    end

    def equivalencies_not_selected?
      accept_gcse_equivalency.present? && accept_english_gcse_equivalency.blank? && accept_maths_gcse_equivalency.blank? && accept_science_gcse_equivalency.blank?
    end

    def set_equivalency_values_to_false
      self.accept_english_gcse_equivalency = false
      self.accept_maths_gcse_equivalency = false
      self.accept_science_gcse_equivalency = false
      self.additional_gcse_equivalencies = nil
    end
  end
end
