require 'mcb_helper'

describe 'mcb courses audit' do
  let(:lib_dir) { Rails.root.join('lib') }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/courses/audit.rb"
    )
  end
  let(:admin_user) { create :user, :admin, email: 'h@i' }
  let(:course) { create(:course, name: 'P') }

  before do
    Audited.store[:audited_user] = admin_user
  end

  it 'shows the list of changes for a given course' do
    course.update(name: 'B')

    output = with_stubbed_stdout do
      cmd.run([course.provider.provider_code, course.course_code])
    end

    expect(output).to have_text_table_row(admin_user.id,
                                          'h@i',
                                          'update',
                                          '',
                                          '',
                                          '{"name"=>["P", "B"],')
  end
end
