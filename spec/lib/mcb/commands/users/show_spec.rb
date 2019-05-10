require 'mcb_helper'

describe 'mcb users show' do
  let(:lib_dir) { "#{Rails.root}/lib" }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/show.rb"
    )
  end

  it 'shows the given user' do
    user = create(:user)

    output = with_stubbed_stdout do
      cmd.run([user.id])
    end

    expect(output).to have_text_table_row('id', user.id)
    expect(output).to have_text_table_row('email', user.email)
    expect(output).to have_text_table_row('first_name', user.first_name)
    expect(output).to have_text_table_row('last_name', user.last_name)
  end

  it "lists the user's providers" do
    provider = create(:provider)
    user = create(:user, organisations: [provider.organisations.first])

    output = with_stubbed_stdout do
      cmd.run([user.id])
    end

    provider = user.providers.first
    expect(output).to have_text_table_row(provider.id,
                                          provider.provider_name,
                                          provider.provider_code)
  end
end
