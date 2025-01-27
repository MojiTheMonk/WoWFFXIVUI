# ConsolePortNode

This library, part of ConsolePort, provides functionality for interface node calculations and management in World of Warcraft addons. It scans a given interface hierarchy, calculates distances, and determines the travel path between nodes. A node is any object in the hierarchy that is considered interactive, either by clicking or mousing over it.

This library can be used to create virtual cursors for accessibility reasons, where the current method uses four discrete directions for movement, but is able to make decisions on the best candidate node to move in a dynamic UI layout without perfect grids that match those four directions. A virtual cursor based on this library works sufficiently well for almost any UI hierarchy - when reasonably sane in structure.

## API

The library provides the following API:

- `NODE(frame1, frame2, ..., frameN)`: This function caches all nodes in the hierarchy for later use. The frames are the nodes to be cached.

- `NODE.ClearCache()`: This function clears the node cache.

- `NODE.IsDrawn(node, super)`: This function checks if a node is drawn. The `node` is the node to check, and `super` is the most relevant parent node.

- `NODE.IsRelevant(node)`: This function checks if a node is relevant.

- `NODE.GetScrollButtons(node)`: This function gets the scroll buttons of a node.

- `NODE.NavigateToBestCandidate(cur, key)`: This function navigates to the best candidate node. `cur` is the current node, and `key` is the direction to navigate in.

- `NODE.NavigateToClosestCandidate(cur, key)`: This function navigates to the closest candidate node. `cur` is the current node, and `key` is the general direction to navigate in.

- `NODE.NavigateToArbitraryCandidate([cur, old, origX, origY])`: This function navigates to an arbitrary candidate node. `cur` is the current node, `old` is the previous node, and `origX` and `origY` are the original coordinates.

## Node Attributes

Nodes can have the following attributes:

- `nodeignore`: If true, this node will be ignored.
- `nodepriority`: This number determines the priority of the node in arbitrary selection.
- `nodesingleton`: If true, no recursive scan will be performed on this node.
- `nodepass`: If true, the node's children will be included, but the node itself will be skipped.

## Installation

To use this library, include the `ConsolePortNode.lua` file in your project and acquire it using LibStub:

```lua
local LibStub = _G.LibStub
local NODE = LibStub:NewLibrary('ConsolePortNode', 1)
```

## License

This library is licensed under the GPL version 2 (General Public License).