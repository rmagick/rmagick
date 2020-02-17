RSpec.describe Magick::Image, '#rendering_intent' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.rendering_intent }.not_to raise_error
    expect(image.rendering_intent).to be_instance_of(Magick::RenderingIntent)
    expect(image.rendering_intent).to eq(Magick::PerceptualIntent)

    Magick::RenderingIntent.values do |rendering_intent|
      expect { image.rendering_intent = rendering_intent }.not_to raise_error
    end
    expect { image.rendering_intent = 2 }.to raise_error(TypeError)
  end
end
