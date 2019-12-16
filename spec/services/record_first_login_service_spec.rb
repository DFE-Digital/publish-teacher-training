describe RecordFirstLoginService do
  let(:service) { described_class.new }

  context "with no previous logins" do
    let(:current_user_spy) { spy(first_login_date_utc: nil) }

    it "updates the first login date" do
      Timecop.freeze do
        update_time = Time.now.utc
        service.execute(current_user: current_user_spy)
        expect(current_user_spy).to have_received(:update).with(first_login_date_utc: update_time)
      end
    end
  end

  context "with previous logins" do
    let(:current_user_spy) { spy(first_login_date_utc: Time.zone.now) }

    it "does not update the first login date" do
      service.execute(current_user: current_user_spy)
      expect(current_user_spy).not_to have_received(:update)
    end
  end
end
