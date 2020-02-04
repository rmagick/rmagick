require_relative 'matchers/match_pixels_matcher'

def match_pixels(expected, delta: 0)
  Matchers::MatchPixels.new(expected, delta: delta)
end
