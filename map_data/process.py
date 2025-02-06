# Built-in modules:
import json

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
    
    def node (self, n):
        self.map_con [n.id] = {
            "y": n.location.lat,
            "x": n.location.lon,
            "n": {}
        }

    def way (self, w):
        tags = dict (w.tags)
        if w.tags.get ("oneway") != "-1":
            for i, j in zip (tuple (w.nodes), tuple (w.nodes) [1 : ]):
                self.map_con [i.ref] ["n"] [j.ref] = tags.get ("name", "Unnamed Road")
                # self.map_con [i.ref] ["n"].append (j.ref)
        if w.tags.get ("oneway") != "yes":
            for i, j in zip (tuple (w.nodes) [1 : ], tuple (w.nodes)):
                self.map_con [i.ref] ["n"] [j.ref] = tags.get ("name", "Unnamed Road")
                # self.map_con [i.ref] ["n"].append (j.ref)

handler = lmmHandler ()
handler.apply_file ("greater-london-latest.osm.filtered.o5m")
with open ("produceddemand.json", "w") as f:
    json.dump (handler.map_con, f, separators = (',', ':'))