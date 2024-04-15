require 'rvg/rvg'

Magick::RVG.dpi = 90

BORDER         = { fill: 'none', stroke: 'blue', stroke_width: 1 }
CONNECT        = { fill: 'none', stroke: '#888', stroke_width: 2 }
SAMPLE_PATH    = { fill: 'none', stroke: 'red',  stroke_width: 5 }
END_POINT      = { fill: 'none', stroke: '#888', stroke_width: 2 }
CTL_POINT      = { fill: '#888', stroke: 'none' }
AUTO_CTL_POINT = { fill: 'none', stroke: 'blue', stroke_width: 4 }
LABEL          = { font_size: 22, font_family: 'Verdana', font_weight: 'normal', font_style: 'normal' }

rvg = Magick::RVG.new(5.cm, 4.cm).viewbox(0, 0, 500, 400) do |canvas|
  canvas.title = 'Example cubic01 - cubic Bezier commands in path data'
  canvas.desc = <<-END_DESC
        Picture showing a simple example of path data using both a
        "C" and an "S" command, along with annotations showing the
        control points and end points.
  END_DESC

  canvas.background_fill = 'white'
  canvas.rect(496, 395, 1, 1).styles(BORDER)

  canvas.polyline(100, 200, 100, 100).styles(CONNECT)
  canvas.polyline(250, 100, 250, 200).styles(CONNECT)
  canvas.polyline(250, 200, 250, 300).styles(CONNECT)
  canvas.polyline(400, 300, 400, 200).styles(CONNECT)

  canvas.path('M100,200 C100,100 250,100 250,200 S400,300 400,200').styles(SAMPLE_PATH)

  canvas.circle(10, 100, 200).styles(END_POINT)
  canvas.circle(10, 250, 200).styles(END_POINT)
  canvas.circle(10, 400, 200).styles(END_POINT)
  canvas.circle(10, 100, 100).styles(CTL_POINT)
  canvas.circle(10, 250, 100).styles(CTL_POINT)
  canvas.circle(10, 400, 300).styles(CTL_POINT)
  canvas.circle(9, 250, 300).styles(AUTO_CTL_POINT)

  canvas.text(25, 70, 'M100,200 C100,100 250,100 250,200').styles(LABEL)
  canvas.text(225, 350, 'S400,300 400,200').styles(LABEL)
end

rvg.draw.write('cubic01.gif')
