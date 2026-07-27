# frozen_string_literal: true

describe Magick::RVG::Path do
  it 'accepts SVG path data' do
    path_data = Magick::RVG::PathData.new
    path_data.moveto(true, 0, 0)
    path_data.arc(true, 1, 2, 3, 1, 0, 4, 5)
    path_data.closepath

    expect(described_class.new(path_data)).to be_instance_of(described_class)
    expect { described_class.new('M0,0 L10,10 C1,2 3,4 5,6 Z') }.not_to raise_error
    expect { described_class.new('M1e+20,-1e-20 h1.5 v-2') }.not_to raise_error
    expect { described_class.new("M0,0\n\tL1,1") }.not_to raise_error
    expect { described_class.new('') }.not_to raise_error
  end

  # Regression: the path string was stored unvalidated, and Draw#path wraps it in
  # double quotes without escaping, so a '"' in the path closed the MVG token and
  # the rest of the string was executed as further MVG primitives -- including
  # `image`, which reads an arbitrary file into the rendered output.
  it 'rejects characters outside the SVG path grammar' do
    ['M0,0" image Over 0,0 1,1 "/etc/passwd', "M0,0' x", 'M0,0} x', 'M0,0\\ x'].each do |path|
      expect { described_class.new(path) }.to raise_error(ArgumentError, /invalid character in path data/)
    end
  end

  it 'rejects injected path data given to RVG#path' do
    expect do
      Magick::RVG.new(200, 200) do |canvas|
        canvas.background_fill = 'white'
        canvas.path('M0,0" image Over 0,0 80,80 "/etc/passwd')
      end
    end.to raise_error(ArgumentError, /invalid character in path data/)
  end
end
