# frozen_string_literal: true

RSpec.describe Magick::Image, '#properties' do
  it 'returns a hash of assigned properties' do
    image = described_class.new(20, 20)

    image['comment'] = 'str_1'
    image['label'] = 'str_2'
    image['jpeg:sampling-factor'] = '2x1,1x1,1x1'
    expected_properties = { 'comment' => 'str_1', 'label' => 'str_2', 'jpeg:sampling-factor' => '2x1,1x1,1x1' }

    expect(image.properties).to eq(expected_properties)
  end

  it "yields the properties of a frozen image" do
    image = described_class.new(20, 20)
    image["comment"] = "str_1"
    image.freeze

    yielded = []
    expect(image.properties { |name, value| yielded << [name, value] }).to be(image)
    expect(yielded).to eq([%w[comment str_1]])
  end
end
