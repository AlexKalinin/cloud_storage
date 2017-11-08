shared_examples 'engine interface' do
  it { is_expected.to respond_to(:ls) }
  # it { is_expected.to respond_to(:exist?) }
end
