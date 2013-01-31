require "bundler/setup"
require "gaminator"
require "./dungeon"

class Adnd
  def initialize (width, height)
    @exit_message
    @width = width
    @height = height
    @randomizer = Random.new
    @dungeon = DungeonBuilder.new(width, height, 5).build
    @dragon = Dragon.new 1, 1
    @dwarfs = []
    add_dwarfs (width*height)/100
    @dungeon.add_entity @dragon
    @counter = 0
  end

  def add_dwarfs (count)
    count.times {
      add_dwarf_at_random_position
    }
  end

  def add_dwarf_at_random_position ()
    x = @randomizer.rand(0..@width - 2)
    y = @randomizer.rand(0..@height -2)
    while !@dungeon.entity_passable? x, y
      x = @randomizer.rand(0..@width)
      y = @randomizer.rand(0..@height)
    end
    dwarf_new = Dwarf.new x, y
    @dwarfs.push dwarf_new
    @dungeon.add_entity dwarf_new
  end

  def exit_message
    @exit_message
  end

  def tick
    if @counter == 0
      dwarfs_turn
    end
    @counter = (@counter + 1) % 10
    if @dungeon.gold_piles_left == 0
      @exit_message = "NOOB! Dwarfs got all yer gold!"
      quit
    end
    if @dwarfs.length == 0
      @exit_message = "PWNED all teh dwarves!"
      quit
    end
    @textbox_content = "Gold piles left: #{@dungeon.gold_piles_left}. Dwarfs left: #{@dwarfs.length}"
  end

  def dwarfs_turn
    @dwarfs.each { |dwarf|
      steal_gold dwarf
      move_dwarf dwarf
    }

  end

  def steal_gold (dwarf)
    nearby_gold = @dungeon.nearby_gold dwarf.x, dwarf.y
    nearby_gold.each { |gold|
      @dungeon.steal_gold(gold.x, gold.y)
    }
  end

  def move_dwarf (dwarf)
    neighbours = @dungeon.passable_neighbours dwarf.x, dwarf.y
    if neighbours.length > 0
      entity = neighbours.shuffle![0]
      @dungeon.remove_entity(dwarf)
      dwarf.move(entity[:x] - dwarf.x, entity[:y] - dwarf.y)
      @dungeon.add_entity(dwarf)
    end
  end

  def objects
    @dungeon.entities
  end

  def textbox_content
    @textbox_content
  end

  def wait?
    false
  end

  def input_map
    {
        ?a => :perform_action_west,
        ?w => :perform_action_north,
        ?s => :perform_action_south,
        ?d => :perform_action_east,
        ?q => :quit
    }
  end

  def sleep_time
    0.01
  end

  def move (dx, dy)
    target_x = @dragon.x + dx
    target_y = @dragon.y + dy
    dwarfs_to_eat =@dungeon.entities_at(target_x, target_y).select { |entity| entity.char == 'd' }
    dwarfs_to_eat.each { |eaten|
      @dungeon.remove_entity eaten
      @dwarfs.delete eaten
    }
    if @dungeon.entity_passable?(target_x, target_y)
      @dungeon.remove_entity(@dragon)
      @dragon.move dx, dy
      @dungeon.add_entity(@dragon)
    end
  end

  def perform_action_west
    move -1, 0
  end

  def perform_action_north
    move 0, -1
  end

  def perform_action_south
    move 0, 1
  end

  def perform_action_east
    move 1, 0
  end

  def quit
    Kernel.exit
  end
end

Gaminator::Runner.new(Adnd).run