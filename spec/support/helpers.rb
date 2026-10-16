# frozen_string_literal: true

module TestHelpers
  TEST_PIXELS = {
    RGB: [[45, 98, 156], [209, 171, 11], [239, 236, 2], [8, 65, 247]],
    CMYK: [[23, 54, 186, 76], [29, 71, 131, 122], [239, 206, 99, 76], [84, 165, 47, 54]]
  }.freeze

  def build_image(mode: "RGB", pixels: TEST_PIXELS[mode.to_sym])
    image = Magick::Image.new(2, 2)
    image.import_pixels(0, 0, 2, 2, mode, pixels.flatten)
  end

  def gray(pixel_value)
    [pixel_value, pixel_value, pixel_value]
  end

  def interrupt(error, ready: nil)
    thread = Thread.new do
      Thread.current.report_on_exception = false
      yield
      nil
    rescue error
      nil
    end
    Thread.pass until (ready ? ready.call : thread.status == 'sleep') || !thread.alive?
    thread.raise(error) if thread.alive?
    thread.join
    nil
  end

  module InterruptAtCall
    def handle_interrupt(*)
      result = super
      state = Thread.current[:rmagick_interrupt_at_call]
      if state && (state[:count] += 1) == state[:at]
        Thread.current[:rmagick_interrupt_at_call] = nil
        raise state[:error]
      end
      result
    end
  end
  Thread.singleton_class.prepend(InterruptAtCall)

  def interrupt_each_call(error, limit: 100)
    Thread.new do
      Thread.current.report_on_exception = false
      finished_at = (1..limit).find do |n|
        Thread.current[:rmagick_interrupt_at_call] = { count: 0, at: n, error: error }
        yield
        true
      rescue error
        false
      ensure
        Thread.current[:rmagick_interrupt_at_call] = nil
      end
      raise ArgumentError, "the block made more than #{limit} calls" unless finished_at

      finished_at - 1
    end.value
  end

  # Runs the block with the GC collecting on every allocation, so that anything
  # the extension leaves unreferenced is reclaimed at the first opportunity
  # rather than by chance.
  def with_gc_stress
    GC.stress = true
    yield
  ensure
    GC.stress = false
  end
end
