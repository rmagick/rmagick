# frozen_string_literal: true

describe Magick, '.formats' do
  it 'works', unless: -> { !RUBY_PLATFORM.include?('mingw') } do
    # Skip because it causes "`init_formats': unable to register image format 'DMR'" error on Windows
    expect(described_class.formats).to be_instance_of(Hash)
    described_class.formats.each do |f, v|
      expect(f).to be_instance_of(String)
      expect(v).to match(/[*+\srw]+/)
    end

    described_class.formats do |f, v|
      expect(f).to be_instance_of(String)
      expect(v).to match(/[*+\srw]+/)
    end
  end
end
