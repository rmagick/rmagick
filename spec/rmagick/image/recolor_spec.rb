# frozen_string_literal: true

RSpec.describe Magick::Image, '#recolor' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.recolor([1, 1, 2, 1]) }.not_to raise_error
    expect { image.recolor('x') }.to raise_error(TypeError)
    expect { image.recolor([1, 1, 'x', 1]) }.to raise_error(TypeError)
  end

  # Regression: the matrix order used to be derived from `len + 1`, so an array
  # one element short of a perfect square produced a kernel that read past the
  # end of the allocation and mixed the adjacent heap contents into the result.
  it 'uses only as much of the matrix as forms a square' do
    image = described_class.new(4, 4) { |options| options.background_color = 'red' }
    matrix = [0.9, 0.1, 0.0, 0.0, 0.8, 0.2, 0.1, 0.0]

    expect(image.recolor(matrix).export_pixels).to eq(image.recolor(matrix[0, 4]).export_pixels)
    expect { image.recolor([]) }.not_to raise_error
  end
end
