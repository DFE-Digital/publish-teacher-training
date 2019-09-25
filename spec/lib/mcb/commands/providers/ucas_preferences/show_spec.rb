require "rails_helper"
require "mcb"
require "stringio"

describe "mcb providers ucas_preferences show" do
  let(:lib_dir) { Rails.root.join("lib") }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/providers/ucas_preferences/show.rb",
    )
  end

  let(:provider) { create(:provider, ucas_preferences: preferences) }
  let(:preferences) do
    build :provider_ucas_preference,
          type_of_gt12: "coming_or_not",
          send_application_alerts: "all"
  end

  it "displays the preferences for the given provider" do
    output = with_stubbed_stdout do
      cmd.run([provider.provider_code])
    end
    output = output[:stdout]

    expect(output).to match %r{type_of_gt12\s+\|\scoming_or_not}
  end
end
