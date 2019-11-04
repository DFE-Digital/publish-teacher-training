require "mcb_helper"

describe "mcb users audit" do
  let(:lib_dir) { Rails.root.join("lib") }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/audit.rb",
    )
  end
  let(:admin_email) { "aa@education.gov.uk" }
  let(:admin_user) { create :user, :admin, email: admin_email }
  let(:user) { create :user, email: "a@a" }

  it "shows the list of changes for a given user" do
    Audited.store[:audited_user] = admin_user
    user.update(email: "b@b")

    output = with_stubbed_stdout do
      cmd.run([user.id.to_s])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row(admin_user.id,
                                          admin_email,
                                          "update",
                                          "",
                                          "",
                                          '{"email"=>["a@a", "b@b"]}')
  end

  it "allows specifying user by email" do
    Audited.store[:audited_user] = admin_user
    user.update(email: "b@b")

    output = with_stubbed_stdout do
      cmd.run([user.email])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row(admin_user.id,
                                          admin_email,
                                          "update",
                                          "",
                                          "",
                                          '{"email"=>["a@a", "b@b"]}')
  end

  it "allows specifying user by sign-in id" do
    Audited.store[:audited_user] = admin_user
    user.update(email: "b@b")

    output = with_stubbed_stdout do
      cmd.run([user.sign_in_user_id])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row(admin_user.id,
                                          admin_email,
                                          "update",
                                          "",
                                          "",
                                          '{"email"=>["a@a", "b@b"]}')
  end
end
