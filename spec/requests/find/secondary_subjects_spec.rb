# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Find::SecondarySubjectsController#index", service: :find do
  before { FeatureFlag.activate(:bursaries_and_scholarships_announced) }
  after { FeatureFlag.deactivate(:bursaries_and_scholarships_announced) }

  def render_subjects_for(subject_names)
    group = create(:subject_group)
    subject_names.each { |name| find_or_create(:secondary_subject, name).update!(subject_group: group) }

    count_queries { get "/secondary" }
  end

  # Every subject on the page shows its bursary or scholarship, so the
  # financial incentive has to come with the subjects rather than one query
  # per subject.
  it "renders the subjects in a constant number of queries regardless of how many there are" do
    few = render_subjects_for(%i[physics geography])
    many = render_subjects_for(%i[biology chemistry computing mathematics])

    expect(response).to have_http_status(:ok)
    expect(many).to eq(few)
  end
end
