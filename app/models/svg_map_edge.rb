class SvgMapEdge

  attr_reader :key, :line
  attr_reader :nax, :nay, :nbx, :nby

  def initialize(r)

    @edge_id = r[0]
    @nida    = r[1]
    @nidb    = r[2]
    @line    = r[7]

    @nax     = r[3]
    @nay     = r[4]
    @nbx     = r[5]
    @nby     = r[6]

    ax = 0
    ay = 0
    bx = 0 
    by = 0

    if (@nbx > @nax)
      ax = @nax
      ay = @nay
      bx = @nbx
      by = @nby
      
    elsif (@nbx == @nax)
      
      if (@nby > @nay)
        ax = @nax
        ay = @nay
        bx = @nbx
        by = @nby
        
      else
        ax = @nbx
        ay = @nby
        bx = @nax
        by = @nay

      end

    else
      ax = @nbx
      ay = @nby
      bx = @nax
      by = @nay
      
    end

    @nax = ax
    @nay = ay
    @nbx = bx
    @nby = by

    @key = sprintf("%d%d%d%d", ax, ay, bx, by)

  end

end
