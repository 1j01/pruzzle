
puz_canvas = document.createElement("canvas")
puz_ctx = puz_canvas.getContext("2d")
puzzle_x = 320
puzzle_y = 160
puz_canvas.width = 150 * 5
puz_canvas.height = 150 * 5
# TODO: render the puzzle on the pieces outside of the puzzle bounds
# probably simplest to size puzzle canvas the same as the playing area

pointers = {}

class Piece
	constructor: ->
		@x = 10
		@y = 10
		@puz_x = 0
		@puz_y = 0
		@puz_w = 150
		@puz_h = 150
		
		@calcPath()
		
		@points =
			for [0..4]
				x: random() * @puz_w
				y: random() * @puz_h
				piece: @
		
		@is_key = false # "key pieces are sort of like the *key* to the puzzle"
		# "... / level / pruzzle / pruzzle level"
		@okay = false # whether on the grid and such
		@locked = false # not allowed to move; applies to key pieces
	
	calcPath: ->
		@path = new Path2D
		# @path.rect(@puz_x, @puz_y, @puz_w, @puz_h)
		# @path.rect(@puz_x, @puz_y, @puz_w-15, @puz_h-15)
		# @path.rect(@puz_x+15, @puz_y+15, @puz_w-15, @puz_h-15)
		@path.moveTo(0, 0)
		r = @puz_w/5
		@path.arc(@puz_w/2, 0, r, -TAU/2, 0, true) if @puz_y > 0
		@path.lineTo(@puz_w, 0)
		@path.arc(@puz_w, @puz_h/2, r, -TAU/4, TAU/4, false) if @puz_x + @puz_w < puz_canvas.width
		@path.lineTo(@puz_w, @puz_h)
		@path.arc(@puz_w/2, @puz_h, r, 0, TAU/2, false) if @puz_y + @puz_h < puz_canvas.height
		@path.lineTo(0, @puz_h)
		@path.arc(0, @puz_h/2, r, TAU/4, -TAU/4, true) if @puz_x > 0
		@path.lineTo(0, 0)
		@path.closePath()
	
	draw: ->
		held = false
		for pointerId, pointer of pointers
			if pointer.drag_piece is @
				held = true
		hovered = @hover and not held
		
		ctx.save()
		ctx.globalAlpha = 0.8 if held
		
		ctx.translate(@x, @y)
		
		ctx.save()
		ctx.clip(@path)
		
		#ctx.fillStyle = "white"
		#ctx.fill()
		#ctx.drawImage(puz_canvas, puzzle_x - @x, puzzle_y - @y)
		#ctx.translate(-@x, -@y)
		#ctx.drawImage(puz_canvas, puzzle_x + @x, puzzle_y + @y)
		#ctx.drawImage(puz_canvas, @x, @y)
		#ctx.translate(-@puz_x, -@puz_y)
		ctx.drawImage(puz_canvas, -@puz_x, -@puz_y)
		
		#ctx.strokeStyle = if @hover then "yellow" else "white"
		#ctx.strokeStyle = if held then "lime" else if @hover then "yellow" else "white"
		#ctx.strokeStyle = "white"
		if hovered
			ctx.strokeStyle = "yellow"
			ctx.strokeStyle = "lime" if @is_key
			ctx.lineWidth = 6
			ctx.stroke(@path)
		
		ctx.strokeStyle = "rgba(255, 255, 255, 0.6)"
		ctx.lineWidth = 2
		ctx.translate(0, 1)
		ctx.stroke(@path)
		ctx.translate(0, -1)
		
		ctx.strokeStyle = "black"
		ctx.lineWidth = 2
		ctx.stroke(@path)
		
		ctx.restore()
		ctx.restore()

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
	for piece in pieces when not piece.locked
		if ctx.isPointInPath(piece.path, x - piece.x, y - piece.y)
			drag_piece = piece
			#break
	for piece in pieces
		piece.hover = piece is drag_piece
	canvas.style.cursor = if drag_piece then "move" else "default"

canvas.addEventListener "pointerdown", (e)->
	#undoable()
	{x, y} = toCanvasPosition(e)
	for piece in pieces when not piece.locked
		if ctx.isPointInPath(piece.path, x - piece.x, y - piece.y)
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
		piece = pointer.drag_piece
		if piece
			piece.x = x + pointer.offset_x
			piece.y = y + pointer.offset_y
			
			align_x = Math.round((piece.x - puzzle_x) / 150) * 150 + puzzle_x
			align_y = Math.round((piece.y - puzzle_y) / 150) * 150 + puzzle_y
			
			d = 20
			if (
				abs(piece.x - align_x) < d and
				abs(piece.y - align_y) < d
			)
				piece.x = align_x
				piece.y = align_y
				# TODO: check geometric plausibility
				# - within the puzzle bounds
				# - not intersecting any placed pieces
				# - edge/corner pieces against sides
				# (although maybe it should let you eject pieces in some cases)
				piece.okay = true
			else
				piece.okay = false
			
			if piece.is_key
				piece.puz_x = piece.x - puzzle_x
				piece.puz_y = piece.y - puzzle_y

maybe_reveal_next_piece = (current_piece)->
	if current_piece?.okay
		if current_piece.is_key
			current_piece.locked = true
		reveal_next_piece()

canvas.addEventListener "pointerup", (e)->
	maybe_reveal_next_piece(pointers[e.pointerId].drag_piece)
	delete pointers[e.pointerId]

canvas.addEventListener "pointercancel", (e)->
	# NOTE: maybe ought to revert to original position of piece instead
	maybe_reveal_next_piece(pointers[e.pointerId].drag_piece)
	delete pointers[e.pointerId]

# grid = new Grid


pieces = []
# active_pieces = []
next_pieces = []
# TODO: define next pieces based on the current pieces
# so that the next pieces don't overlap with the occupied space

for x_i in [0...5]
	for y_i in [0...5]
		piece = new Piece
		piece.puz_x = x_i * 150
		piece.puz_y = y_i * 150
		# piece.x = -x_i * 150 + 10
		# piece.y = -y_i * 150 + 10
		piece.calcPath()
		# pieces.push piece
		next_pieces.push piece

next_pieces.sort((a, b)-> a.x + a.y % b.y > b.x - a.y)
# next_pieces.sort((a, b)-> (a.x + a.y) % b.y - (b.x % 3) - (a.y % 6) - (a.x % 3))

# for piece, i in pieces
# 	piece.x += i * 2
# 	piece.y += i * 1

shapes = []

# key_pieces = pieces.slice(pieces.length-3, pieces.length)
key_pieces = next_pieces.slice(0, 3)
for key in key_pieces
	key.is_key = true

do reveal_next_piece = ->
	next_piece = next_pieces.shift()
	if next_piece
		pieces.push(next_piece)

# class Shape
# 	constructor: ->
# 		
# 	getPoint: ->

getPoint = (point)->
	# x: point.x + point.piece.x - point.piece.puz_x
	# y: point.y + point.piece.y - point.piece.puz_y
	return unless point.piece in pieces
	x: point.x + point.piece.puz_x
	y: point.y + point.piece.puz_y

shapes.push({
	# center: key_pieces[0].points[0]
	a: key_pieces[1].points[0]
	b: key_pieces[2].points[0]
	draw: ->
		a = getPoint(@a)
		b = getPoint(@b)
		return unless a and b
		# puz_ctx.beginPath()
		# puz_ctx.arc(@center.x + @center.piece.x, @center.y + @center.piece.y, 50, 0, TAU)
		# puz_ctx.fillStyle = "lime"
		# puz_ctx.fill()
		puz_ctx.beginPath()
		puz_ctx.moveTo(a.x, a.y)
		puz_ctx.lineTo(b.x, b.y)
		puz_ctx.strokeStyle = "lime"
		puz_ctx.lineCap = "round"
		puz_ctx.lineWidth = 50
		puz_ctx.stroke()
})

shapes.push({
	center: key_pieces[0].points[0]
	# a: key_pieces[0].points[0]
	# b: key_pieces[1].points[0]
	draw: ->
		center = getPoint(@center)
		return unless center
		puz_ctx.save()
		tx = 200
		puz_ctx.fillStyle = "yellow"
		puz_ctx.translate(center.x, center.y)
		for i in [0..100]
			puz_ctx.rotate(tx / 56)
			puz_ctx.fillRect(cos(tx/6)*150*sin(i/60+tx), 50, 1, cos(tx/6+i) * 50)
		puz_ctx.restore()
		
})

t = 20
draw_puzzle = ->
	t += 0.01
	
	puz_ctx.fillStyle = "#1178ff"
	puz_ctx.fillRect 0, 0, puz_canvas.width, puz_canvas.height
	
	###
	sunset = puz_ctx.createLinearGradient 0, 0, 0, puz_canvas.height
	
	sunset.addColorStop 0.000, 'rgb(0, 255, 242)'
	sunset.addColorStop 0.442, 'rgb(107, 99, 255)'
	sunset.addColorStop 0.836, 'rgb(255, 38, 38)'
	sunset.addColorStop 0.934, 'rgb(255, 135, 22)'
	sunset.addColorStop 1.000, 'rgb(255, 252, 0)'
	
	puz_ctx.fillStyle = sunset
	puz_ctx.fillRect 0, 0, puz_canvas.width, puz_canvas.height
	
	puz_ctx.save()
	# t = 20
	puz_ctx.translate(puz_canvas.width / 2, puz_canvas.height / 2)
	for i in [0..100]
		puz_ctx.rotate(t / 56)
		puz_ctx.fillRect(cos(t/6)*150*sin(i/60+t), 50, 15, cos(t/6+i) * 50)
	puz_ctx.restore()
	
	puz_ctx.save()
	tx = 200
	puz_ctx.fillStyle = "yellow"
	#puz_ctx.translate(puz_canvas.width / 2, puz_canvas.height / 2)
	for i in [0..100]
		puz_ctx.rotate(tx / 56)
		puz_ctx.fillRect(cos(tx/6)*150*sin(i/60+tx), 50, 1, cos(tx/6+i) * 50)
	puz_ctx.restore()
	###
	
	for shape in shapes
		shape.draw()


animate ->
	ctx.clearRect(0, 0, canvas.width, canvas.height)
	ctx.beginPath()
	ctx.rect(puzzle_x, puzzle_y, puz_canvas.width, puz_canvas.height)
	ctx.fillStyle = "rgba(0, 0, 0, 0.1)"
	ctx.fill()
	draw_puzzle()
	for piece in pieces
		piece.draw()
	return
