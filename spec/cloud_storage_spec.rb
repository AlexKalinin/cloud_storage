require 'spec_helper'

RSpec.describe CloudStorage do
  it 'has a version number' do
    expect(CloudStorage::VERSION).not_to be nil
  end
end
