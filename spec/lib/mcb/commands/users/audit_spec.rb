require 'mcb_helper'

describe 'mcb users audit' do
  let(:lib_dir) { "#{Rails.root}/lib" }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/audit.rb"
    )
  end

  it 'shows the list of changes for a given user' do
    user = create(:user, email: 'a@a')
    admin_user = create :user, :admin, email: 'h@i'

    Audited.store[:audited_user] = admin_user
    user.update(email: 'b@b')

    output = with_stubbed_stdout do
      cmd.run([user.id.to_s])
    end

    expect(output).to have_text_table_row(admin_user.id,
                                          'h@i',
                                          'update',
                                          '',
                                          '',
                                          '{"email"=>["a@a", "b@b"]}')
  end

  it 'allows specifying user by email' do
    user = create(:user, email: 'a@a')
    admin_user = create :user, :admin, email: 'h@i'

    Audited.store[:audited_user] = admin_user
    user.update(email: 'b@b')

    output = with_stubbed_stdout do
      cmd.run([user.email])
    end

    expect(output).to have_text_table_row(admin_user.id,
                                          'h@i',
                                          'update',
                                          '',
                                          '',
                                          '{"email"=>["a@a", "b@b"]}')
  end

  it 'allows specifying user by sign-in id' do
    user = create(:user, email: 'a@a')
    admin_user = create :user, :admin, email: 'h@i'

    Audited.store[:audited_user] = admin_user
    user.update(email: 'b@b')

    output = with_stubbed_stdout do
      cmd.run([user.sign_in_user_id])
    end

    expect(output).to have_text_table_row(admin_user.id,
                                          'h@i',
                                          'update',
                                          '',
                                          '',
                                          '{"email"=>["a@a", "b@b"]}')
  end
end
