RSpec.describe Magick::Image, "#[]=" do
  it "works" do
    image = described_class.new(20, 20)

    image['label'] = 'foobarbaz'
    image[:comment] = 'Hello world'
    expect(image['label']).to eq('foobarbaz')
    expect(image['comment']).to eq('Hello world')
    expect { image[nil] = 'foobarbaz' }.not_to raise_error
  end
end
