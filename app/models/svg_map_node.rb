class SvgMapNode

  attr_reader :name, :nods_id, :os_x, :os_y

  def initialize(r)

    @name    = r[0]
    @nods_id = r[1]
    @os_x    = r[2]
    @os_y    = r[3]

  end

end
