local util = require("util")

local function unpack_table(t)
   assert(table_size(t) == 1, "Error: upack_table need a table with only one item.")
   return next(t)
end

local function seek_table(t, count)
   for i = 1, count do
      next(t)
   end
end

local constant_combinator_size

local function on_init()
   global.constant_combinator_size = game.entity_prototypes["constant-combinator"].item_slot_count
   assert(global.constant_combinator_size ~= nil)
end

local function on_load()
   constant_combinator_size = global.constant_combinator_size
end

local function create_constant_combinator(i, values, values_begin)
   local connection_template = {{entity_id = i - 1}}
   local connections = nil
   if i - 1 > 0 then
      connections = {{red = connection_template, green = connection_template}}
   end
   local entity = {
        entity_number = i,
        name = "constant-combinator",
        position = {0, i},
        direction = defines.direction.north,
        connections = connections,
	control_behavior = {filters={}},
   }
   local i = 1
   while true do
      item, count = next(values, values_begin)
      values_begin = item
      if item == nil then
	 return entity
      end
      entity.control_behavior.filters[i] =
	 {signal={type="item", name=item}, count=count, index=i}
      i = i + 1
      if i > constant_combinator_size then
	 return entity, values_begin
      end
   end
end

local function create_constant_combinators(values, output)
   assert(output.is_blueprint)
   local equipments = {}
   local count = 0
   local i = 1
   local next_index
   while true do
      equipments[i], next_index = create_constant_combinator(i, values, next_index)
      if next_index == nil then
	 break
      end
      i = i + 1
      if i >= 100 then
	 game.print("error: maybe infinty loop?")
	 return nil
      end
   end
   output.set_blueprint_entities(equipments)
   output.set_blueprint_tiles{}
end


local function convert_blueprint(blueprint)
   create_constant_combinators(blueprint.cost_to_build, blueprint)
end

local convert_blueprint_book
local function convert_blueprint_or_book(stack)
   if not stack.valid_for_read then
      return
   end
   
   if stack.is_blueprint_book then
      convert_blueprint_book(stack)
   elseif stack.is_blueprint_setup then
      convert_blueprint(stack)
   end
end

function convert_blueprint_book(book)
   local inv = book.get_inventory(defines.inventory.item_main)
   for i = 1, #inv do
      convert_blueprint_or_book(inv[i])
   end
end

local function blueprint_converter_selection(event)
   -- Change all the blueprints on the ground into
   -- constant combinators containing their items.
   -- Also convert blueprint books recursively.
   if event.item ~= "blueprint-converter" then
      return
   end
   
   local temp_inv = game.create_inventory(1)
   local surface = event.surface
   for _, item_on_ground in pairs(event.entities) do
      local pos = item_on_ground.position
      local force = item_on_ground.force
      item_on_ground.mine{inventory=temp_inv}
      local blueprint = temp_inv[1]
      if blueprint.is_blueprint_setup or blueprint.is_blueprint_book then
	 convert_blueprint_or_book(blueprint)
      end
      surface.spill_item_stack({pos.x + 0.34, pos.y + 0.34}, temp_inv[1])
      temp_inv.clear()
   end
   temp_inv.destroy()
end

local function blueprint_converter_alt_selection(event)
   if event.item ~= "blueprint-converter" then
      return
   end
   local player = game.get_player(event.player_index)
   local surface = event.surface
   local stack = player.cursor_stack
   if stack == nil then
      player.print({"messages.player-has-no-cursor"}, {217, 87, 99})
      return
   end
   stack.set_stack("blueprint")
   stack.create_blueprint{surface=surface, force=player.force, area=event.area}
   convert_blueprint(stack)
end

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(function() on_init(); on_load() end)

script.on_event(
   defines.events.on_player_alt_selected_area,
   blueprint_converter_alt_selection)

script.on_event(
   defines.events.on_player_selected_area,
   blueprint_converter_selection)
