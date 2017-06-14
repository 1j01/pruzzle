
puz_canvas = document.createElement("canvas")
puz_ctx = puz_canvas.getContext("2d")
@puzzle_x = 300
@puzzle_y = 70

pointers = {}

class Piece
	constructor: ->
		@x = 0
		@y = 0
		@puz_x = 0
		@puz_y = 0
		@puz_w = 150
		@puz_h = 150
		
		@sides = [
			{type: "edge"}
			{type: "edge"}
			{type: "edge"}
			{type: "edge"}
		]
		
		@calcPath()
		
		@points =
			for [0..4]
				x: random() * @puz_w
				y: random() * @puz_h
				piece: @
		
		@okay = false # placed in a valid position
		@is_key = false # "key pieces are sort of like the *key* to the puzzle"
		@locked_in = false # not allowed to move; applies to key pieces
	
	calcPath: ->
		@path = new Path2D
		# @path.rect(0, 0, @puz_w, @puz_h)
		@path.moveTo(0, 0)
		r = @puz_w/5
		if @sides[0].type isnt "edge"
			@path.arc(@puz_w/2, 0, r, -TAU/2, 0, @sides[0].type is "innie")
		@path.lineTo(@puz_w, 0)
		if @sides[1].type isnt "edge"
			@path.arc(@puz_w, @puz_h/2, r, -TAU/4, TAU/4, @sides[1].type is "innie")
		@path.lineTo(@puz_w, @puz_h)
		if @sides[2].type isnt "edge"
			@path.arc(@puz_w/2, @puz_h, r, 0, TAU/2, @sides[2].type is "innie")
		@path.lineTo(0, @puz_h)
		if @sides[3].type isnt "edge"
			@path.arc(0, @puz_h/2, r, TAU/4, -TAU/4, @sides[3].type is "innie")
		@path.lineTo(0, 0)
		@path.closePath()
	
	moved: ->
		if @is_key
			@puz_x = @x - puzzle_x
			@puz_y = @y - puzzle_y
	
	draw: ->
		ctx.save()
		# not sure about lowering the opacity like this
		# it could be confusing if you're trying to match colors
		# or just seeing the texture of things under it
		ctx.globalAlpha = 0.8 if @held
		
		ctx.translate(@x, @y)
		
		ctx.save()
		ctx.clip(@path)
		
		ctx.drawImage(puz_canvas, -puzzle_x-@puz_x, -puzzle_y-@puz_y)
		
		if @hovered and not @held
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
		@rows = []
	
	get: (x, y)->
		@rows[y]?[x]
	
	set: (x, y, val)->
		@rows[y] ?= []
		@rows[y][x] = val

to_canvas_position = (evt)->
	rect = canvas.getBoundingClientRect()  # absolute position and size of element
	scaleX = canvas.width / rect.width     # ratio of bitmap to element width
	scaleY = canvas.height / rect.height   # ratio of bitmap to element height
	
	x: (evt.clientX - rect.left) * scaleX  # scale mouse coordinates after they have
	y: (evt.clientY - rect.top) * scaleY   # been adjusted to be relative to element

canvas.setAttribute "touch-action", "none"

canvas.addEventListener "mousemove", (e)->
	{x, y} = to_canvas_position(e)
	for piece in pieces when not piece.locked_in
		if ctx.isPointInPath(piece.path, x - piece.x, y - piece.y)
			drag_piece = piece
	for piece in pieces
		piece.hovered = piece is drag_piece
	canvas.style.cursor = if drag_piece then "move" else "default"

canvas.addEventListener "pointerdown", (e)->
	# TODO: maybe undoable()
	{x, y} = to_canvas_position(e)
	for piece in pieces when not piece.locked_in
		if ctx.isPointInPath(piece.path, x - piece.x, y - piece.y)
			drag_piece = piece
	
	if drag_piece
		# bring piece to the top
		pieces.splice(pieces.indexOf(drag_piece), 1)
		pieces.push(drag_piece)
	
	drag_piece?.held = true
	
	pointers[e.pointerId] =
		x: x
		y: y
		drag_piece: drag_piece
		offset_x: drag_piece?.x - x
		offset_y: drag_piece?.y - y

canvas.addEventListener "pointermove", (e)->
	{x, y} = to_canvas_position(e)
	pointer = pointers[e.pointerId]
	if pointer
		pointer.x = x
		pointer.y = y
		piece = pointer.drag_piece
		if piece
			piece.x = x + pointer.offset_x
			piece.y = y + pointer.offset_y
			
			grid_x = Math.round((piece.x - puzzle_x) / 150)
			grid_y = Math.round((piece.y - puzzle_y) / 150)
			align_x = grid_x * 150 + puzzle_x
			align_y = grid_y * 150 + puzzle_y
			
			# TODO: check geometric plausibility before snapping
			# - piece's bounds within the puzzle bounds
			# - piece doesn't intersect placed pieces*
			# - edge sides against puzzle sides
			# - non-edge sides not against puzzle sides
			# (*although maybe it should let you eject pieces in some cases)
			d = 20
			if (
				abs(piece.x - align_x) < d and
				abs(piece.y - align_y) < d
			)
				piece.x = align_x
				piece.y = align_y
				piece.grid_x = grid_x
				piece.grid_y = grid_y
				piece.okay = true
			else
				piece.okay = false
			
			piece.moved()

drop_piece_and_maybe_reveal_next = (current_piece)->
	current_piece?.held = false
	if current_piece?.okay
		grid.set(current_piece.grid_x, current_piece.grid_y, current_piece)
		if current_piece.is_key
			current_piece.locked_in = true
			update_next_pieces()
		reveal_next_piece()

canvas.addEventListener "pointerup", (e)->
	drop_piece_and_maybe_reveal_next(pointers[e.pointerId]?.drag_piece)
	delete pointers[e.pointerId]

canvas.addEventListener "pointercancel", (e)->
	# NOTE: maybe ought to revert to original position of piece instead
	drop_piece_and_maybe_reveal_next(pointers[e.pointerId]?.drag_piece)
	delete pointers[e.pointerId]


grid = new Grid

pieces = [] # "in play"
next_pieces = [] # "out of play"
key_pieces = []

update_next_pieces = ->
	next_pieces = []
	for x_i in [0...5]
		for y_i in [0...5]
			unless grid.get(x_i, y_i)
				piece = new Piece
				piece.puz_x = x_i * 150
				piece.puz_y = y_i * 150
				piece.x = (puzzle_x - piece.puz_w) / 2
				# piece.y = (puzzle_y - piece.puz_h) / 2
				# piece.y = puzzle_y
				piece.y = puzzle_y + (puzzle.height - piece.puz_h) / 2
				piece.sides[0].type = if piece.puz_y > 0 then "innie" else "edge"
				piece.sides[1].type = if piece.puz_x + piece.puz_w < puzzle.width then "outie" else "edge"
				piece.sides[2].type = if piece.puz_y + piece.puz_h < puzzle.height then "outie" else "edge"
				piece.sides[3].type = if piece.puz_x > 0 then "innie" else "edge"
				piece.calcPath()
				piece.is_key = pieces.length < puzzle.n_keys
				next_pieces.push piece
	
	next_pieces.sort((a, b)-> a.x + a.y % b.y > b.x - a.y)
	# next_pieces.sort((a, b)-> (a.x + a.y) % b.y - (b.x % 3) - (a.y % 6) - (a.x % 3))

puzzle = null

start_puzzle = (_puzzle)->
	puzzle = _puzzle
	
	# reset grid, pieces, next_pieces, key_pieces
	# maybe canvases, etc.
	
	grid = new Grid
	
	pieces = [] # "in play"
	next_pieces = [] # "out of play"
	key_pieces = []
	
	update_next_pieces()
	reveal_next_piece()

reveal_next_piece = ->
	next_piece = next_pieces.shift()
	if next_piece
		pieces.push(next_piece)
		if next_piece.is_key
			key_pieces.push(next_piece)
		next_piece.moved()

do update_from_hash = ->
	lvl_n = parseInt(location.hash.replace("#", ""))
	if puzzles[lvl_n]
		start_puzzle(puzzles[lvl_n])
	else
		start_puzzle(puzzles[0])

addEventListener "hashchange", update_from_hash


draw_puzzle = ->
	if typeof puzzle.background is "function"
		puzzle.background(puz_ctx)
	else
		puz_ctx.fillStyle = puzzle.background
		puz_ctx.fillRect 0, 0, puz_canvas.width, puz_canvas.height
	
	puz_ctx.save()
	puz_ctx.translate(puzzle_x, puzzle_y)
	
	for shape in puzzle.shapes
		shape.draw(puz_ctx, key_pieces)
	
	puz_ctx.restore()


animate ->
	ctx.clearRect(0, 0, canvas.width, canvas.height)
	ctx.beginPath()
	ctx.rect(puzzle_x, puzzle_y, puzzle.width, puzzle.height)
	ctx.fillStyle = "rgba(0, 0, 0, 0.1)"
	ctx.fill()
	puz_canvas.width = max(canvas.width, puzzle_x + puzzle.width)
	puz_canvas.height = max(canvas.height, puzzle_x + puzzle.height)
	draw_puzzle()
	if location.hash.match(/peak/)
		ctx.drawImage(puz_canvas, 0, 0)
	for piece in pieces
		piece.draw()
	return
