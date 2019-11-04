require "rails_helper"

describe Courses::AssignableMasterSubjectService do
  let(:service) do
    described_class.new(
      primary_subject: primary_model,
      secondary_subject: secondary_model,
      further_education_subject: further_education_model,
    )
  end
  let(:primary_model) { spy(all: []) }
  let(:secondary_model) { spy(all: []) }
  let(:further_education_model) { spy(all: []) }

  it "gets all primary subjects if the level is primary" do
    course = create(:course, level: "primary")

    expect(service.execute(course)).to eq([])
    expect(primary_model).to have_received(:all)
  end

  it "gets all secondary subjects if the level is secondary" do
    course = create(:course, level: "secondary")

    expect(service.execute(course)).to eq([])
    expect(secondary_model).to have_received(:all)
  end

  it "gets all further education subjects if the level is further education" do
    course = create(:course, level: "further_education")

    expect(service.execute(course)).to eq([])
    expect(further_education_model).to have_received(:all)
  end
end
