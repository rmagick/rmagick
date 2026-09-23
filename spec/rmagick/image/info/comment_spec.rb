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
end
