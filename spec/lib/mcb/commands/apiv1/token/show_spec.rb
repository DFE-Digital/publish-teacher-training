require 'spec_helper'
require 'mcb_helper'

describe 'mcb apiv1 token show' do
  context 'with no args' do
    it 'displays the local token' do
      result = with_stubbed_stdout do
        $mcb.run(%w[apiv1 token show])
      end

      expect(result.chomp).to eq 'bats'
    end
  end

  context 'with --webapp set' do
    it 'returns the token returned by get_config' do
      allow(MCB::Azure).to receive(:get_config).and_return(
        'AUTHENTICATION_TOKEN' => 'toke'
      )

      result = with_stubbed_stdout do
        $mcb.run(%w[apiv1 token --webapp az-app show])
      end

      expect(result.chomp).to eq 'toke'
    end
  end
end
