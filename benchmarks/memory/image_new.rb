require 'rmagick'

1000.times do |i|
  Magick::Image.new(1000, 1000)

  rss = Integer(`ps -o rss= -p #{Process.pid}`) / 1024.0
  puts "#{i},#{rss}"
end
