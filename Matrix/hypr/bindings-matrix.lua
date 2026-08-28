-- begin omarchy-matrix brave binding
-- SUPER+SHIFT+B is Browser in stock Omarchy. Unbind before replacing.
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + B", "Brave", os.getenv("HOME") .. "/.local/bin/omarchy-brave-matrix")
-- end omarchy-matrix brave binding
