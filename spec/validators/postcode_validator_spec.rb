describe PostcodeValidator do
  # TODO: Use a dummy model here, instead of site.
  let(:site) { build(:site) }

  before do
    site.postcode = postcode
  end

  context 'with a valid UK postcode' do
    let(:postcode) { 'SW1A 1AA' }

    it 'does not add an error' do
      expect(site).to be_valid
    end
  end

  context 'with an invalid UK postcode' do
    let(:postcode) { 'not really a postcode' }

    it 'adds an error' do
      expect(site).not_to be_valid
      expect(site.errors[:postcode]).not_to be_blank
    end
  end

  context 'without a postcode' do
    let(:postcode) { nil }

    it 'adds an error' do
      expect(site).not_to be_valid
      expect(site.errors[:postcode]).not_to be_blank
    end
  end
end
