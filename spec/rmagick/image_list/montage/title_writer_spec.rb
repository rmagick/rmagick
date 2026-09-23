# frozen_string_literal: true

RSpec.describe Magick::ImageList::Montage, '#title=' do
  it 'works' do
    montage = described_class.new

    expect { montage.title = 'sample' }.not_to raise_error
  end

  # Regression: MontageImages runs the title through InterpretImageProperties,
  # which reads a string whose first non-blank character is '@' from the file it
  # names. A title of "@/etc/passwd" therefore had that file rasterized into the
  # montage. RMagick cannot draw such a title as written the way Draw#annotate
  # does in #1837, because both ImageMagick 6 and 7 interpret the title inside
  # MontageImages rather than taking already interpreted text.
  it "rejects a title that begins with '@'" do
    ['@/etc/passwd', '  @/etc/passwd', "\t@/etc/passwd", '@username'].each do |title|
      montage = described_class.new

      expect { montage.title = title }.to raise_error(ArgumentError)
    end
  end

  it "rejects a title that begins with '@' from the ImageList#montage block" do
    image_list = Magick::ImageList.new
    image_list.new_image(20, 20)

    expect { image_list.montage { |options| options.title = '@/etc/passwd' } }.to raise_error(ArgumentError)
  end

  it "accepts a title with '@' elsewhere" do
    image_list = Magick::ImageList.new
    image_list.new_image(20, 20)

    expect { image_list.montage { |options| options.title = 'user@example.com' } }.not_to raise_error
  end

  # Regression: InterpretImageProperties also evaluates %[fx:...], %[hex:...]
  # and %[pixel:...] escapes, and ImageMagick 7 reads an fx expression that
  # begins with '@' from the file it names, including one in a %[...] nested in
  # another fx expression. A title of "%[fx:@/path]" therefore walked past the
  # check above.
  it "rejects a title with an fx, hex or pixel escape that begins with '@'" do
    [
      '%[fx:@/etc/passwd]',
      '%[FX:@/etc/passwd]',
      '%[hex:@/etc/passwd]',
      '%[pixel:@/etc/passwd]',
      'x %[fx:1+%[fx:@/etc/passwd]]',
      '%[fx:100%%[fx:@/etc/passwd]]'
    ].each do |title|
      montage = described_class.new

      expect { montage.title = title }.to raise_error(ArgumentError)
    end
  end

  it "accepts a title with an fx escape that does not read a file" do
    ['%[fx:1+1]', '%[fx:w/2]', 'user@example.com %[fx:1+1]'].each do |title|
      image_list = Magick::ImageList.new
      image_list.new_image(20, 20)

      expect { image_list.montage { |options| options.title = title } }.not_to raise_error
    end
  end
end
