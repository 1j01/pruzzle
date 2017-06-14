
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
		background: (puz_ctx)->
			# sunset = puz_ctx.createLinearGradient puzzle_x, puzzle_y, puzzle_x, puzzle_y + @height
			# sunset = puz_ctx.createLinearGradient puzzle_x, puzzle_y, puzzle_x, puzzle_y + @height
			sunset = puz_ctx.createLinearGradient 0, 0, 0, puz_ctx.canvas.height
			
			sunset.addColorStop 0.000, 'rgb(0, 255, 242)'
			sunset.addColorStop 0.442, 'rgb(107, 99, 255)'
			sunset.addColorStop 0.836, 'rgb(255, 38, 38)'
			sunset.addColorStop 0.934, 'rgb(255, 135, 22)'
			sunset.addColorStop 1.000, 'rgb(255, 252, 0)'
			
			puz_ctx.fillStyle = sunset
			# puz_ctx.fillRect 0, 0, @width, @height
			puz_ctx.fillRect 0, 0, puz_ctx.canvas.width, puz_ctx.canvas.height
			
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
]