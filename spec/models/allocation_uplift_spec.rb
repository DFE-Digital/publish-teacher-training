require 'rails_helper'

RSpec.describe AllocationUplift, type: :model do
  it { is_expected.to belong_to(:allocation) }
end
