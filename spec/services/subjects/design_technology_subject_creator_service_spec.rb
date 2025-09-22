# frozen_string_literal: true

require "rails_helper"

describe Subjects::DesignTechnologySubjectCreatorService do
  let(:subject_area_spy) { spy }
  let(:design_technology_model) { spy }

  let(:service) do
    described_class.new(
      subject_area: subject_area_spy,
      design_technology_subject: design_technology_model,
    )
  end

  it "creates the Design & Technology subject area and all design technology specialisms" do
    service.execute

    expect(subject_area_spy).to have_received(:find_or_create_by!).with(typename: "DesignTechnologySubject", name: "Secondary: Design and technology")
    expect(design_technology_model).to have_received(:find_or_create_by!).with(subject_name: "Electronics", subject_code: "DTE")
    expect(design_technology_model).to have_received(:find_or_create_by!).with(subject_name: "Engineering", subject_code: "DTEN")
    expect(design_technology_model).to have_received(:find_or_create_by!).with(subject_name: "Food technology", subject_code: "DTF")
    expect(design_technology_model).to have_received(:find_or_create_by!).with(subject_name: "Product technology", subject_code: "DTP")
    expect(design_technology_model).to have_received(:find_or_create_by!).with(subject_name: "Textiles", subject_code: "DTT")
  end
end
