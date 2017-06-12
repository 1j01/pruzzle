
puz_canvas = document.createElement("canvas")
puz_ctx = puz_canvas.getContext("2d")
puzzle_x = 320
puzzle_y = 160
puz_canvas.width = 150 * 5
puz_canvas.height = 150 * 5

sunset = puz_ctx.createLinearGradient 0, 0, 0, puz_canvas.height

sunset.addColorStop 0.000, 'rgb(0, 255, 242)'
sunset.addColorStop 0.442, 'rgb(107, 99, 255)'
sunset.addColorStop 0.836, 'rgb(255, 38, 38)'
sunset.addColorStop 0.934, 'rgb(255, 135, 22)'
sunset.addColorStop 1.000, 'rgb(255, 252, 0)'

puz_ctx.fillStyle = sunset
puz_ctx.fillRect 0, 0, puz_canvas.width, puz_canvas.height

puz_ctx.save()
t = 20
puz_ctx.translate(puz_canvas.width / 2, puz_canvas.height / 2)
for i in [0..100]
	puz_ctx.rotate(t / 56)
	puz_ctx.fillRect(cos(t/6)*150*sin(i/60+t), 50, 15, cos(t/6+i) * 50)
puz_ctx.restore()

puz_ctx.save()
t = 200
puz_ctx.fillStyle = "yellow"
#puz_ctx.translate(puz_canvas.width / 2, puz_canvas.height / 2)
for i in [0..100]
	puz_ctx.rotate(t / 56)
	puz_ctx.fillRect(cos(t/6)*150*sin(i/60+t), 50, 1, cos(t/6+i) * 50)
puz_ctx.restore()

pointers = {}

class Piece
	constructor: ->
		@x = 10
		@y = 10
		@puz_x = 0
		@puz_y = 0
		@puz_w = 150
		@puz_h = 150
		@points =
			for [0..4]
				x: random() * @puz_w
				h: random() * @puz_h
				piece: @
	
	makePath: ->
		ctx.beginPath()
		#ctx.rect(@puz_x, @puz_y, @puz_w, @puz_h)
		#ctx.rect(@puz_x, @puz_y, @puz_w-15, @puz_h-15)
		#ctx.rect(@puz_x+15, @puz_y+15, @puz_w-15, @puz_h-15)
		ctx.save()
		ctx.translate(@puz_x, @puz_y)
		ctx.moveTo(0, 0)
		r = @puz_w/5
		ctx.arc(@puz_w/2, 0, r, -TAU/2, 0, true) if @puz_y > 0
		ctx.lineTo(@puz_w, 0)
		ctx.arc(@puz_w, @puz_h/2, r, -TAU/4, TAU/4, false) if @puz_x + @puz_w < puz_canvas.width
		ctx.lineTo(@puz_w, @puz_h)
		ctx.arc(@puz_w/2, @puz_h, r, 0, TAU/2, false) if @puz_y + @puz_h < puz_canvas.height
		ctx.lineTo(0, @puz_h)
		ctx.arc(0, @puz_h/2, r, TAU/4, -TAU/4, true) if @puz_x > 0
		ctx.lineTo(0, 0)
		ctx.closePath()
		ctx.restore()
	
	draw: ->
		held = false
		for pointerId, pointer of pointers
			if pointer.drag_piece is @
				held = true
		hovered = @hover and not held
		
		ctx.save()
		ctx.globalAlpha = 0.8 if held
		
		ctx.translate(@x, @y)
		@makePath()
		
		ctx.save()
		ctx.clip()
		
		#ctx.fillStyle = "white"
		#ctx.fill()
		#ctx.drawImage(puz_canvas, puzzle_x - @x, puzzle_y - @y)
		#ctx.translate(-@x, -@y)
		#ctx.drawImage(puz_canvas, puzzle_x + @x, puzzle_y + @y)
		#ctx.drawImage(puz_canvas, @x, @y)
		#ctx.translate(-@puz_x, -@puz_y)
		ctx.drawImage(puz_canvas, 0, 0)
		
		#ctx.strokeStyle = if @hover then "yellow" else "white"
		#ctx.strokeStyle = if held then "lime" else if @hover then "yellow" else "white"
		#ctx.strokeStyle = "white"
		if hovered
			ctx.strokeStyle = "yellow"
			ctx.lineWidth = 6
			ctx.stroke()
		
		# XXX: pillow shading
		#ctx.strokeStyle = "white"
		#ctx.lineWidth = 4
		#ctx.stroke()
		
		ctx.shadowColor = "rgba(255, 255, 255, 0.6)"
		ctx.shadowOffsetX = 0
		ctx.shadowOffsetY = 1.5
		
		#ctx.strokeStyle = if hovered then "yellow" else "black"
		ctx.strokeStyle = "black"
		ctx.lineWidth = 2
		ctx.stroke()
		
		ctx.restore()
		ctx.restore()
		
		#ctx.strokeStyle = "rgba(0,0,0,0.5)"
		#ctx.lineWidth = 1
		#ctx.stroke()
		

class Grid
	constructor: ->
		
	
	get: ->
		

toCanvasPosition = (evt)->
	rect = canvas.getBoundingClientRect()  # absolute position and size of element
	scaleX = canvas.width / rect.width     # relationship bitmap vs. element for X
	scaleY = canvas.height / rect.height   # relationship bitmap vs. element for Y
	
	x: (evt.clientX - rect.left) * scaleX  # scale mouse coordinates after they have
	y: (evt.clientY - rect.top) * scaleY   # been adjusted to be relative to element

canvas.setAttribute "touch-action", "none"

canvas.addEventListener "mousemove", (e)->
	{x, y} = toCanvasPosition(e)
	for piece in pieces
		piece.makePath()
		if ctx.isPointInPath(x - piece.x, y - piece.y)
			drag_piece = piece
			#break
	for piece in pieces
		piece.hover = piece is drag_piece
	canvas.style.cursor = if drag_piece then "move" else "default"

canvas.addEventListener "pointerdown", (e)->
	#undoable()
	{x, y} = toCanvasPosition(e)
	for piece in pieces
		piece.makePath()
		if ctx.isPointInPath(x - piece.x, y - piece.y)
			drag_piece = piece
			#break
	
	if drag_piece
		pieces.splice(pieces.indexOf(drag_piece), 1)
		pieces.push(drag_piece)
	
	pointers[e.pointerId] =
		x: x
		y: y
		drag_piece: drag_piece
		offset_x: drag_piece?.x - x
		offset_y: drag_piece?.y - y

canvas.addEventListener "pointermove", (e)->
	{x, y} = toCanvasPosition(e)
	pointer = pointers[e.pointerId]
	if pointer
		pointer.x = x
		pointer.y = y
		if pointer.drag_piece
			piece = pointer.drag_piece
			piece.x = x + pointer.offset_x
			piece.y = y + pointer.offset_y
			
			align_x = Math.round((piece.x - puzzle_x) / 150) * 150 + puzzle_x
			align_y = Math.round((piece.y - puzzle_y) / 150) * 150 + puzzle_y
			
			d = 20
			if (
				abs(pointer.drag_piece.x - align_x) < d and
				abs(pointer.drag_piece.y - align_y) < d
			)
				pointer.drag_piece.x = align_x
				pointer.drag_piece.y = align_y
			

canvas.addEventListener "pointerup", (e)->
	delete pointers[e.pointerId]

canvas.addEventListener "pointercancel", (e)->
	# NOTE: maybe ought to revert to original position of piece
	delete pointers[e.pointerId]


pieces = []
grid = new Grid

for x_i in [0...5]
	for y_i in [0...5]
		piece = new Piece
		piece.puz_x = x_i * 150
		piece.puz_y = y_i * 150
		piece.x = -x_i * 150 + 10
		piece.y = -y_i * 150 + 10
		pieces.push piece

pieces.sort((a, b)-> a.x + a.y % b.y > b.x - a.y)
pieces.sort((a, b)-> (a.x + a.y) % b.y - (b.x % 3) - (a.y % 6) - (a.x % 3))

for piece, i in pieces
	piece.x += i * 2
	piece.y += i * 1

shapes = []

key_pieces = pieces.slice(pieces.length-3, pieces.length)

shapes.push({
	center: key_pieces[0].points[0]
	draw: ->
		#puz_ctx.moveTo
		puz_ctx.beginPath()
		puz_ctx.arc(@center.x + @center.piece.x, @center.y + @center.piece.y, 500, 0, TAU)
		#puz_ctx.arc(0, 0, 500, 0, TAU)
		puz_ctx.fillStyle = "red"
		puz_ctx.fill()
})

animate ->
	ctx.clearRect(0, 0, canvas.width, canvas.height)
	ctx.beginPath()
	ctx.rect(puzzle_x, puzzle_y, puz_canvas.width, puz_canvas.height)
	ctx.fillStyle = "rgba(0, 0, 0, 0.1)"
	ctx.fill()
	for shape in shapes
		shape.draw()
	for piece in pieces
		piece.draw()
