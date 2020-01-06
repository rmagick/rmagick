RSpec.describe Magick::Image, "#[]=" do
  it "works" do
    img = described_class.new(20, 20)

    img['label'] = 'foobarbaz'
    img[:comment] = 'Hello world'
    expect(img['label']).to eq('foobarbaz')
    expect(img['comment']).to eq('Hello world')
    expect { img[nil] = 'foobarbaz' }.not_to raise_error
  end
end
