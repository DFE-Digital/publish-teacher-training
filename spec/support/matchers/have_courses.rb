RSpec::Matchers.define :have_courses do |*expected_courses|
  expected_courses = expected_courses.flatten
  def course_codes(server_response_body)
    json = JSON.parse(server_response_body)
    json.map { |course| course["course_code"] }
  end

  match do |server_response_body|
    if expected_courses.any?
      course_codes(server_response_body) == expected_courses.map(&:course_code)
    else
      course_codes(server_response_body).any? # inverted match logic for "should_not have_courses"
    end
  end

  failure_message do |server_response_body|
    if expected_courses.any?
      <<~STRING
        expected course codes #{expected_courses.map(&:course_code)}
        but got #{course_codes(server_response_body)}
      STRING
    else
      "expected course codes #{expected_courses.map(&:course_code)} but no courses found"
    end
  end

  failure_message_when_negated do |server_response_body|
    if expected_courses.any?
      <<~STRING
        didn't expect to find course codes #{expected_courses.map(&:course_code)}
        in response. Got: #{course_codes(server_response_body)}
      STRING
    else
      "expected no courses in response. Got: #{course_codes(server_response_body)}"
    end
  end
end
