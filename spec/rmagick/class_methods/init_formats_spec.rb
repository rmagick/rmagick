# frozen_string_literal: true

RSpec.describe Magick, '.init_formats' do
  it 'works', unless: -> { RUBY_PLATFORM !~ /mswin|mingw/ } do
    # Skip because it causes "`init_formats': unable to register image format 'DMR'" error on Windows
    expect(described_class.init_formats).to be_instance_of(Hash)
  end
end
