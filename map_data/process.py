# Built-in modules:
import json, math, sys

# Third-party modules:
import osmium

class dataHandler (osmium.SimpleHandler):
    def __init__ (
            self,
            map_con = {},
            stats = {}):
        super (dataHandler, self).__init__ ()
        self.map_con = map_con

        self.center = (51.5074456, -0.1277653) # geographical center of London
        self.scale_x = 1113195 # decimeters per degree longitude
        self.scale_y = 1113195 # * math.cos (math.radians (self.center [0]))
    
    def node (self, n):
        self.map_con [n.id] = [
            round ((n.location.lon - self.center [1]) * self.scale_x), # Unit: 1 decimeter
            0 - round ((n.location.lat - self.center [0]) * self.scale_y), # Godot's y-axis is inverted
            {}
        ]

    def way (self, w):
        tags = dict (w.tags)
        if w.tags.get ("oneway") != "-1":
            for i, j in zip (tuple (w.nodes), tuple (w.nodes) [1 : ]):
                self.map_con [i.ref] [2] [j.ref] = tags.get ("name", "Unnamed Road")
                # self.map_con [i.ref] ["n"].append (j.ref)
        if w.tags.get ("oneway") != "yes":
            for i, j in zip (tuple (w.nodes) [1 : ], tuple (w.nodes)):
                self.map_con [i.ref] [2] [j.ref] = tags.get ("name", "Unnamed Road")
                # self.map_con [i.ref] ["n"].append (j.ref)

class mapHandler (osmium.SimpleHandler):
    def __init__ (
            self,
            map_con = {},
            stats = {}):
        super (mapHandler, self).__init__ ()
        self.map_con = map_con
        self.node_coords = {}

        self.center = (51.5074456, -0.1277653) # geographical center of London
        self.scale_x = 1113195 # decimeters per degree longitude
        self.scale_y = 1113195 # * math.cos (math.radians (self.center [0]))

    def node (self, n):
        self.node_coords [n.id] = (
            round ((n.location.lon - self.center [1]) * self.scale_x), # Unit: 1 decimeter
            0 - round ((n.location.lat - self.center [0]) * self.scale_y) # Godot's y-axis is inverted
        )

    def way (self, w):
        way_list = [w.tags.get ("name", "Unnamed Road")]
        for i in w.nodes:
            way_list.extend (self.node_coords [i.ref])
        self.map_con [w.id] = way_list

if len (sys.argv) < 2 or sys.argv [1] != "map":
    handler = dataHandler ()
    handler.apply_file ("greater-london-latest.osm.filtered.o5m")
    with open ("data.json", "w") as f:
        json.dump (handler.map_con, f, separators = (',', ':'))

if len (sys.argv) < 2 or sys.argv [1] != "data":
    handler = mapHandler ()
    handler.apply_file ("greater-london-latest.osm.filtered.o5m")
    with open ("map.json", "w") as f:
        json.dump (handler.map_con, f, separators = (',', ':'))