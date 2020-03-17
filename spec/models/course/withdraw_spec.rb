describe Course, type: :model do
  describe "withdraw" do
    let(:course) { create(:course, provider: provider, site_statuses: [site_status1, site_status2, site_status3], enrichments: [enrichment]) }
    let(:provider) { build(:provider) }
    let(:enrichment) { build(:course_enrichment) }
    let(:site_status1) { build(:site_status, :running, :published, :full_time_vacancies, site: site) }
    let(:site_status2) { build(:site_status, :new, :full_time_vacancies, site: site) }
    let(:site_status3) { build(:site_status, :suspended, :with_no_vacancies, site: site) }
    let(:site) { build(:site, provider: provider) }

    before do
      course.withdraw
    end

    context "a published course" do
      let(:enrichment) { build(:course_enrichment, :published) }

      it "should not be findable" do
        expect(course.findable?).to eq(false)
      end

      it "should not be published" do
        expect(course.is_published?).to eq(false)
      end

      it "should have updated the courses site statuses to be suspended and have no vacancies" do
        expect(site_status1.vac_status).to eq("no_vacancies")
        expect(site_status1.status).to eq("suspended")
        expect(site_status2.vac_status).to eq("no_vacancies")
        expect(site_status2.status).to eq("suspended")
        expect(site_status3.vac_status).to eq("no_vacancies")
        expect(site_status3.status).to eq("suspended")
      end

      it "should have a content_status of withdrawn" do
        expect(course.content_status).to eq(:withdrawn)
      end
    end

    context "an unpublished course" do
      it "should not have updated the courses site statuses or vac status" do
        expect(site_status1.vac_status).to eq("full_time_vacancies")
        expect(site_status1.status).to eq("running")
        expect(site_status2.vac_status).to eq("full_time_vacancies")
        expect(site_status2.status).to eq("new_status")
        expect(site_status3.vac_status).to eq("no_vacancies")
        expect(site_status3.status).to eq("suspended")
      end

      it "should add an error to the course" do
        expect(course.reload.errors[:withdraw].first).to eq("Courses that have not been published should be deleted not withdrawn")
      end
    end
  end
end
