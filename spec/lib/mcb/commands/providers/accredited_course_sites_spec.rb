require "mcb_helper"

describe "mcb providers accredited_course_sites" do
  def execute(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["providers", "accredited_course_sites", *arguments])
    end
  end

  let(:provider) { create :provider, :accredited_body }
  let!(:findable_course) do
    create :course, name: "findable-course",
           accrediting_provider: provider,
           site_statuses: [build(:site_status, :findable)]
  end

  it "writes course information to terminal" do
    output = execute(arguments: [provider.provider_code])[:stdout]
    expect(output).to include("provider_code | provider_name") # headers
    expect(output).to include(findable_course.provider.provider_code)
    expect(output).to include(findable_course.course_code)
  end

  it "writes course information to file" do
    csv_class_double = class_double("CSV").as_stubbed_const(transfer_nested_constants: true)
    csv_double = instance_double("CSV")
    allow(csv_class_double).to receive(:open).and_yield(csv_double)
    allow(csv_double).to receive(:<<)
    output = execute(arguments: [provider.provider_code, "-f", "accredited_course_sites_spec_output.csv"])[:stdout]
    expect(output).to include("1 rows written to accredited_course_sites_spec_output.csv")
    expect(csv_class_double).to have_received(:open)
    expect(csv_double).to have_received(:<<)
  end
end
