require 'mcb_helper'

describe '"mcb courses show"' do
  let(:lib_dir) { "#{Rails.root}/lib" }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/courses/show.rb"
    )
  end

  it 'displays the course info' do
    _site_status1 = create(:site_status)

    site_status2 = create(:site_status)
    course2      = site_status2.course
    subjects2    = course2.subjects

    output = with_stubbed_stdout do
      cmd.run([course2.provider.provider_code, course2.course_code])
    end

    expect(output).to have_text_table_row('course_code',
                                          course2.course_code)

    expect(output).to have_text_table_row(subjects2.first.subject_code,
                                          subjects2.first.subject_name)

    expect(output).to(
      have_text_table_row(
        site_status2.id,
        site_status2.site.code,
        site_status2.site.location_name,
        site_status2.vac_status,
        site_status2.status,
        site_status2.publish,
        site_status2.applications_accepted_from.strftime('%Y-%m-%d')
      )
    )
  end
end
