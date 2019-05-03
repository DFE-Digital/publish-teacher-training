require 'rails_helper'

describe Course, type: :model do
  describe "#enrichments" do
    subject {
      create(:course, with_enrichments: [
               [:published, created_at: 5.days.ago],
               [:published, created_at: 3.days.ago],
               [:subsequent_draft, created_at: 1.day.ago],
             ]).enrichments
    }

    let(:another_course) {
      create(:course, with_enrichments: [
               [:published, created_at: 5.days.ago],
             ])
    }

    its(:size) { should eq(3) }

    it "doesn't overlap with enrichments from another course" do
      expect(subject & another_course.enrichments).to be_empty
    end
  end

  describe "#content_status" do
    context "for a course without any enrichments" do
      subject { create(:course, with_enrichments: []) }
      its(:content_status) { should eq(:empty) }
    end

    context "for a course an initial draft enrichments" do
      subject { create(:course, with_enrichments: [[:initial_draft]]) }
      its(:content_status) { should eq(:draft) }
    end

    context "for a course with a single published enrichment" do
      subject { create(:course, with_enrichments: [[:published]]) }
      its(:content_status) { should eq(:published) }
    end

    context "for a course with multiple published enrichments" do
      subject { create(:course, with_enrichments: [[:published], [:published]]) }
      its(:content_status) { should eq(:published) }
    end

    context "for a course with published enrichments and a draft one" do
      subject { create(:course, with_enrichments: [[:published], [:subsequent_draft]]) }
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
      let(:subject) do
        create(:course,
               changed_at: 10.minutes.ago,
               with_enrichments: [[:initial_draft,
                                   created_at: 1.day.ago,
                                   updated_at: 20.minutes.ago]])
      end

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
      let(:subject) do
        create(:course, with_enrichments: [
                 [:published, created_at: 5.days.ago],
                 [:published, created_at: 3.days.ago],
                 [:subsequent_draft, created_at: 1.day.ago],
               ])
      end

      it 'publishes the draft' do
        subject.enrichments.each do |enrichment|
          expect(enrichment).to be_published
        end
      end
    end
  end
end
