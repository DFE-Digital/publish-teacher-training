require 'mcb_helper'

describe '"mcb apiv1 courses find"' do
  it 'displays the info for the given course' do
    course1 = create(:course)

    subject = build(:ucas_subject)
    site_status = build(:site_status)

    course2 = create(:course, ucas_subjects: [subject], site_statuses: [site_status])


    url = "http://localhost:3001/api/v1/#{RecruitmentCycle.current_recruitment_cycle.year}/courses"
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
    output = output[:stdout]

    expect(output).to have_text_table_row('course_code',
                                          course2.course_code)
    expect(output).to have_text_table_row(subject.subject_code,
                                          subject.subject_name)
    expect(output).to(have_text_table_row(
                        site_status.site.code,
                        site_status.site.location_name,
                        site_status.vac_status_before_type_cast,
                        site_status.status_before_type_cast,
                        site_status.publish_before_type_cast,
                        site_status.applications_accepted_from.strftime('%Y-%m-%d')
                      ))
  end
end
