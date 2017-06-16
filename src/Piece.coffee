
class @Piece
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
	
	draw: (ctx, puz_canvas)->
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
		
		ctx.strokeStyle = "rgba(255, 255, 255, 0.4)"
		ctx.lineWidth = 2
		ctx.save()
		ctx.translate(1, 2)
		ctx.stroke(@path)
		ctx.strokeStyle = "rgba(255, 255, 255, 0.1)"
		ctx.translate(0, 1)
		ctx.stroke(@path)
		ctx.restore()
		
		ctx.strokeStyle = "black"
		ctx.lineWidth = 2
		ctx.stroke(@path)
		
		ctx.restore()
		ctx.restore()
