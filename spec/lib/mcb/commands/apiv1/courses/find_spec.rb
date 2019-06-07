require 'mcb_helper'

describe '"mcb apiv1 courses find"' do
  it 'displays the info for the given course' do
    # The site_status factory is an easy way to create a course and it's site
    site_status1 = create(:site_status)
    course1 = site_status1.course

    site_status2 = create(:site_status)
    course2 = site_status2.course
    create_subject = create(:subject)
    course2.update(subjects: [create_subject])
    subject2 = course2.subjects.first

    url = 'http://localhost:3001/api/v1/2019/courses'
    next_url = url + '&' + {
        changed_since: course2.created_at.utc.strftime('%FT%T.%6NZ'),
        per_page: 100
      }.to_query
    json = ActiveModel::Serializer::CollectionSerializer.new(
      [
        course1,
        course2
      ],
      serializer: CourseSerializer
    )

    stub_request(:get, url)
      .with(headers: {
              'Authorization' => 'Bearer bats'
            })
      .to_return(status: 200,
                 body: json.to_json,
                 headers: {
                   link: next_url + '; rel="next"'
                 })
    stub_request(:get, next_url)
      .to_return(status: 200,
                 body: [].to_json,
                 headers: {
                   link: next_url + '; rel="next"'
                 })

    output = with_stubbed_stdout do
      $mcb.run(%W[apiv1
                  courses
                  find
                  #{course2.provider.provider_code}
                  #{course2.course_code}])
    end

    expect(output).to have_text_table_row('course_code',
                                          course2.course_code)
    expect(output).to have_text_table_row(subject2.subject_code,
                                          subject2.subject_name)
    expect(output).to(have_text_table_row(
                        site_status2.site.code,
                        site_status2.site.location_name,
                        site_status2.vac_status_before_type_cast,
                        site_status2.status_before_type_cast,
                        site_status2.publish_before_type_cast,
                        site_status2.applications_accepted_from.strftime('%Y-%m-%d')
                      ))
  end
end
