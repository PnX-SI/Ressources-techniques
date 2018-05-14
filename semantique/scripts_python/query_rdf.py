

from rdflib import plugin, Graph, Literal, URIRef
from rdflib.store import Store
from rdflib_sqlalchemy import registerplugins


registerplugins()

ident = URIRef("pt_ecoute")
dburi = Literal('sqlite:////tmp/store_pt_ecoute.db')

store = plugin.get("SQLAlchemy", Store)(identifier=ident)
graph = Graph(store, identifier=ident)
graph.open(dburi)

# Nb d'occurence du jeux de données
qres = graph.query(
    """
        SELECT (count(distinct ?s) as ?count)
        WHERE {
            ?s a <http://rs.tdwg.org/dwc/terms/Occurrence>
        }
    """)

for row in qres:
    print("%s " % row)

graph.close()
