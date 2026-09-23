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

  # Regression: InterpretImageProperties also evaluates %[fx:...], %[hex:...]
  # and %[pixel:...] escapes, and ImageMagick 7 reads an fx expression that
  # begins with '@' from the file it names, including one in a %[...] nested in
  # another fx expression. A label of "%[fx:@/path]" therefore walked past the
  # check above.
  it "rejects a label with an fx, hex or pixel escape that begins with '@'" do
    info = described_class.new

    [
      '%[fx:@/etc/passwd]',
      '%[FX:@/etc/passwd]',
      '%[hex:@/etc/passwd]',
      '%[pixel:@/etc/passwd]',
      'x %[fx:1+%[fx:@/etc/passwd]]',
      '%[fx:100%%[fx:@/etc/passwd]]'
    ].each do |label|
      expect { info.label = label }.to raise_error(ArgumentError)
    end
    expect(info.label).to be(nil)
  end

  it "accepts a label with an fx escape that does not read a file" do
    info = described_class.new

    expect { info.label = '%[fx:1+1]' }.not_to raise_error
    expect(info.label).to eq('%[fx:1+1]')
  end
end
