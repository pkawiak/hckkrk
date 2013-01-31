require "./dungeon_entity"

class Dungeon
  def initialize
    @entities = []
    @entities_to_coordinates = {}
    @gold_piles = []
  end

  def steal_gold(x, y)
    gold_pile = entities_at(x, y).select { |entity| entity.char == 'G' }[0]
    remove_entity gold_pile
    @gold_piles.delete gold_pile
    add_entity Pavement.new(x, y)
  end

  def remove_entity (entity)
    @entities.delete entity
    entities_at(entity.x, entity.y).delete(entity)
    #@entities_to_coordinates.delete("#{entity.x}x#{entity.y}y")
  end

  def gold_piles_left
    @gold_piles.length
  end

  def entities_at(x, y)
    key = "#{x}x#{y}y"
    ents = @entities_to_coordinates[key]
    if ents == nil
      ents = []
      @entities_to_coordinates[key] = ents
    end
    ents
  end

  def add_entity (entity, track = true)
    if track
      ents = entities_at(entity.x, entity.y)
      ents.push entity
      if entity.char == 'G'
        @gold_piles << entity
      end
    end
    @entities.push entity
  end

  def entity_at(x, y)
    @entities_to_coordinates["#{x}x#{y}y"]
  end


  def entity_passable?(x, y)
    entities = entities_at x, y
    entities.length >= 0 && (entities.select { |ent| !ent.passable }.length == 0)
  end

  def passable_neighbours (x, y)
    nearby_passable_entities x, y
  end

  def nearby_passable_entities (x, y)
    ret = []
    if entity_passable?(x+1, y)
      ret.push({x: x+1, y: y})
    end

    if entity_passable?(x-1, y)
      ret.push ({x: x-1, y: y})
    end

    if entity_passable?(x, y+1)
      ret.push ({x: x, y: y+1})
    end

    if entity_passable?(x, y-1)
      ret.push ({x: x, y: y -1})
    end
    ret
  end

  def nearby_gold (x, y)
    entities = nearby_entities x, y
    entities.select { |entity| entity != nil && entity.char == 'G' }
  end

  def nearby_entities (x, y)
    entities = entities_at(x+1, y) + entities_at(x-1, y) + entities_at(x, y-1) + entities_at(x, y+1)
  end

  def add_all(entities, track = true)
    entities.each { |ent|
      add_entity ent, track
    }
  end

  def entities
    @entities
  end
end

class DungeonBuilder
  def initialize(width, height, min_passage_length = 4)
    @min_passage_length = min_passage_length
    @width = width
    @height = height
  end

  def build
    dungeon = create_solid_rock
    process_tile dungeon, [{x: 1, y: 1}]
    create_caverns dungeon
    ret = Dungeon.new
    ret.add_all to_entities dungeon
    ret
  end

  def to_entities(dungeon)
    entities = []
    (0..dungeon.length-1).each { |y|
      entity_row = dungeon[y]
      (0..entity_row.length-1).each { |x|
        tile = dungeon[y][x]
        case tile
          when '.' then
            entities << Pavement.new(x, y)
          when 'G' then
            entities << GoldPile.new(x, y)
          else
            entities << Wall.new(x, y)
        end
      }
    }
    entities
  end

  def create_caverns(dungeon)
    (10..25).each { |size|
      make_cavern_of_size dungeon, size
    }
    dungeon
  end

  def make_cavern_of_size(dungeon, size)
    x = Random.rand(@width - size -2) +1
    y = Random.rand(@height - size - 2) +1
    (1..size).each { |i|
      (1..size).each { |j|
        if i.between?(size/2 -1, size/2 +1) && j.between?(size/2 -1, size/2 +1)
          dungeon[y + i][x + j] = 'G'
        else
          dungeon[y + i][x + j] = '.'
        end
      }
    }
  end

  def process_tile (dungeon, stack)
    until stack.empty?
      tile = stack.pop
      mark_as_visited dungeon, tile
      unvisited_neighbours = collect_unvisited_neighbours dungeon, tile
      unvisited_neighbours = unvisited_neighbours.shuffle
      unvisited_neighbours.each { |neighbour|
        unless is_visited dungeon, neighbour
          make_passage dungeon, tile, neighbour
          stack.push neighbour
        end
      }
    end

    dungeon
  end

  def make_passage(dungeon, tile, neighbour)
    tile_x = tile[:x]
    tile_y = tile[:y]
    neighbour_x = neighbour[:x]
    neighbour_y = neighbour[:y]
    delta_x = (tile_x - neighbour_x)/@min_passage_length
    delta_y = (tile_y - neighbour_y)/@min_passage_length
    for i in 1..@min_passage_length
      new_x = tile_x - delta_x*i
      new_y = tile_y - delta_y*i
      mark_as_visited dungeon, {x: new_x, y: new_y}
    end
  end

  def mark_as_visited(dungeon, tile)
    dungeon[tile[:y]][tile[:x]] = '.'
  end

  def is_visited(dungeon, tile)
    dungeon[tile[:y]][tile[:x]] == '.'
  end

  def create_solid_rock
    dungeon = []
    @height.times {
      row = []
      @width.times {
        row << "#"
      }
      dungeon << row
    }
    dungeon
  end

  def collect_unvisited_neighbours(dungeon, tile)
    x = tile[:x]
    y = tile[:y]
    neighbours = []
    if y < @height - @min_passage_length
      neighbours << {x: x, y: y+@min_passage_length}
    end
    if y >= @min_passage_length
      neighbours << {x: x, y: y-@min_passage_length}
    end
    if x < @width -@min_passage_length
      neighbours << {x: x+@min_passage_length, y: y}
    end
    if x >= @min_passage_length
      neighbours << {x: x-@min_passage_length, y: y}
    end
    neighbours.select { |neighbour|
      !is_visited dungeon, neighbour
    }
  end
end