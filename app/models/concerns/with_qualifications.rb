module WithQualifications
  extend ActiveSupport::Concern

  included do
    enum profpost_flag: {
      recommendation_for_qts: "",
      professional: "PF",
      postgraduate: "PG",
      professional_postgraduate: "BO",
    }

    def is_further_education?
      subjects.further_education.any?
    end

    def qualifications
      qts_if_any + qualification_awarded_by_uni_if_any
    end

  private

    def qts_if_any
      is_further_education? ? [] : [:qts]
    end

    def qualification_awarded_by_uni_if_any
      if PGDECourse.is_one?(self)
        [:pgde]
      elsif recommendation_for_qts?
        []
      else
        [:pgce]
      end
    end
  end
end
