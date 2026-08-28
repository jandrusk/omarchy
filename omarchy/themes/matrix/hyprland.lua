local active_border_color = { colors = { "rgba(00ff41ee)", "rgba(00b32dee)" }, angle = 45 }
local active_shadow_color = "rgb(00ff41)"
local inactive_border_color = "rgba(1f5c28aa)"
local inactive_shadow_color = "rgba(1f5c2877)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    shadow = {
      enabled = true,
      range = 8,
      render_power = 4,
      color = active_shadow_color,
      color_inactive = inactive_shadow_color,
    },
  },
})
