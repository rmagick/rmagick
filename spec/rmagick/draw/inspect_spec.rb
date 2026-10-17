# frozen_string_literal: true

RSpec.describe Magick::Draw, '#inspect' do
  it 'works' do
    draw = described_class.new

    expect(draw.inspect).to eq('(no primitives defined)')

    draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    draw.fill('yellow')
    expect(draw.inspect).to eq("path \"M110,100 h-75 a75,75 0 1,0 75,-75 z\"\nfill \"yellow\"")
  end

  it "returns a copy of the primitives" do
    draw = described_class.new
    draw.primitive("point 0,0")
    draw.freeze
    draw.inspect << "\ncircle 5,5 5,9"

    expect(draw.inspect).to eq("point 0,0")
  end
end
