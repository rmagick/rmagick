# frozen_string_literal: true

RSpec.describe Magick::Image, '#fx' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.fx('1/2') }.not_to raise_error
    expect { image.fx('1/2', Magick::BlueChannel) }.not_to raise_error
    expect { image.fx('1/2', Magick::BlueChannel, Magick::RedChannel) }.not_to raise_error
    expect { image.fx }.to raise_error(ArgumentError)
    expect { image.fx(Magick::BlueChannel) }.to raise_error(ArgumentError)
    expect { image.fx(1) }.to raise_error(TypeError)
    expect { image.fx('1/2', 1) }.to raise_error(TypeError)
  end

  it "rejects an expression that names a file with '@'" do
    image = described_class.new(1, 1)

    Tempfile.create(['fx', '.txt']) do |file|
      file.write('0.25')
      file.flush

      ["@#{file.path}", "  @#{file.path}", "0*u+%[fx:@#{file.path}]", "0*u+%[FX:@#{file.path}]", "%[hex:@#{file.path}]", "%[pixel:@#{file.path}]"].each do |expression|
        expect { image.fx(expression) }.to raise_error(ArgumentError, /must not name a file/)
      end
    end
  end

  it 'accepts an fx escape that does not name a file' do
    image = described_class.new(1, 1)

    ['0*u+%[fx:1/2]', '%[fx:w]'].each do |expression|
      expect do
        image.fx(expression)
      rescue Magick::ImageMagickError
        nil
      end.not_to raise_error
    end
  end
end
