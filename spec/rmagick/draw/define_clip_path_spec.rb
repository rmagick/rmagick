RSpec.describe Magick::Draw, '#define_clip_path' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    expect { @draw.define_clip_path('test') { @draw } }.not_to raise_error
    expect(@draw.inspect).to eq("push defs\npush clip-path \"test\"\npush graphic-context\npop graphic-context\npop clip-path\npop defs")
  end
end
