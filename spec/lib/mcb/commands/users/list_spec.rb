require "mcb_helper"
require "csv"

describe "mcb users list" do
  let(:lib_dir) { Rails.root.join("lib") }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/list.rb",
    )
  end

  it "lists all the columns" do
    user = create(:user)

    output = with_stubbed_stdout do
      cmd.run([])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row(user.id,
                                          user.email,
                                          user.sign_in_user_id,
                                          user.first_name,
                                          user.last_name,
                                          user.last_login_date_utc)
  end

  it "lists all the users by default" do
    user1 = create(:user)
    user2 = create(:user)

    output = with_stubbed_stdout do
      cmd.run([])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row(user1.id)
    expect(output).to have_text_table_row(user2.id)
  end

  it "lists the given users by id" do
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    output = with_stubbed_stdout do
      cmd.run([user1.id.to_s, user2.id.to_s])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row(user1.id)
    expect(output).to have_text_table_row(user2.id)
    expect(output).not_to have_text_table_row(user3.id)
  end

  it "lists the given users by email" do
    user1 = create(:user)
    user2 = create(:user)

    output = with_stubbed_stdout do
      cmd.run([user1.email])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row(user1.id)
    expect(output).not_to have_text_table_row(user2.id)
  end

  it "lists active, non-admin users with the -o option" do
    user1 = create(:user, :admin)
    user2 = create(:user, :inactive)
    user3 = create(:user, accept_terms_date_utc: Date.yesterday)

    output = with_stubbed_stdout do
      cmd.run(["-o"])
    end
    output = output[:stdout]

    expect(output).not_to have_text_table_row(user1.id)
    expect(output).not_to have_text_table_row(user2.id)
    expect(output).to     have_text_table_row(user3.id)
  end

  it "exports the results to a CSV file" do
    tmpfile = Tempfile.new
    tmpfile.close

    user1 = create(:user)
    user2 = create(:user)

    with_stubbed_stdout do
      cmd.run(["-c", tmpfile.path])
    end
    table = CSV.read(tmpfile.path, headers: true)

    expect(table.size).to eq(2)
    expect(table[0]["email"]).to eq(user1.email)
    expect(table[1]["email"]).to eq(user2.email)
  end
end
