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
end
