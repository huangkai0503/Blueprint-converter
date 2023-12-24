local function copy(prototype, changes)
   local res = table.deepcopy(prototype)
   for k, v in pairs(changes) do
      res[k] = v
   end
   return res
end

local blueprint_converter_icon_path  =
   "__BlueprintConverter__/graphics/blueprint-converter.png"
data:extend{
   {
      type = "selection-tool",
      name = "blueprint-converter",
      icon = blueprint_converter_icon_path,
      icon_size = 32,
      flags = {"hidden", "not-stackable", "spawnable", "only-in-cursor"},
      stack_size = 1,
      subgroup = "tool",
      order = "c[automated-construction]-b[blueprint-converter]",
      --draw_label_for_cursor_render = true,
      selection_color = {57, 156, 251},
      alt_selection_color = {0.3, 0.8, 1},
      --selection_count_button_color = {43, 113, 180},
      --alt_selection_count_button_color = {0.3, 0.8, 1},
      selection_cursor_box_type = "not-allowed",
      alt_selection_cursor_box_type = "copy",
      selection_mode = {"items"},
      alt_selection_mode = {"buildable-type"},
   },
   {
      type = "shortcut",
      name = "blueprint-converter",
      localised_name = {"shortcut.blueprint-converter"},
      icon = {
	 filename = blueprint_converter_icon_path,
	 size = 32,
	 flags = {"gui-icon"}
      },
      action = "spawn-item",
      item_to_spawn = "blueprint-converter",
      technology_to_unlock = "construction-robotics",
      order = "b[blueprints]-i[blueprint-converter]",
      associated_control_input = "blueprint_converter",
   },
   {
      type = "custom-input",
      name = "blueprint-converter",
      key_sequence = "ALT + T",
      action = "spawn-item",
      item_to_spawn = "blueprint-converter",
   },
}
