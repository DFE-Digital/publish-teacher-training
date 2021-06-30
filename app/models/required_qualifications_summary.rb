class RequiredQualificationsSummary
  attr_reader :course

  def initialize(course)
    @course = course
  end

  def extract
    legacy_qualifications_attribute = course.latest_published_enrichment&.required_qualifications
    return legacy_qualifications_attribute if legacy_qualifications_attribute.present?

    generate_summary_text
  end

private

  def generate_summary_text
    output = ""
    output << required_gcse_content
    output << "\n"
    output << pending_gcse_content
    output << "\n"
    output << gcse_equivalency_content
    output << "\n"
    output << (course.additional_gcse_equivalencies || "")
  end

  def required_gcse_content
    case course.level
    when "primary"
      "Grade 4 (C) or above in English, maths and science, or equivalent qualification."
    when "secondary"
      "Grade 4 (C) or above in English and maths, or equivalent qualification."
    else
      ""
    end
  end

  def pending_gcse_content
    if course.accept_pending_gcse?
      "Candidates with pending GCSEs will be considered."
    else
      "Candidates with pending GCSEs will not be considered."
    end
  end

  def gcse_equivalency_content
    return "Equivalency tests will not be accepted." unless course.accept_gcse_equivalency?

    case gcse_equivalencies.count
    when 0
      "" # Assume that course.additional_gcse_equivalencies is populated instead
    when 1
      "Equivalency tests will be accepted in #{gcse_equivalencies[0].capitalize}."
    when 2
      "Equivalency tests will be accepted in #{gcse_equivalencies[0].capitalize} and #{gcse_equivalencies[1]}."
    when 3
      "Equivalency tests will be accepted in #{gcse_equivalencies[0].capitalize}, #{gcse_equivalencies[1]} and #{gcse_equivalencies[2]}."
    end
  end

  def gcse_equivalencies
    {
      english: course.accept_english_gcse_equivalency?,
      maths: course.accept_maths_gcse_equivalency?,
      science: course.accept_science_gcse_equivalency?,
    }.select { |_k, v| v }.keys
  end
end
