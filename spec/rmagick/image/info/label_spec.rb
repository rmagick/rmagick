# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#label' do
  it 'works' do
    info = described_class.new

    expect { info.label = 'string' }.not_to raise_error
    expect(info.label).to eq('string')
    expect { info.label = nil }.not_to raise_error
    expect(info.label).to be(nil)
  end

  # Regression: ReadImage runs the label option through
  # InterpretImageProperties, which reads a string whose first non-blank
  # character is '@' from the file it names. A label of "@/etc/passwd" set in
  # the block of Image.read, Image.ping or Image.from_blob therefore had that file
  # copied into the label property of the image read.
  it "rejects a label that begins with '@'" do
    info = described_class.new

    ['@/etc/passwd', '  @/etc/passwd', "\t@/etc/passwd", '@username'].each do |label|
      expect { info.label = label }.to raise_error(ArgumentError)
    end
    expect(info.label).to be(nil)
  end

  it "rejects a label that begins with '@' from the Image.ping block" do
    expect { Magick::Image.ping(FILES[0]) { |options| options.label = '@/etc/passwd' } }.to raise_error(ArgumentError)
  end

  it "accepts a label with '@' elsewhere" do
    info = described_class.new

    expect { info.label = 'user@example.com' }.not_to raise_error
    expect(info.label).to eq('user@example.com')
  end
end
