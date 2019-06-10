require 'rails_helper'

describe Course, type: :model do
  describe "#enrichments" do
    let(:first_course) { first_enrichment.course }
    let(:first_enrichment) { create(:course_enrichment, :published, created_at: 5.days.ago) }
    let(:second_enrichment) { create(:course_enrichment, :published, created_at: 3.days.ago, course: first_course) }
    let(:third_enrichment) { create(:course_enrichment, :subsequent_draft, created_at: 1.day.ago, course: first_course) }
    let(:second_course) { second_courses_enrichment.course }
    let(:second_courses_enrichment) { create(:course_enrichment, :published, created_at: 5.days.ago) }

    before do
      first_course.enrichments = [first_enrichment, second_enrichment, third_enrichment]
      second_course.enrichments = [second_courses_enrichment]
    end

    subject { first_course.enrichments }

    its(:size) { should eq(3) }

    it "doesn't overlap with enrichments from another course" do
      expect(subject & second_course.enrichments).to be_empty
    end
  end

  describe "#content_status" do
    subject { enrichment.course }

    context "for a course without any enrichments" do
      subject { create(:course) }
      its(:content_status) { should eq(:empty) }
    end

    context "for a course an initial draft enrichments" do
      let(:enrichment) { create(:course_enrichment, :initial_draft, created_at: 5.days.ago) }
      its(:content_status) { should eq(:draft) }
    end

    context "for a course with a single published enrichment" do
      let(:enrichment) { create(:course_enrichment, :published) }
      its(:content_status) { should eq(:published) }
    end

    context "for a course with multiple published enrichments" do
      let(:enrichment) { create(:course_enrichment, :published) }
      let(:second_enrichment) { create(:course_enrichment, :published, course: enrichment.course) }


      before do
        subject.enrichments = [enrichment, second_enrichment]
      end

      its(:content_status) { should eq(:published) }
    end

    context "for a course with published enrichments and a draft one" do
      let(:enrichment) { create(:course_enrichment, :published) }
      let(:second_enrichment) { create(:course_enrichment, :subsequent_draft, course: enrichment.course) }

      before do
        subject.enrichments = [enrichment, second_enrichment]
      end

      its(:content_status) { should eq(:published_with_unpublished_changes) }
    end
  end

  describe "#publish_enrichments" do
    let(:user) { create(:user) }

    before do
      subject.publish_enrichment(user)
      subject.reload
    end

    context 'on a course with only a draft enrichment' do
      let(:course_enrichment) {
        create(:course_enrichment,
               :initial_draft,
               created_at: 1.day.ago,
                     updated_at: 20.minutes.ago)
      }

      subject { course_enrichment.course }

      let(:enrichment) { subject.enrichments.first }

      its(:changed_at) { should be_within(1.second).of Time.now.utc }

      it 'publishes the draft' do
        expect(enrichment).to be_published
      end

      it 'updates enrichment updated_at to the current time' do
        expect(enrichment.updated_at).to be_within(1.second).of Time.now.utc
      end

      it 'updates last_published to the current time' do
        expect(enrichment.last_published_timestamp_utc).to be_within(1.second).of Time.now.utc
      end

      it 'updates updated_by to the current user' do
        expect(enrichment.updated_by_user_id).to eq user.id
      end
    end

    context 'on a course with a draft enrichment and previously-published enrichments' do
      let(:enrichment) { create(:course_enrichment, :published, created_at: 5.days.ago) }
      let(:second_enrichment) { create(:course_enrichment, :published, created_at: 3.days.ago, course: course) }
      let(:third_enrichment) { create(:course_enrichment, :subsequent_draft, created_at: 1.day.ago, course: course) }
      let(:course) { enrichment.course }

      subject { course }

      before do
        subject.enrichments = [enrichment, second_enrichment, third_enrichment]
        subject.publish_enrichment(user)
        subject.reload
      end

      it 'publishes the draft' do
        subject.enrichments.each do |enrichment|
          expect(enrichment).to be_published
        end
      end
    end
  end
end
