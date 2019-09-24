require "mcb_helper"

describe "mcb courses edit" do
  def execute_edit(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["courses", "edit", *arguments])
    end
  end

  let(:provider_code) { "X12" }
  let(:course_code) { "3FC4" }
  let(:email) { "user@education.gov.uk" }
  let(:provider) { create(:provider, provider_code: provider_code) }
  let!(:course) {
    create(:course,
           provider: provider,
           course_code: course_code,
           name: "Original name")
  }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context "for an authorised user" do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

    describe "edits the course name for a single course" do
      it "updates the course" do
        expect { execute_edit(arguments: [provider_code, course_code], input: ["edit title", "Mathematics", "exit"]) }.to change { course.reload.name }.
          from("Original name").to("Mathematics")
      end
    end

    describe "trying to edit a course on a nonexistent provider" do
      it "raises an error" do
        expect { execute_edit(arguments: ["ABC", course_code]) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
      end
    end

    describe "not specifying any course codes" do
      let!(:another_course) {
        create(:course,
               provider: provider,
               course_code: "A123",
               name: "Another name")
      }

      it "edits all the courses on the provider" do
        expect { execute_edit(arguments: [provider_code], input: ["edit title", "Mathematics", "exit"]) }.
          to change { provider.reload.courses.order(:name).pluck(:name) }.
          from(["Another name", "Original name"]).to(%w[Mathematics Mathematics])
      end
    end

    context "when the same course exists across multiple recruitment cycles" do
      let!(:next_recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
      let(:provider_in_the_next_recruitment_cycle) {
        create(:provider,
               provider_code: provider_code,
               recruitment_cycle: next_recruitment_cycle,
               organisations: provider.organisations)
      }
      let!(:course_in_the_next_recruitment_cycle) {
        create(:course,
               provider: provider_in_the_next_recruitment_cycle,
               course_code: course_code,
               name: "Original name")
      }

      context "when recruitment cycle is unspecified" do
        it "picks the provider and course from the current recruitment year" do
          expect { execute_edit(arguments: [provider_code, course_code], input: ["edit title", "Mathematics", "exit"]) }.
            to change { course.reload.name }.
            from("Original name").to("Mathematics")

          expect(course_in_the_next_recruitment_cycle.reload.name).to eq("Original name")
        end

        it "ignores providers associated with the next cycle" do
          provider.destroy
          course.destroy

          expect { execute_edit(arguments: [provider_code, course_code], input: ["edit title", "Mathematics", "exit"]) }.
            to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)

          expect(course_in_the_next_recruitment_cycle.reload.name).to eq("Original name")
        end
      end

      context "when recruitment cycle is specified" do
        it "picks the provider and course for the specified recruitment year" do
          expect { execute_edit(arguments: [provider_code, course_code, "-r", next_recruitment_cycle.year], input: ["edit title", "Chemistry", "exit"]) }.
            to change { course_in_the_next_recruitment_cycle.reload.name }.
            from("Original name").to("Chemistry")

          expect(course.reload.name).to eq("Original name")
        end
      end
    end
  end

  context "when a non-existent user tries to edit a course" do
    let!(:requester) { create(:user, email: "someother@email.com") }

    it "raises an error" do
      expect { execute_edit(arguments: [provider_code, course_code]) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
    end
  end
end
