require 'mcb_helper'

describe 'mcb users show' do
  let(:lib_dir) { "#{Rails.root}/lib" }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/show.rb"
    )
  end

  it 'shows the given user using id' do
    user = create(:user)

    output = with_stubbed_stdout do
      cmd.run([user.id.to_s])
    end

    expect(output).to have_text_table_row('id', user.id)
    expect(output).to have_text_table_row('email', user.email)
    expect(output).to have_text_table_row('first_name', user.first_name)
    expect(output).to have_text_table_row('last_name', user.last_name)
  end

  it 'shows the given user using email' do
    user = create(:user)

    output = with_stubbed_stdout do
      cmd.run([user.email])
    end

    expect(output).to have_text_table_row('id', user.id)
    expect(output).to have_text_table_row('email', user.email)
  end

  it 'shows the given user using sign-in id' do
    user = create(:user)

    output = with_stubbed_stdout do
      cmd.run([user.sign_in_user_id])
    end

    expect(output).to have_text_table_row('id', user.id)
    expect(output).to have_text_table_row('email', user.email)
  end

  it "shows an error if user isn't found" do
    user = create(:user)

    output = with_stubbed_stdout do
      cmd.run(%w[foobaz])
    end

    expect(output).to include "User not found: foobaz"
    expect(output).not_to have_text_table_row('id', user.id)
  end

  it "lists the user's providers" do
    provider = create(:provider)
    user = create(:user, organisations: [provider.organisations.first])

    output = with_stubbed_stdout do
      cmd.run([user.id.to_s])
    end

    provider = user.providers.first
    expect(output).to have_text_table_row(provider.id,
                                          provider.provider_name,
                                          provider.provider_code)
  end
end
