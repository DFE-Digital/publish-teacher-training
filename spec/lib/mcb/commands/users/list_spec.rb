require 'mcb_helper'

describe 'mcb users list' do
  let(:lib_dir) { "#{Rails.root}/lib" }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/list.rb"
    )
  end

  it 'lists all the users by default' do
    user1 = create(:user)
    user2 = create(:user)

    output = with_stubbed_stdout do
      cmd.run([])
    end

    expect(output).to have_text_table_row(user1.id,
                                          user1.email,
                                          user1.first_name,
                                          user1.last_name)
    expect(output).to have_text_table_row(user2.id,
                                          user2.email,
                                          user2.first_name,
                                          user2.last_name)
  end

  it 'lists the users given users by id' do
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    output = with_stubbed_stdout do
      cmd.run([user1.id, user2.id])
    end

    expect(output).to have_text_table_row(user1.id)
    expect(output).to have_text_table_row(user2.id)
    expect(output).not_to have_text_table_row(user3.id)
  end
end
