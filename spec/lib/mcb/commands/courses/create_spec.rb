require "mcb_helper"

describe "mcb courses create" do
  def create_new_course_on(provider_code, in_recruitment_year: nil)
    args = in_recruitment_year.present? ? ["-r", in_recruitment_year] : []
    $mcb.run(["courses", "create", provider_code] + args)
  end

  let(:provider_code) { "X12" }
  let(:email) { "user@education.gov.uk" }
  let!(:provider) { create(:provider, provider_code: provider_code) }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context "for an authorised user" do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

    it "launches the courses editor" do
      allow(MCB::Editor::CoursesEditor).to receive(:new).and_return(instance_double(MCB::Editor::CoursesEditor, new_course_wizard: nil))

      create_new_course_on(provider_code)

      expect(MCB::Editor::CoursesEditor).to have_received(:new)
    end

    describe "trying to edit a course on a nonexistent provider" do
      it "raises an error" do
        expect { create_new_course_on("ABC") }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
      end
    end

    context "when the same provider exists across multiple recruitment cycles" do
      let!(:next_recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
      let!(:provider_in_the_next_recruitment_cycle) {
        create(:provider,
               provider_code: provider_code,
               recruitment_cycle: next_recruitment_cycle,
               organisations: provider.organisations)
      }

      before do
        allow(MCB::Editor::CoursesEditor).to receive(:new)
          .and_return(instance_double(MCB::Editor::CoursesEditor, new_course_wizard: nil))
      end

      it "picks the provider in the current cycle by default" do
        create_new_course_on(provider_code)

        expect(MCB::Editor::CoursesEditor)
          .to have_received(:new)
          .with(hash_including(provider: provider, requester: requester))
      end

      it "picks the provider in the specified recruitment cycle when appropriate" do
        create_new_course_on(provider_code, in_recruitment_year: next_recruitment_cycle.year)

        expect(MCB::Editor::CoursesEditor)
          .to have_received(:new)
          .with(hash_including(provider: provider_in_the_next_recruitment_cycle, requester: requester))
      end
    end
  end

  context "when a non-existent user tries to edit a course" do
    let!(:requester) { create(:user, email: "someother@email.com") }

    it "raises an error" do
      expect { create_new_course_on(provider_code) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
    end
  end
end
