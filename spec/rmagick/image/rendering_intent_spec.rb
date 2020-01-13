RSpec.describe Magick::Image, '#rendering_intent' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.rendering_intent }.not_to raise_error
    expect(@img.rendering_intent).to be_instance_of(Magick::RenderingIntent)
    expect(@img.rendering_intent).to eq(Magick::PerceptualIntent)

    Magick::RenderingIntent.values do |rendering_intent|
      expect { @img.rendering_intent = rendering_intent }.not_to raise_error
    end
    expect { @img.rendering_intent = 2 }.to raise_error(TypeError)
  end
end
