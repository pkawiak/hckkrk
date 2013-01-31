class DungeonEntity

  def initialize (display_char, x = 0, y = 0)
    @display_char = display_char
    @x = x
    @y = y
  end

  def passable
    false
  end

  def char
    @display_char
  end

  def x
    @x
  end

  def y
    @y
  end
end

class Wall < DungeonEntity

  def initialize (x = 0, y = 0)
    super '#', x, y
  end

end

class Pavement < DungeonEntity
  def initialize (x = 0, y = 0)
    super '.', x, y
  end

  def passable
    true
  end
end

class GoldPile < DungeonEntity
  def initialize (x = 0, y = 0)
    super 'G', x, y
  end

  def color
    Curses::COLOR_YELLOW
  end

  def passable
    false
  end
end

class Dragon < DungeonEntity
  def initialize (x = 0, y = 0)
    super 'D', x, y
  end

  def move (dx, dy)
    @x += dx
    @y += dy
  end

  def color
    Curses::COLOR_RED
  end

  def passable
    false
  end
end

class Dwarf < DungeonEntity
  def initialize (x = 0, y = 0)
    super 'd', x, y
  end

  def move (dx, dy)
    if dy == 1 || dx == 1 || dy == -1 || dx == -1
      @x += dx
      @y += dy
    end
  end

  def color
    Curses::COLOR_GREEN
  end

  def passable
    false
  end

end