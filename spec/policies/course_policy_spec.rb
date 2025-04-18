# frozen_string_literal: true

require "rails_helper"

describe CoursePolicy do
  subject { described_class }

  let(:user) { create(:user) }

  permissions :index?, :new? do
    it { is_expected.to permit(user, Course) }
  end

  permissions :show?, :update?, :withdraw?, :details? do
    let(:course) { create(:course) }
    let!(:provider) do
      create(:provider,
             courses: [course],
             users: [user])
    end

    it { is_expected.to permit(user, course) }

    context "with a user outside the provider" do
      let(:other_user) { create(:user) }

      it { is_expected.not_to permit(other_user, course) }
    end
  end

  permissions :can_update_funding_type? do
    let(:course) { create(:course, :published) }

    it { is_expected.not_to permit(user, course) }

    context "with a draft course" do
      let(:course) { create(:course, enrichments: [build(:course_enrichment, :initial_draft)]) }

      it { is_expected.to permit(user, course) }
    end

    context "with a rolled over course" do
      let(:course) { create(:course, enrichments: [build(:course_enrichment, :rolled_over)]) }

      it { is_expected.to permit(user, course) }
    end
  end

  permissions :can_update_qualification? do
    context "when the course is a TDA and is published" do
      let(:course) do
        create(
          :course,
          :with_teacher_degree_apprenticeship,
          :resulting_in_undergraduate_degree_with_qts,
          :with_gcse_equivalency,
          :published,
        )
      end

      it { is_expected.not_to permit(user, course) }
    end

    context "when the course is a TDA but not published" do
      let(:course) do
        create(
          :course,
          :with_teacher_degree_apprenticeship,
          :resulting_in_undergraduate_degree_with_qts,
          :with_gcse_equivalency,
        )
      end

      it { is_expected.to permit(user, course) }
    end

    context "when the course is not a TDA but is published" do
      let(:course) do
        create(
          :course,
          :resulting_in_qts,
          :with_gcse_equivalency,
          :published,
        )
      end

      it { is_expected.to permit(user, course) }
    end

    context "when the course is withdrawn" do
      let(:course) do
        create(
          :course,
          :resulting_in_qts,
          :with_gcse_equivalency,
          :withdrawn,
        )
      end

      it { is_expected.not_to permit(user, course) }
    end

    context "when the course is not a TDA, not published, and not withdrawn" do
      let(:course) do
        create(
          :course,
          :resulting_in_qts,
          :with_gcse_equivalency,
        )
      end

      it { is_expected.to permit(user, course) }
    end
  end

  describe "#permitted_attributes" do
    subject { described_class.new(user, build(:course)) }

    context "when non admin user" do
      it "returns user attributes" do
        expect(subject.permitted_attributes).to include(:english)
        expect(subject.permitted_attributes).not_to include(:name)
      end
    end

    context "when admin user" do
      let(:user) { build(:user, :admin) }

      it "returns user and admin attributes" do
        expect(subject.permitted_attributes).to include(:english)
        expect(subject.permitted_attributes).to include(:name)
      end
    end
  end

  describe "#permitted_new_course_attributes" do
    subject { described_class.new(user, build(:course)).permitted_new_course_attributes }

    context "when non admin user" do
      it "returns new course attributes" do
        expected_attributes = %i[
          accredited_provider_code
          age_range_in_years
          applications_open_from
          funding_type
          funding
          is_send
          level
          qualification
          start_date
          study_mode
          can_sponsor_student_visa
          can_sponsor_skilled_worker_visa
          visa_sponsorship_application_deadline_required
          visa_sponsorship_application_deadline_at
          campaign_name
          master_subject_id
          subordinate_subject_id
          subjects_ids
        ]
        expect(subject).to match_array(expected_attributes)
      end
    end
  end

  describe CoursePolicy::Scope do
    subject { described_class.new(user, Course).resolve }

    let(:accredited_provider) { create(:provider, :accredited_provider, users: [user]) }
    let(:training_provider) { create(:provider) }
    let!(:course) { create(:course, provider: training_provider, accrediting_provider: accredited_provider) }
    let!(:other_course) { create(:course) }

    context "user from the accredited_provider" do
      it { is_expected.to contain_exactly(course) }
    end

    context "user not from the accredited provider" do
      let(:accredited_provider) { create(:provider, :accredited_provider) }

      it { is_expected.to be_empty }
    end

    context "a user from the provider" do
      let(:user) { create(:user, providers: [training_provider]) }

      it { is_expected.to contain_exactly(course) }
    end

    context "an admin" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to contain_exactly(course, other_course) }
    end
  end
end
