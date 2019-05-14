require 'mcb_helper'

describe 'mcb users list' do
  let(:lib_dir) { "#{Rails.root}/lib" }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/list.rb"
    )
  end

  it 'lists all the columns' do
    user = create(:user)

    output = with_stubbed_stdout do
      cmd.run([])
    end

    expect(output).to have_text_table_row(user.id,
                                          user.email,
                                          user.sign_in_user_id,
                                          user.first_name,
                                          user.last_name,
                                          user.last_login_date_utc)
  end

  it 'lists all the users by default' do
    user1 = create(:user)
    user2 = create(:user)

    output = with_stubbed_stdout do
      cmd.run([])
    end

    expect(output).to have_text_table_row(user1.id)
    expect(output).to have_text_table_row(user2.id)
  end

  it 'lists the given users by id' do
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    output = with_stubbed_stdout do
      cmd.run([user1.id.to_s, user2.id.to_s])
    end

    expect(output).to have_text_table_row(user1.id)
    expect(output).to have_text_table_row(user2.id)
    expect(output).not_to have_text_table_row(user3.id)
  end

  it 'lists the given users by email' do
    user1 = create(:user)
    user2 = create(:user)

    output = with_stubbed_stdout do
      cmd.run([user1.email])
    end

    expect(output).to have_text_table_row(user1.id)
    expect(output).not_to have_text_table_row(user2.id)
  end
end
