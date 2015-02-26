#!/usr/bin/env ruby -w
require 'rmagick'

# Compute column widths
name_length = 0
family_length = 0
Magick.fonts do |font|
  if font.name.length > name_length
    name_length = font.name.length
  end
  if font.family.length > family_length
    family_length = font.family.length
  end
end

# Print all fonts
Magick.fonts do |font|
  printf("%-*s %-*s %d %s\t%s\n", name_length, font.name,
         family_length, font.family, font.weight, font.style, font.stretch)
end
