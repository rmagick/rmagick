# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#define' do
  it 'works' do
    info = described_class.new

    expect { info.define('tiff', 'bits-per-sample', 2) }.not_to raise_error
    expect { info.undefine('tiff', 'bits-per-sample') }.not_to raise_error
    expect { info.define('tiff', 'bits-per-sample', 2, 2) }.to raise_error(ArgumentError)
    expect { info.define('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end

  it 'copies the image option to an artifact keyed by the option name' do
    image = Magick::Image.new(50, 50)
    image.to_blob do |info|
      info.format = 'PNG'
      info.define('reg', 'probe', 'HELLOARTIFACT')
    end

    draw = Magick::Draw.new
    via_artifact = draw.get_type_metrics(image, '%[artifact:reg:probe]').width
    literal = draw.get_type_metrics(image, 'HELLOARTIFACT').width

    expect(literal).to be_positive
    expect(via_artifact).to eq(literal)

    # The value must not be used as the artifact key.
    via_value_as_key = draw.get_type_metrics(image, '%[artifact:HELLOARTIFACT]').width
    expect(via_value_as_key).to eq(0)
  end
end
