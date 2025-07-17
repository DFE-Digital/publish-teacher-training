require "rails_helper"

RSpec.describe Import, type: :model do
  subject { build(:import, :register_schools) }

  describe "validations" do
    it { is_expected.to define_enum_for(:import_type).with_values(register_schools: 0) }

    it { is_expected.to validate_presence_of(:short_summary) }
    it { is_expected.to validate_presence_of(:full_summary) }
    it { is_expected.to validate_presence_of(:import_type) }
  end
end
