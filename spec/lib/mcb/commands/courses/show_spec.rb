require 'mcb_helper'

describe '"mcb courses show"' do
  let(:lib_dir) { Rails.root.join('lib') }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/courses/show.rb"
    )
  end

  it 'displays the course info' do
    subject = build(:subject)
    site_status = build(:site_status)

    course = create(:course, subjects: [subject], site_statuses: [site_status])

    output = with_stubbed_stdout do
      cmd.run([course.provider.provider_code, course.course_code])
    end

    expect(output).to have_text_table_row('course_code',
                                          course.course_code)

    expect(output).to have_text_table_row(subject.subject_code,
                                          subject.subject_name)

    expect(output).to(
      have_text_table_row(
        site_status.id,
        site_status.site.code,
        site_status.site.location_name,
        site_status.vac_status,
        site_status.status,
        site_status.publish,
        site_status.applications_accepted_from.strftime('%Y-%m-%d')
      )
    )
  end
end
