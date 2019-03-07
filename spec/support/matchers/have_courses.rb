RSpec::Matchers.define :have_courses do |*courses|
  courses = courses.flatten
  def course_codes(body)
    json = JSON.parse(body)
    json.map { |course| course["course_code"] }
  end

  match do |body|
    if courses
      course_codes(body) == courses.map(&:course_code)
    end
  end

  failure_message do |body|
    if courses
      <<~STRING
        expected course codes #{courses.map(&:course_code)}
          to be found in body #{course_codes(body)}
      STRING
    else
      'expected courses to be present, but no courses found'
    end
  end

  failure_message_when_negated do |body|
    if courses
      <<~STRING
          expected course codes #{courses.map(&:course_code)}
        not to be found in body #{course_codes(body)}
      STRING
    else
      "expected no courses to be present, #{course_codes(body).length} course(s) found"
    end
  end
end
