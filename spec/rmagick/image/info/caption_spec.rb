# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#caption' do
  it 'works' do
    info = described_class.new

    expect { info.caption = 'string' }.not_to raise_error
    expect(info.caption).to eq('string')
    expect { info.caption = nil }.not_to raise_error
    expect(info.caption).to be(nil)
    expect { Magick::Image.new(20, 20) { |options| options.caption = 'string' } }.not_to raise_error
  end

  # Regression: ReadImage runs the caption option through
  # InterpretImageProperties, which reads a string whose first non-blank
  # character is '@' from the file it names. A caption of "@/etc/passwd" set in
  # the block of Image.read, Image.ping or Image.from_blob therefore had that file
  # copied into the caption property of the image read.
  it "rejects a caption that begins with '@'" do
    info = described_class.new

    ['@/etc/passwd', '  @/etc/passwd', "\t@/etc/passwd", '@username'].each do |caption|
      expect { info.caption = caption }.to raise_error(ArgumentError)
    end
    expect(info.caption).to be(nil)
  end

  it "rejects a caption that begins with '@' from the Image.read block" do
    expect { Magick::Image.read(FILES[0]) { |options| options.caption = '@/etc/passwd' } }.to raise_error(ArgumentError)
  end

  it "accepts a caption with '@' elsewhere" do
    info = described_class.new

    expect { info.caption = 'user@example.com' }.not_to raise_error
    expect(info.caption).to eq('user@example.com')
  end
end
