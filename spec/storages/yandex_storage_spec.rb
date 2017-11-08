require 'spec_helper'

RSpec.describe CloudStorage::Engine::Yandex do
  let(:folder_name) { 'sample' }
  let(:file_name) { 'photo.jpg' }
  let(:new_folder_name) { '/new_folder' }
  let(:new_file_name) { '/new_text_file.txt' }

  before(:all) do
    @engine = described_class.new(token: ENV['YANDEX_TOKEN'])
  end

  # it_behaves_like 'engine interface'

  it 'ls' do
    list = @engine.ls('/')
    expect(list.find { |item| item.name == folder_name }).to_not be_nil
    expect(list.find { |item| item.name == file_name }).to_not be_nil
  end

  it 'exists?' do
    expect(@engine.exists?('/not_exists')).to be_falsey
    expect(@engine.exists?('/' + folder_name)).to be_truthy
    expect(@engine.exists?('/' + file_name)).to be_truthy
  end

  it 'mkdir and rm' do
    @engine.rm(new_folder_name) if @engine.exists?(new_folder_name)
    # mkdir
    expect(@engine.mkdir(new_folder_name)).to be_truthy
    expect(@engine.exists?(new_folder_name)).to be_truthy
    # rm
    expect(@engine.rm(new_folder_name)).to be_truthy
    expect(@engine.exists?(new_folder_name)).to be_falsey
  end
end
