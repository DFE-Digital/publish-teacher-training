# == Schema Information
#
# Table name: subject_area
#
#  created_at :datetime         not null
#  name       :text
#  typename   :text             not null, primary key
#  updated_at :datetime         not null
#

describe SubjectArea do
  it "excludes the discontinued subject area" do
    expect(described_class.active.find_by(typename: "DiscontinuedSubject")).to be_nil
  end
end
