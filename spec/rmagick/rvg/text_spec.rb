# frozen_string_literal: true

describe Magick::RVG, '#text' do
  # The quoted operand of every `text` primitive in the MVG the canvas builds.
  def text_tokens(text, **styles)
    rvg = described_class.new(300, 60) do |canvas|
      element = canvas.text(10, 30, text)
      element.styles(**styles) unless styles.empty?
    end
    gc = Magick::RVG::Utility::GraphicContext.new
    rvg.add_outermost_primitives(gc)
    gc.inspect.lines.grep(/\Atext /).map { |line| line.chomp.split(' ', 3).last }
  end

  # The same operand, quoted by Magick::Draw#text alone.
  def draw_token(text)
    draw = Magick::Draw.new
    draw.text(10, 30, text)
    draw.inspect.split(' ', 3).last
  end

  # Regression: TextStrategy#enquote wrapped the text in quotes before handing it
  # to Magick::Draw#text, which quotes it itself. Draw#text does not trust a
  # string that merely looks quoted -- it cannot, because that is how text ending
  # in a backslash used to break out of the MVG token -- so the quotes enquote had
  # added were drawn as part of the text.
  it 'quotes the text exactly once' do
    ['plain text', "a'b", 'a"b', "a'b\"c", 'a{b}c', 'C:\\path', 'trailing backslash\\', "a'b\"c\\}"].each do |text|
      expect(text_tokens(text)).to eq([draw_token(text)])
    end
  end

  it 'quotes vertical text exactly once' do
    expect(text_tokens("x\\", writing_mode: 'tb')).to eq([draw_token('x'), draw_token("\\")])
  end
end
