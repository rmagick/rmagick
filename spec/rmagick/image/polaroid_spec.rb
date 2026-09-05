# frozen_string_literal: true

RSpec.describe Magick::Image, '#polaroid' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.polaroid }.not_to raise_error
    expect { image.polaroid(5) }.not_to raise_error
    expect(image.polaroid).to be_instance_of(described_class)
    expect { image.polaroid('x') }.to raise_error(TypeError)
    expect { image.polaroid(5, 'x') }.to raise_error(ArgumentError)
  end

  # Regression: PolaroidImage runs the Caption property through
  # InterpretImageProperties, which reads a string whose first non-blank
  # character is '@' from the file it names. The property comes from the image
  # file itself, so an uploaded PNG carrying a tEXt chunk of Caption=@/etc/passwd
  # had that file rasterized into the returned image. RMagick cannot draw such a
  # caption as written the way Draw#annotate does in #1837, because ImageMagick 6
  # reads the property inside PolaroidImage rather than taking it as an argument.
  it "rejects a Caption property that begins with '@'" do
    ['@/etc/passwd', '  @/etc/passwd', "\t@/etc/passwd", '@username'].each do |caption|
      image = described_class.new(20, 20)
      image['Caption'] = caption

      expect { image.polaroid }.to raise_error(ArgumentError)
    end
  end

  it "rejects a Caption property the options block sets" do
    image = described_class.new(20, 20)

    expect { image.polaroid { |_options| image['Caption'] = '@/etc/passwd' } }.to raise_error(ArgumentError)
  end

  it "accepts a Caption property with '@' elsewhere" do
    image = described_class.new(20, 20)
    image['Caption'] = 'user@example.com'

    expect { image.polaroid }.not_to raise_error
  end
end
