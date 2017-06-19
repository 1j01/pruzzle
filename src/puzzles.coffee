
get_point = (point)->
	return unless point
	x: point.x + point.piece.puz_x
	y: point.y + point.piece.puz_y

@puzzles = [
	{
		name: "Test"
		background: "#1178ff"
		width: 150 * 5
		height: 150 * 5
		n_keys: 3
		shapes: [
			{
				draw: (puz_ctx, key_pieces)->
					# NOTE: this is an "invalid" shape
					# it shows up on the second key only once the third is revealed
					# and you can change it directly as you move the third key
					# it can even show up on the first key
					a = get_point(key_pieces[1]?.points[0])
					b = get_point(key_pieces[2]?.points[0])
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
			}
			{
				draw: (puz_ctx, key_pieces)->
					center = get_point(key_pieces[0]?.points[0])
					return unless center
					puz_ctx.save()
					tx = 200
					puz_ctx.fillStyle = "yellow"
					puz_ctx.translate(center.x, center.y)
					for i in [0..100]
						puz_ctx.rotate(tx / 56)
						puz_ctx.fillRect(cos(tx/6)*150*sin(i/60+tx), 50, 1, cos(tx/6+i) * 50)
					puz_ctx.restore()
			}
		]
	}
	{
		name: "Test 2"
		t: 0
		background: (puz_ctx, puz_canvas, puzzle_x, puzzle_y)->
			# sunset = puz_ctx.createLinearGradient puzzle_x, puzzle_y, puzzle_x, puzzle_y + @height
			# sunset = puz_ctx.createLinearGradient puzzle_x, puzzle_y, puzzle_x, puzzle_y + @height
			sunset = puz_ctx.createLinearGradient 0, 0, 0, puz_canvas.height
			
			sunset.addColorStop 0.000, 'rgb(0, 255, 242)'
			sunset.addColorStop 0.442, 'rgb(107, 99, 255)'
			sunset.addColorStop 0.836, 'rgb(255, 38, 38)'
			sunset.addColorStop 0.934, 'rgb(255, 135, 22)'
			sunset.addColorStop 1.000, 'rgb(255, 252, 0)'
			
			puz_ctx.fillStyle = sunset
			# puz_ctx.fillRect 0, 0, @width, @height
			puz_ctx.fillRect 0, 0, puz_canvas.width, puz_canvas.height
			
			puz_ctx.save()
			puz_ctx.translate(puzzle_x, puzzle_y)
			
			puz_ctx.save()
			t = @t += 0.01
			puz_ctx.translate(@width / 2, @height / 2)
			for i in [0..100]
				puz_ctx.rotate(t / 56)
				puz_ctx.fillRect(cos(t/6)*150*sin(i/60+t), 50, 15, cos(t/6+i) * 50)
			puz_ctx.restore()
			
			puz_ctx.save()
			tx = 200
			puz_ctx.fillStyle = "yellow"
			for i in [0..100]
				puz_ctx.rotate(tx / 56)
				puz_ctx.fillRect(cos(tx/6)*150*sin(i/60+tx), 50, 1, cos(tx/6+i) * 50)
			puz_ctx.restore()
			
			puz_ctx.restore()
		
		width: 150 * 5
		height: 150 * 5
		n_keys: 3
		shapes: [
			{
				draw: (puz_ctx, key_pieces)->
					# NOTE: this is an "invalid" shape
					# it shows up on the second key only once the third is revealed
					# and you can change it directly as you move the third key
					# it can even show up on the first key
					a = get_point(key_pieces[1]?.points[0])
					b = get_point(key_pieces[2]?.points[0])
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
			}
			{
				draw: (puz_ctx, key_pieces)->
					center = get_point(key_pieces[0]?.points[0])
					return unless center
					puz_ctx.save()
					tx = 200
					puz_ctx.fillStyle = "yellow"
					puz_ctx.translate(center.x, center.y)
					for i in [0..100]
						puz_ctx.rotate(tx / 56)
						puz_ctx.fillRect(cos(tx/6)*150*sin(i/60+tx), 50, 1, cos(tx/6+i) * 50)
					puz_ctx.restore()
					
			}
		]
	}
	{
		name: "Pac-Man"
		# name: "Onho its gOust h"
		# name: "Casper the Friendly Ghost Eater"
		
		# could do stuff with [implied] wrapping
		# even maze generation!
		t: 0
		background: "#000920"
		width: 150 * 5
		height: 150 * 5
		n_keys: 5
		# TODO: show a patch of maze grid on the key pieces
		# and apply it when placing the piece
		# the patch could be 1x1 if the grid sizes are equal and the pieces are made completely square
		# or 3x3 if there are tabs/slots, or more if the maze grid size is smaller
		# maybe just the key pieces could be made square... except that would look weird
		
		# maze: new Grid
		maze:
			rows: []
			get: (x, y)->
				@rows[y]?[x]
			set: (x, y, val)->
				@rows[y] ?= []
				@rows[y][x] = val
		
		update: ->
			
			# init grid
			for y_i in [0..5]
				for x_i in [0..5]
					
					cell =
						sides: [
							{dx: +1, dy: 0, name: "right", open: no}
							{dx: 0, dy: +1, name: "down", open: no}
							{dx: -1, dy: 0, name: "left", open: no}
							{dx: 0, dy: -1, name: "up", open: no}
						]
						x: x_i
						y: y_i
					
					cell.corners =
						for side, side_index in cell.sides
							[side, cell.sides[(side_index + 1) %% cell.sides.length]]
					
					@maze.set x_i, y_i, cell
			
			# "generate maze"
			for maze_row, y_i in @maze.rows
				for cell, x_i in maze_row
					cell.open = random() < 0.5
			
			for maze_row, y_i in @maze.rows
				for cell, x_i in maze_row
					for side in cell.sides
						side.walled = (@maze.get(x_i + side.dx, y_i + side.dy)?.open ? no) isnt cell.open
		
		draw: (puz_ctx, key_pieces)->
			
			# the "level" grid shouldn't *necessarily* have to be the same size as the jigsaw grid, but it would be more complicated
			grid_size = 150
			wall_size = 100
			inset = (grid_size - wall_size)
			
			for maze_row, y_i in @maze.rows
				for cell, x_i in maze_row
					puz_ctx.save()
					puz_ctx.translate(x_i * grid_size, y_i * grid_size)
					
					puz_ctx.beginPath()
					puz_ctx.strokeStyle = "blue"
					puz_ctx.lineWidth = 4
					puz_ctx.lineCap = "round"
					puz_ctx.lineJoin = "round"
					
					for side in cell.sides
						if side.walled
							perpendicular_sides =
								(other_side for other_side in cell.sides when (other_side.dx is 0) isnt (side.dx is 0))
							
							for around in [
								{d: +1, side: perpendicular_sides[0]}
								{d: -1, side: perpendicular_sides[1]}
							]
								puz_ctx.moveTo(
									(grid_size + wall_size * (side.dx)) / 2
									(grid_size + wall_size * (side.dy)) / 2
								)
								if around.side.walled
									puz_ctx.lineTo(
										(grid_size + wall_size * (side.dx or around.d / 2)) / 2
										(grid_size + wall_size * (side.dy or around.d / 2)) / 2
									)
									puz_ctx.arcTo(
										(grid_size + wall_size * (side.dx or around.d)) / 2
										(grid_size + wall_size * (side.dy or around.d)) / 2
										(grid_size + wall_size * (side.dx or around.d)) / 2 - side.dx * inset / 2
										(grid_size + wall_size * (side.dy or around.d)) / 2 - side.dy * inset / 2
										inset / 2
									)
								else
									if (@maze.get(x_i + side.dx + around.side.dx, y_i + side.dy + around.side.dy)?.open ? no) isnt cell.open
										puz_ctx.lineTo(
											(grid_size + ((wall_size * side.dx) or (grid_size * around.d))) / 2
											(grid_size + ((wall_size * side.dy) or (grid_size * around.d))) / 2
										)
									else
										puz_ctx.lineTo(
											(grid_size + wall_size * (side.dx or around.d)) / 2
											(grid_size + wall_size * (side.dy or around.d)) / 2
										)
					
					for [side_a, side_b] in cell.corners
						unless side_a.walled or side_b.walled
							if (@maze.get(x_i + side_a.dx + side_b.dx, y_i + side_a.dy + side_b.dy)?.open ? no) isnt cell.open
								
								puz_ctx.stroke()
								puz_ctx.beginPath()
								
								angle = Math.atan2(side_a.dy, side_a.dx)
								puz_ctx.arc(
									(grid_size / 2 + wall_size * (side_a.dx + side_b.dx))
									(grid_size / 2 + wall_size * (side_a.dy + side_b.dy))
									inset
									angle - TAU/2, angle - TAU/4
								)
					
					puz_ctx.stroke()
					if cell.open
						puz_ctx.beginPath()
						puz_ctx.arc(grid_size / 2, grid_size / 2, grid_size / 15, 0, TAU)
						puz_ctx.fillStyle = "white" # or yellow
						puz_ctx.fill()

					puz_ctx.restore()
			
			draw_plucky_puck = (x, y)->
				puz_ctx.save()
				puz_ctx.translate(x, y)
				puz_ctx.beginPath()
				puz_ctx.arc(0, 0, 30, TAU/8, -TAU/8)
				puz_ctx.lineTo(0, 0)
				puz_ctx.fillStyle = "yellow"
				puz_ctx.fill()
				puz_ctx.restore()
			
			draw_ghost = (x, y, color, face_x=1)->
				puz_ctx.save()
				puz_ctx.translate(x, y + 20)
				puz_ctx.beginPath()
				puz_ctx.arc(0, -20, 30, 0, TAU/2, true)
				for i in [0..6]
					puz_ctx.lineTo((i/6 - 1/2) * 2 * 30, 10 - 10 * (i % 2))
				puz_ctx.fillStyle = color
				puz_ctx.fill()
				
				eye = (x, look_x)->
					puz_ctx.beginPath()
					puz_ctx.arc(x, -30, 8, 0, TAU, true)
					puz_ctx.fillStyle = "white"
					puz_ctx.fill()
					puz_ctx.beginPath()
					puz_ctx.arc(x + look_x, -30, 4, 0, TAU, true)
					puz_ctx.fillStyle = "blue"
					puz_ctx.fill()
				
				eye(-10 * face_x, 5 * face_x)
				eye(15 * face_x, 5 * face_x)
				
				puz_ctx.restore()
			
			piece = key_pieces[1]
			if piece
				x = piece.puz_x + piece.puz_w/2
				y = piece.puz_y + piece.puz_h/2
				draw_ghost(x, y, "#f8981b", 1) # Clyde
			
			piece = key_pieces[2]
			if piece
				x = piece.puz_x + piece.puz_w/2
				y = piece.puz_y + piece.puz_h/2
				draw_ghost(x, y, "#64cbe3", 1) # Inky
			
			piece = key_pieces[3]
			if piece
				x = piece.puz_x + piece.puz_w/2
				y = piece.puz_y + piece.puz_h/2
				draw_ghost(x, y, "#ed1d24", 1) # Blinky
			
			piece = key_pieces[4]
			if piece
				x = piece.puz_x + piece.puz_w/2
				y = piece.puz_y + piece.puz_h/2
				draw_ghost(x, y, "#edadce", 1) # Pinky
			
			piece = key_pieces[0]
			if piece
				x = piece.puz_x + piece.puz_w/2
				y = piece.puz_y + piece.puz_h/2
				draw_plucky_puck(x, y)
	}
	{
		name: "Bo-Ring" # as in a boring ring
		t: 0
		background: "#153958"
		width: 150 * 5
		height: 150 * 5
		n_keys: 3
		shapes: [
			{
				t: 0
				draw: (puz_ctx, key_pieces)->
					# center = get_point(key_pieces[0]?.points[0])
					# return unless center
					piece = key_pieces[0]
					return unless piece
					x = piece.puz_x + piece.puz_w/2
					y = piece.puz_y + piece.puz_h/2
					puz_ctx.save()
					@t += 0.1
					puz_ctx.fillStyle = "white"
					puz_ctx.translate(x, y)
					# for i in [0..100]
					# 	# puz_ctx.rotate(@t / 56)
					# 	# puz_ctx.fillRect(cos(@t/6)*150*sin(i/60+@t), 50, 15, cos(@t/6+i) * 50)
					# 	# puz_ctx.rotate(@t / 50)
					# 	puz_ctx.rotate(@t / 60)
					# 	puz_ctx.fillRect(cos((@t/60)*TAU)*150*sin((i/100+@t/60)*TAU), 50, 15, cos((@t/60+i/100)*TAU) * 50)
					puz_ctx.arc(0, -300, 300, 0, TAU)
					puz_ctx.arc(0, -300, 200, 0, TAU, true)
					puz_ctx.fill()
					puz_ctx.restore()
					
			}
		]
	}
]
