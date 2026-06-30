# frozen_string_literal: true

# Regression: Draw_alloc leaves draw->info == NULL until #initialize runs.
# Methods that dereference draw->info used to crash the process (SIGSEGV) when
# called on an object obtained via .allocate, or on a subclass whose #initialize
# does not call super. They must raise RuntimeError instead.
RSpec.describe Magick::Draw do
  shared_examples 'raises instead of crashing' do
    it 'fill= raises RuntimeError' do
      expect { draw_obj.fill = 'red' }.to raise_error(RuntimeError)
    end

    it 'gravity= raises RuntimeError' do
      expect { draw_obj.gravity = Magick::CenterGravity }.to raise_error(RuntimeError)
    end

    it 'annotate raises RuntimeError' do
      img = Magick::Image.new(2, 2)
      expect { draw_obj.annotate(img, 2, 2, 0, 0, 'x') }.to raise_error(RuntimeError)
    end

    it 'get_type_metrics raises RuntimeError' do
      img = Magick::Image.new(2, 2)
      expect { draw_obj.get_type_metrics(img, 'x') }.to raise_error(RuntimeError)
    end

    it 'marshal_dump raises RuntimeError' do
      expect { draw_obj.marshal_dump }.to raise_error(RuntimeError)
    end

    it 'draw raises RuntimeError once primitives are present' do
      draw_obj.primitive('fill red')
      expect { draw_obj.draw(Magick::Image.new(2, 2)) }.to raise_error(RuntimeError)
    end
  end

  context 'when obtained via .allocate' do
    let(:draw_obj) { described_class.allocate }

    it_behaves_like 'raises instead of crashing'
  end

  context 'when a subclass #initialize does not call super' do
    let(:subclass) do
      Class.new(described_class) { def initialize; end } # rubocop:disable Lint/MissingSuper, Style/RedundantInitialize
    end
    let(:draw_obj) { subclass.new }

    it_behaves_like 'raises instead of crashing'
  end

  context 'when the method does not require DrawInfo' do
    it 'primitive works' do
      expect { described_class.allocate.primitive('fill red') }.not_to raise_error
    end

    it 'inspect works' do
      expect { described_class.allocate.inspect }.not_to raise_error
    end

    it 'dup works' do
      expect { described_class.allocate.dup }.not_to raise_error
    end
  end

  context 'when fully initialized' do
    it 'accepts setters' do
      draw = described_class.new
      expect { draw.fill = 'red' }.not_to raise_error
      expect { draw.gravity = Magick::CenterGravity }.not_to raise_error
    end

    it 'Marshal round-trips' do
      expect { Marshal.load(Marshal.dump(described_class.new)) }.not_to raise_error
    end
  end
end
