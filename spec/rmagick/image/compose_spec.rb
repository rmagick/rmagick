RSpec.describe Magick::Image, '#compose' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.compose }.not_to raise_error
    expect(image.compose).to be_instance_of(Magick::CompositeOperator)
    expect(image.compose).to eq(Magick::OverCompositeOp)
    expect { image.compose = 2 }.to raise_error(TypeError)
    expect { image.compose = Magick::UndefinedCompositeOp }.not_to raise_error
    expect(image.compose).to eq(Magick::UndefinedCompositeOp)

    Magick::CompositeOperator.values do |composite|
      expect { image.compose = composite }.not_to raise_error
    end
    expect { image.compose = 2 }.to raise_error(TypeError)
  end
end
