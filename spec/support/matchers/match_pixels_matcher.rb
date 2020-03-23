module Matchers
  class MatchPixels
    attr_accessor :actual, :expected, :delta

    def initialize(expected, delta:)
      self.expected = expected.flatten
      self.delta = delta
    end

    def matches?(actual)
      self.actual = actual

      actual.export_pixels.each_with_index.all? do |value, index|
        expected_value = expected[index]
        value.between?(expected_value - delta, expected_value + delta)
      end
    end

    def failure_message
      "expected all pixel values to differ by max #{delta}\n" \
        "\nexpected: #{expected}\n     got: #{actual.export_pixels}\n\n\n"
    end
  end
end
