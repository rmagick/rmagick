# frozen_string_literal: true

RSpec.describe Magick::Draw, '#primitive' do
  it 'works' do
    draw = described_class.new

    expect { draw.primitive('ABCDEF') }.not_to raise_error
    expect { draw.primitive('12345') }.not_to raise_error
    expect { draw.primitive(nil) }.to raise_error(TypeError)
  end

  describe 'argument type validation' do
    [nil, 123, :symbol, [1, 2], 1.5, true, { a: 1 }].each do |bad|
      it "raises TypeError for #{bad.inspect} on the first call" do
        draw = described_class.new
        expect { draw.primitive(bad) }.to raise_error(TypeError)
      end

      it "raises TypeError for #{bad.inspect} on a subsequent call" do
        draw = described_class.new
        draw.primitive('fill red')
        expect { draw.primitive(bad) }.to raise_error(TypeError)
      end
    end

    it 'accepts a String' do
      draw = described_class.new
      expect { draw.primitive('fill red') }.not_to raise_error
    end

    it 'accepts an object that responds to #to_str' do
      stringish = Object.new
      def stringish.to_str = 'fill red'
      draw = described_class.new
      expect { draw.primitive(stringish) }.not_to raise_error
    end
  end
end
