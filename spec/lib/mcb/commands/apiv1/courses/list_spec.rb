require "mcb_helper"

describe '"mcb apiv1 courses list"' do
  let(:current_cycle) { find_or_create(:recruitment_cycle, year: "2019") }
  let(:next_cycle) { find_or_create(:recruitment_cycle, year: "2020") }
  let(:provider1) { create(:provider, recruitment_cycle: current_cycle) }
  let(:provider2) { create(:provider, recruitment_cycle: next_cycle) }
  let(:course1) { create(:course, provider: provider1) }
  let(:course2) { create(:course, provider: provider2) }

  it "lists courses for the default recruitment year" do
    url = "http://localhost:3001/api/v1/#{RecruitmentCycle.current_recruitment_cycle.year}/courses"
    next_url = url + "&" + {
        changed_since: course2.created_at.utc.strftime("%FT%T.%6NZ"),
        per_page: 100,
      }.to_query
    json = ActiveModel::Serializer::CollectionSerializer.new(
      [
        course1,
        course2,
      ],
      serializer: CourseSerializer,
    )

    stub_request(:get, url)
      .with(headers: {
              "Authorization" => "Bearer bats",
            })
      .to_return(status: 200,
                 body: json.to_json,
                 headers: {
                   link: next_url + '; rel="next"',
                 })
    stub_request(:get, next_url)
      .to_return(status: 200,
                 body: [].to_json,
                 headers: {
                   link: next_url + '; rel="next"',
                 })

    output = with_stubbed_stdout do
      $mcb.run(%W[apiv1
                  courses
                  list])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row("Code",
                                          "Name",
                                          "Provider Code",
                                          "Provider Name")
    expect(output).to have_text_table_row(course1.course_code, course1.name)
    expect(output).to have_text_table_row(course2.course_code, course2.name)
  end

  it "lists courses for a given recruitment year" do
    url = "http://localhost:3001/api/v1/#{next_cycle.year}/courses"
    next_url = url + "&" + {
        changed_since: course2.created_at.utc.strftime("%FT%T.%6NZ"),
        per_page: 100,
      }.to_query
    json = ActiveModel::Serializer::CollectionSerializer.new(
      [
        course2,
      ],
      serializer: CourseSerializer,
    )

    stub_request(:get, url)
      .with(headers: {
              "Authorization" => "Bearer bats",
            })
      .to_return(status: 200,
                 body: json.to_json,
                 headers: {
                   link: next_url + '; rel="next"',
                 })
    stub_request(:get, next_url)
      .to_return(status: 200,
                 body: [].to_json,
                 headers: {
                   link: next_url + '; rel="next"',
                 })

    output = with_stubbed_stdout do
      $mcb.run(%W[apiv1
                  courses
                  list -r #{next_cycle.year}])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row("Code",
                                          "Name",
                                          "Provider Code",
                                          "Provider Name")
    expect(output).to have_text_table_row(course2.course_code, course2.name)
    expect(output).not_to have_text_table_row(course1.course_code, course1.name)
  end
end
