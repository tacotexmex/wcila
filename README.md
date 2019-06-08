# pointlib

pointlib is Minetest mod that returns and displays node names and itemstrings when looking at
them. It is a simplification of Aurailus' WCILA mod.

## Functions
`pointlib.update` returns a table containing:
* `itemstring` the itemstring of the pointed node
* `pos` the position of the pointed node

## Node defintion extension
By adding a function to `on_point` in a node definition, this function will execute every time the node is pointed at where `pos` is player position, `pointer` pointing player object and `node_pos` is the position of the pointed node:
`on_point = function(pos, pointer, node_pos)``
