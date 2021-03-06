
ctx = canvas.getContext("2d")

puz_canvas = document.createElement("canvas")
puz_ctx = puz_canvas.getContext("2d")
puzzle_x = default_large_margin = 300
puzzle_y = default_margin = 70

scale = 1

puzzle = null
piece_pot = {x: 0, y: 0, next_piece: null}
description_position = {x: 0, y: 0}

update_layout = ->
	dipRect = canvas.getBoundingClientRect()
	
	canvas.width =
		Math.round(devicePixelRatio * dipRect.right) -
		Math.round(devicePixelRatio * dipRect.left)
	canvas.height =
		Math.round(devicePixelRatio * dipRect.bottom) -
		Math.round(devicePixelRatio * dipRect.top)
	
	decide = (default_large_margin, default_margin)->
		if canvas.width > canvas.height
			puzzle_x = default_large_margin
			puzzle_y = default_margin
			margin = default_margin
			scale = min(
				canvas.width / (puzzle.width + puzzle_x + margin)
				canvas.height / (puzzle.height + puzzle_y + margin)
			)
			puzzle_x = canvas.width / scale / 2 - puzzle.width / 2
			puzzle_y = canvas.height / scale / 2 - puzzle.height / 2
			if puzzle_x < default_large_margin
				puzzle_x = default_large_margin
			piece_pot.x = -150 * 3/2
			piece_pot.y = (puzzle.height - 150) / 2
			description_position.x = piece_pot.x
			description_position.y = piece_pot.y + 150*2
			# description_position.y = piece_pot.y + 150*3/2
		else
			puzzle_x = default_margin
			puzzle_y = default_margin
			margin = default_margin
			scale = min(
				canvas.width / (puzzle.width + puzzle_x + margin)
				canvas.height / (puzzle.height + puzzle_y + default_large_margin)
			)
			puzzle_x = canvas.width / scale / 2 - puzzle.width / 2
			puzzle_y = canvas.height / scale / 2 - puzzle.height / 2
			if puzzle_y + puzzle.height + default_large_margin > canvas.height / scale
				puzzle_y = canvas.height / scale - default_large_margin - puzzle.height
			piece_pot.x = (puzzle.width - 150) / 2
			piece_pot.y = puzzle.height + 150 / 2
			description_position.x = piece_pot.x + 150*3/2
			description_position.y = piece_pot.y + 150/2
		
		if scale < 1 and default_margin > 0
			decide(default_large_margin, 0)
	
	decide(default_large_margin, default_margin)
	
	# TODO: apply scale to the puzzle canvas as well
	# to avoid pixelation when scaled up
	puz_canvas.width = max(canvas.width / scale, puzzle_x + puzzle.width)
	puz_canvas.height = max(canvas.height / scale, puzzle_y + puzzle.height)

class Grid
	constructor: ->
		@rows = []
	
	get: (x, y)->
		@rows[y]?[x]
	
	set: (x, y, val)->
		@rows[y] ?= []
		@rows[y][x] = val

can_place_piece = (piece, grid_x, grid_y)->
	can_place = true
	if grid.get(grid_x, grid_y)
		can_place = false
	else
		can_place = true
		for side, side_index in piece.sides
			adjacent_piece = grid.get(grid_x + side.dx, grid_y + side.dy)
			if adjacent_piece?
				adjacent_side = adjacent_piece.sides[(side_index + 2) % 4]
				if (
					(adjacent_side.type is "outie" and side.type is "outie") or
					(adjacent_side.type is "innie" and side.type is "innie") or
					(adjacent_side.type is "edge" and side.type in ["innie", "outie"])
				)
					can_place = false
			outside_or_against_puzzle_boundary = switch side_index
				when 0 then grid_y <= 0
				when 1 then grid_x + 1 >= puzzle.n_pieces_x
				when 2 then grid_y + 1 >= puzzle.n_pieces_y
				when 3 then grid_x <= 0
			against_puzzle_boundary = switch side_index
				when 0 then grid_y is 0
				when 1 then grid_x + 1 is puzzle.n_pieces_x
				when 2 then grid_y + 1 is puzzle.n_pieces_y
				when 3 then grid_x is 0
			if side.type is "edge"
				can_place = false unless against_puzzle_boundary
			else
				can_place = false if outside_or_against_puzzle_boundary
	can_place
	

try_to_place_piece = (piece)->
	return unless piece
	piece.held = false
	if piece.snapped_to_pot
		if piece_pot.next_piece
			pieces.splice(pieces.indexOf(piece_pot.next_piece), 1)
			next_pieces.unshift(piece_pot.next_piece)
		piece_pot.next_piece = piece
	else if piece.snapped_to_grid
		if can_place_piece(piece, piece.grid_x, piece.grid_y)
			grid.set(piece.grid_x, piece.grid_y, piece)
			if piece.is_key
				piece.locked_in = true
				update_next_pieces()
			unless piece_pot.next_piece
				reveal_next_piece()
		else
			piece.x += 15
			piece.y += 15
			piece.moved()
			# TODO: pop out towards the center (unless in the center)?
			# or a random direction except where it needs to avoid going offscreen?
			
			# TODO: show why a piece doesn't fit with an animation
			# such as a red X over a mismatched edge
			# or if it needs to be against an edge of the puzzle, a red line or arrow

to_canvas_position = (event)->
	rect = canvas.getBoundingClientRect()    # absolute position and size of element
	scaleX = canvas.width / rect.width       # ratio of bitmap to element width
	scaleY = canvas.height / rect.height     # ratio of bitmap to element height
	
	x: (event.clientX - rect.left) * scaleX  # scale mouse coordinates after they have
	y: (event.clientY - rect.top) * scaleY   # been adjusted to be relative to element

to_game_position = (event)->
	{x, y} = to_canvas_position(event)
	x: x / scale
	y: y / scale

piece_at = (x, y)->
	for piece in pieces when not piece.locked_in
		if ctx.isPointInPath(piece.path, x - piece.x - puzzle_x, y - piece.y - puzzle_y)
			return piece

pointers = {}

canvas.setAttribute "touch-action", "none"

# TODO: remove highlight for touch
# (mousemove has completely different semantics via touch)
canvas.addEventListener "mousemove", (e)->
	{x, y} = to_game_position(e)
	drag_piece = piece_at(x, y)
	for piece in pieces
		piece.hovered = piece is drag_piece
	if drag_piece
		canvas.classList.add("can-move-piece")
	else
		canvas.classList.remove("can-move-piece")

canvas.addEventListener "pointerdown", (e)->
	
	# TODO: make undoable/cancelable
	
	{x, y} = to_game_position(e)
	drag_piece = piece_at(x, y)
	
	if drag_piece
		drag_piece.held = true
		
		# bring piece to the top
		pieces.splice(pieces.indexOf(drag_piece), 1)
		pieces.push(drag_piece)
		
		# remove from pot / grid
		if drag_piece is piece_pot.next_piece
			piece_pot.next_piece = null
		grid.set(drag_piece.grid_x, drag_piece.grid_y, null)
	
	pointers[e.pointerId] =
		x: x
		y: y
		drag_piece: drag_piece
		offset_x: drag_piece?.x - x
		offset_y: drag_piece?.y - y

canvas.addEventListener "pointermove", (e)->
	{x, y} = to_game_position(e)
	pointer = pointers[e.pointerId]
	if pointer
		pointer.x = x
		pointer.y = y
		piece = pointer.drag_piece
		if piece
			piece.x = x + pointer.offset_x
			piece.y = y + pointer.offset_y
			
			grid_x = Math.round(piece.x / 150)
			grid_y = Math.round(piece.y / 150)
			align_x = grid_x * 150
			align_y = grid_y * 150
			
			within_grid =
				(grid_x >= 0) and
				(grid_y >= 0) and
				(grid_x + 1 <= puzzle.n_pieces_x) and
				(grid_y + 1 <= puzzle.n_pieces_y)
			
			# TODO: maybe eject other pieces in some cases
			
			snap_dist = 20 / scale
			if (
				abs(piece.x - align_x) < snap_dist and
				abs(piece.y - align_y) < snap_dist and
				within_grid
			)
				piece.x = align_x
				piece.y = align_y
				piece.grid_x = grid_x
				piece.grid_y = grid_y
				piece.snapped_to_grid = true
				piece.invalid_placement = not can_place_piece(piece, grid_x, grid_y)
			else
				piece.snapped_to_grid = false
				piece.invalid_placement = false
			
			if (
				abs(piece.x - piece_pot.x) < snap_dist and
				abs(piece.y - piece_pot.y) < snap_dist
			)
				piece.x = piece_pot.x
				piece.y = piece_pot.y
				piece.snapped_to_pot = true
			else
				piece.snapped_to_pot = false
			
			piece.moved()

canvas.addEventListener "pointerup", (e)->
	try_to_place_piece(pointers[e.pointerId]?.drag_piece)
	delete pointers[e.pointerId]

canvas.addEventListener "pointercancel", (e)->
	# TODO: revert to original position of piece instead
	try_to_place_piece(pointers[e.pointerId]?.drag_piece)
	delete pointers[e.pointerId]

document.body.style.userSelect = "none"
document.body.addEventListener "selectstart", (e)->
	e.preventDefault()


grid = new Grid

pieces = [] # "in play"
next_pieces = [] # "out of play"
key_pieces = []

update_next_pieces = ->
	next_pieces = []
	temp_grid = new Grid
	for x_i in [0...puzzle.n_pieces_x]
		for y_i in [0...puzzle.n_pieces_y]
			unless grid.get(x_i, y_i)
				piece = new Piece
				piece.puz_x = x_i * 150
				piece.puz_y = y_i * 150
				piece.x = piece_pot.x
				piece.y = piece_pot.y
				
				connect = (side_index)->
					side = piece.sides[side_index]
					adjacent_piece =
						grid.get(x_i + side.dx, y_i + side.dy) or
						temp_grid.get(x_i + side.dx, y_i + side.dy)
					if adjacent_piece
						adjacent_side = adjacent_piece.sides[(side_index + 2) % 4]
						switch adjacent_side.type
							when "innie" then "outie"
							when "outie" then "innie"
							when "edge" then "edge"
							else
								throw new Error "Unknown side type #{adjacent_side.type}"
					else if random() < 0.5
						"innie"
					else
						"outie"
				
				piece.sides[0].type = if piece.puz_y > 0 then connect(0) else "edge"
				piece.sides[1].type = if piece.puz_x + piece.puz_w < puzzle.width then connect(1) else "edge"
				piece.sides[2].type = if piece.puz_y + piece.puz_h < puzzle.height then connect(2) else "edge"
				piece.sides[3].type = if piece.puz_x > 0 then connect(3) else "edge"
				piece.calcPath()
				piece.is_key = pieces.length < puzzle.n_keys
				next_pieces.push piece
				temp_grid.set(x_i, y_i, piece)
	
	# TODO: sort randomly
	next_pieces.sort((a, b)-> a.x + a.y % b.y > b.x - a.y)
	
	puzzle.update?()

@start_puzzle = ->
	grid = new Grid
	
	pieces = [] # "in play"
	next_pieces = [] # "out of play"
	key_pieces = []
	
	update_layout()
	
	update_next_pieces()
	reveal_next_piece()

reveal_next_piece = ->
	next_piece = next_pieces.shift()
	if next_piece
		piece_pot.next_piece = next_piece
		pieces.push(next_piece)
		if next_piece.is_key
			key_pieces.push(next_piece)
		next_piece.moved()

do update_from_hash = ->
	lvl_n = parseInt(location.hash.replace("#", ""))
	go_to_puzzle = puzzles[lvl_n] ? puzzles[0]
	if go_to_puzzle isnt puzzle
		puzzle = go_to_puzzle
		start_puzzle()

addEventListener "hashchange", update_from_hash


render_puzzle_image = ->
	if typeof puzzle.background is "function"
		puzzle.background(puz_ctx, puz_canvas, puzzle_x, puzzle_y)
	else
		puz_ctx.fillStyle = puzzle.background
		puz_ctx.fillRect(0, 0, puz_canvas.width, puz_canvas.height)
	
	puz_ctx.save()
	puz_ctx.translate(puzzle_x, puzzle_y)
	
	puzzle.draw?(puz_ctx, key_pieces)
	if puzzle.shapes?
		for shape in puzzle.shapes
			shape.draw?(puz_ctx, key_pieces)
	
	puz_ctx.restore()


animate ->
	update_layout()
	
	if piece_pot.next_piece
		piece_pot.next_piece.x = piece_pot.x
		piece_pot.next_piece.y = piece_pot.y
		piece_pot.next_piece.moved()
	
	render_puzzle_image()
	
	ctx.clearRect(0, 0, canvas.width, canvas.height)
	ctx.save()
	ctx.scale(scale, scale)
	
	peak = location.hash.match(/peak/)
	if peak
		ctx.drawImage(puz_canvas, 0, 0)
	
	ctx.save()
	ctx.translate(puzzle_x, puzzle_y)
	
	# show the puzzle area
	ctx.beginPath()
	ctx.rect(0, 0, puzzle.width, puzzle.height)
	ctx.fillStyle = "rgba(0, 0, 0, #{if peak then 0.5 else 0.1})"
	ctx.fill()
	
	# draw grid lines
	ctx.beginPath()
	for x_i in [1...puzzle.n_pieces_x]
		ctx.moveTo(x_i * 150, 0)
		ctx.lineTo(x_i * 150, puzzle.height)
	for y_i in [1...puzzle.n_pieces_y]
		ctx.moveTo(0, y_i * 150)
		ctx.lineTo(puzzle.width, y_i * 150)
	ctx.lineWidth = 1
	ctx.strokeStyle = "rgba(0, 0, 0, 0.2)"
	ctx.stroke()
	
	# show the piece pot
	ctx.strokeStyle = "rgba(0, 0, 0, 0.2)"
	ctx.lineWidth = 2
	unless piece_pot.next_piece
		ctx.save()
		ctx.translate(piece_pot.x, piece_pot.y)
		ctx.beginPath()
		ctx.rect(0, 0, 150, 150)
		ctx.setLineDash([150/4, 150/2, 150/4, 0])
		ctx.stroke()
		ctx.restore()
	
	ctx.save()
	ctx.translate(description_position.x, description_position.y)
	ctx.fillStyle = "gray"
	ctx.textAlign = "center"
	ctx.textBaseline = "middle"
	font_size = 30
	ctx.font = "#{font_size}px Arial"
	key_symbol = "🔑\uFE0E" # or \uD83D\uDDDD\uFE0E or ⚿ or ⚷
	ctx.fillText("#{puzzle.n_keys} #{key_symbol}", 150/2, -font_size)
	ctx.fillText("#{pieces.length + next_pieces.length} pc", 150/2, font_size)
	# ctx.fillText("#{puzzle.n_keys} #{key_symbol} / #{pieces.length + next_pieces.length} pc", 150/2, 0)
	ctx.restore()
	
	# draw pieces
	for piece in pieces
		piece.draw(ctx, puz_canvas, puzzle_x, puzzle_y)
	
	ctx.restore()
	
	ctx.restore()
	return
