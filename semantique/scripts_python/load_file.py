"""
    Script permettant de charger un rdf dans une base sqlite
    qui pourra ensuite en théorie être utiliser comme
    triple store
"""

from rdflib import plugin, Graph, Literal, URIRef
from rdflib.store import Store
from rdflib_sqlalchemy import registerplugins


registerplugins()

ident = URIRef("pt_ecoute")
dburi = Literal('sqlite:////tmp/store_pt_ecoute.db')

store = plugin.get("SQLAlchemy", Store)(identifier=ident)
graph = Graph(store, identifier=ident)
graph.open(dburi, create=True)

print("loading file taxon ...")
graph.parse("../TAXON_pt_ecoute.rdf")
print("file load")

print("loading file occurences ...")
graph.parse("../data_pt_ecoute.rdf")
print("file load")

graph.close()
