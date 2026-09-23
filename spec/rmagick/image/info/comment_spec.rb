# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#comment' do
  it 'works' do
    info = described_class.new

    expect { info.comment = 'comment' }.not_to raise_error
    expect(info.comment).to eq('comment')
  end

  # Regression: ReadImage runs the comment option through
  # InterpretImageProperties, which reads a string whose first non-blank
  # character is '@' from the file it names. A comment of "@/etc/passwd" set in
  # the block of Image.read, Image.ping or Image.from_blob therefore had that file
  # copied into the comment property of the image read.
  it "rejects a comment that begins with '@'" do
    info = described_class.new

    ['@/etc/passwd', '  @/etc/passwd', "\t@/etc/passwd", '@username'].each do |comment|
      expect { info.comment = comment }.to raise_error(ArgumentError)
    end
    expect(info.comment).to be(nil)
  end

  it "rejects a comment that begins with '@' from the Image.from_blob block" do
    blob = Magick::Image.new(20, 20).to_blob { |options| options.format = 'PNG' }

    expect { Magick::Image.from_blob(blob) { |options| options.comment = '@/etc/passwd' } }.to raise_error(ArgumentError)
  end

  it "accepts a comment with '@' elsewhere" do
    image = Magick::Image.read(FILES[0]) { |options| options.comment = 'user@example.com' }.first

    expect(image['comment']).to eq('user@example.com')
  end

  # Regression: InterpretImageProperties also evaluates %[fx:...], %[hex:...]
  # and %[pixel:...] escapes, and ImageMagick 7 reads an fx expression that
  # begins with '@' from the file it names, including one in a %[...] nested in
  # another fx expression. A comment of "%[fx:@/path]" therefore walked past the
  # check above.
  it "rejects a comment with an fx, hex or pixel escape that begins with '@'" do
    info = described_class.new

    [
      '%[fx:@/etc/passwd]',
      '%[FX:@/etc/passwd]',
      '%[hex:@/etc/passwd]',
      '%[pixel:@/etc/passwd]',
      'x %[fx:1+%[fx:@/etc/passwd]]',
      '%[fx:100%%[fx:@/etc/passwd]]'
    ].each do |comment|
      expect { info.comment = comment }.to raise_error(ArgumentError)
    end
    expect(info.comment).to be(nil)
  end

  it "accepts a comment with an fx escape that does not read a file" do
    image = Magick::Image.read(FILES[0]) { |options| options.comment = '%[fx:1+1]' }.first

    expect(image['comment']).to eq('2')
  end
end
