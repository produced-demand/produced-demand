# Built-in modules:
import json, math

# Third-party modules:
import osmium

class lmmHandler (osmium.SimpleHandler):
    def __init__ (
            self,
            map_con = {},
            stats = {}):
        super (lmmHandler, self).__init__ ()
        self.map_con = map_con
        self.stats = stats
        self.tags = {}

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

handler = lmmHandler ()
handler.apply_file ("greater-london-latest.osm.filtered.o5m")
with open ("produceddemand.json", "w") as f:
    json.dump (handler.map_con, f, separators = (',', ':'))