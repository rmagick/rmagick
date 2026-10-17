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
    EXHAUSTED_RESOURCES = %i[memory map disk].freeze

    def handle_interrupt(*)
      state = Thread.current[:rmagick_interrupt_at_call]
      return super unless state && (state[:count] += 1) == state[:at]

      Thread.current[:rmagick_interrupt_at_call] = nil
      return with_exhausted_resources { super } if state[:exhaust]

      super
      raise state[:error]
    end

    private

    def with_exhausted_resources
      limits = EXHAUSTED_RESOURCES.to_h { |resource| [resource, Magick.limit_resource(resource, 1)] }
      yield
    ensure
      limits&.each { |resource, limit| Magick.limit_resource(resource, limit) }
    end
  end
  Thread.singleton_class.prepend(InterruptAtCall)

  def interrupt_each_call(error, &)
    each_call([error], { error: error }, &)
  end

  def fail_each_call(&)
    each_call([StandardError, NoMemoryError], { exhaust: true }, &)
  end

  def each_call(expected, options)
    Thread.new do
      Thread.current.report_on_exception = false
      counter = { count: 0, at: 0 }
      Thread.current[:rmagick_interrupt_at_call] = counter
      begin
        yield
      ensure
        Thread.current[:rmagick_interrupt_at_call] = nil
      end
      (1..counter[:count]).each do |n|
        Thread.current[:rmagick_interrupt_at_call] = options.merge(count: 0, at: n)
        yield
      rescue *expected
        nil
      ensure
        Thread.current[:rmagick_interrupt_at_call] = nil
      end
      counter[:count]
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
