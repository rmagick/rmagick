RSpec.describe Magick::Image, "#[]=" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    @img['label'] = 'foobarbaz'
    @img[:comment] = 'Hello world'
    expect(@img['label']).to eq('foobarbaz')
    expect(@img['comment']).to eq('Hello world')
    expect { @img[nil] = 'foobarbaz' }.not_to raise_error
  end
end
