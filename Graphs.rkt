#lang dssl2

# HW4: Graph

let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

import cons
import 'hw4-lib/dictionaries.rkt'


###
### REPRESENTATION
###

# A Vertex is a natural number.
let Vertex? = nat?

# A VertexList is either
#  - None, or
#  - cons(v, vs), where v is a Vertex and vs is a VertexList
let VertexList? = Cons.ListC[Vertex?]

# A Weight is a real number. (It’s a number, but it’s neither infinite
# nor not-a-number.)
let Weight? = AndC(num?, NotC(OrC(inf, -inf, nan)))

# An OptWeight is either
# - a Weight, or
# - None
let OptWeight? = OrC(Weight?, NoneC)

# A WEdge is WEdge(Vertex, Vertex, Weight)
struct WEdge:
    let u: Vertex?
    let v: Vertex?
    let w: Weight?

# A WEdgeList is either
#  - None, or
#  - cons(w, ws), where w is a WEdge and ws is a WEdgeList
let WEdgeList? = Cons.ListC[WEdge?]

# A weighted, undirected graph ADT.
interface WUGRAPH:

    # Returns the number of vertices in the graph. (The vertices
    # are numbered 0, 1, ..., k - 1.)
    def len(self) -> nat?

    # Sets the weight of the edge between u and v to be w. Passing a
    # real number for w updates or adds the edge to have that weight,
    # whereas providing providing None for w removes the edge if
    # present. (In other words, this operation is idempotent.)
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?) -> NoneC

    # Gets the weight of the edge between u and v, or None if there
    # is no such edge.
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?

    # Gets a list of all vertices adjacent to v. (The order of the
    # list is unspecified.)
    def get_adjacent(self, v: Vertex?) -> VertexList?

    # Gets a list of all edges in the graph, in an unspecified order.
    # This list only includes one direction for each edge. For
    # example, if there is an edge of weight 10 between vertices
    # 1 and 3, then exactly one of WEdge(1, 3, 10) or WEdge(3, 1, 10)
    # will be in the result list, but not both.
    def get_all_edges(self) -> WEdgeList?

class WUGraph (WUGRAPH):
    let vertexes
    let base_array

    def __init__(self, size: nat?):
        self.vertexes = size
        self.base_array = [0; self.vertexes] 
        
        # Assigns an array to each of the indexes of the base_array to 
        # create a 2D array
        for i in range(self.vertexes):
            self.base_array[i] = [None; self.vertexes]

    # Returns the number of vertices in the graph.
    def len(self):
        return self.vertexes
        
    # Sets the weight of the edge between u and v to be w. 
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?):
        self.base_array[u][v] = w 
        self.base_array[v][u] = w
        
    # Gets the weight of the edge between u and v, or None if there
    # is no such edge.  
    def get_edge(self, u: Vertex?, v: Vertex?):
        return self.base_array[u][v]
         
    # Gets a list of all vertices adjacent to v.
    def get_adjacent(self, v: Vertex?):
        if v <= self.len() - 1:
            let current_row = self.base_array[v]
            let adjacent_vertexes = None
            for i in range(current_row.len()):
                if self.get_edge(v, i) is not None:
                    adjacent_vertexes = cons(i, adjacent_vertexes)
            return adjacent_vertexes
        else:
            return None
             
    # Gets a list of all edges in the graph, in an unspecified order.
    # This list only includes one direction for each edge.   
    def get_all_edges(self):
        let edges = None
        for i in range(self.vertexes):
            for j in range(self.vertexes):
                if i <= j:
                    if self.base_array[i][j] is not None:
                        edges = cons(WEdge(i, j, self.get_edge(i, j)), edges)
        return edges
                        
test 'test 1':
    let g = WUGraph(5)
    assert g.len() == 5
    
    g.set_edge(0, 1, 3)
    g.set_edge(1, 2, 2)
    g.set_edge(1, 3, 8)
    g.set_edge(2, 3, 1)
    g.set_edge(2, 2, 9)
    
    assert g.len() == 5
    
    assert g.get_edge(0, 1) == 3
    assert g.get_edge(2, 3) == 1
    assert g.get_edge(3, 4) == None
    
    assert g.len() == 5
    
    assert g.get_adjacent(0) == cons(1, None)
    assert g.get_adjacent(1) == cons(3, cons(2, cons(0, None)))
    assert g.get_adjacent(4) == None
    
    assert g.len() == 5
    
    assert g.get_all_edges() == cons(WEdge(2, 3, 1), cons(WEdge(2, 2, 9), cons(WEdge(1, 3, 8), cons(WEdge(1, 2, 2), cons(WEdge(0, 1, 3), None)))))
    
test 'test 2':
    let g = WUGraph(0)
    assert g.get_all_edges() == None
    assert g.len() == 0
    assert g.get_adjacent(3) == None
    
test 'test 3':
    let g = WUGraph(1)
    assert g.get_edge(0, 0) == None
    assert g.get_adjacent(0) == None
    assert g.get_adjacent(2) == None
    assert g.get_all_edges() == None
    assert g.len() == 1
    
test 'test 4':
    let g = WUGraph(3)
    g.set_edge(2, 0, 7)
    g.set_edge(0, 1, 3)
    assert g.get_edge(2, 0) == 7
    assert g.get_edge(0, 1) == 3
    assert g.get_edge(1, 2) == None
    assert g.get_adjacent(0) == cons(2, cons(1, None))
    assert g.get_adjacent(2) == cons(0, None)
    assert g.get_adjacent(3) == None
    #assert g.get_all_edges() == cons(WEdge(0, 1, 3), cons(WEdge(2, 0, 7), None))
    assert g.len() == 3
    
test 'test 5':
    let g = WUGraph(2)
    g.set_edge(0, 1, 9)
    g.set_edge(0, 0, 2)
    assert g.get_edge(0, 0) == 2
    assert g.get_edge(0, 1) == 9
    assert g.get_edge(1, 1) == None
    assert g.get_adjacent(0) == cons(1, cons(0, None))
    assert g.get_adjacent(1) == cons(0, None)
    assert g.get_adjacent(2) == None
    assert g.get_all_edges() == cons(WEdge(0, 1, 9), cons(WEdge(0, 0, 2), None))
    assert g.len() == 2

###
### List helpers
###

# To test methods that return lists with elements in an unspecified
# order, you can use these functions for sorting. Sorting these lists
# will put their elements in a predictable order, order which you can
# use when writing down the expected result part of your tests.

# sort_vertices : ListOf[Vertex] -> ListOf[Vertex]
# Sorts a list of numbers.
def sort_vertices(lst: Cons.list?) -> Cons.list?:
    def vertex_lt?(u, v): return u < v
    return Cons.sort[Vertex?](vertex_lt?, lst)

# sort_edges : ListOf[WEdge] -> ListOf[WEdge]
# Sorts a list of weighted edges, lexicographically
# ASSUMPTION: There's no need to compare weights because
# the same edge can’t appear with different weights.
def sort_edges(lst: Cons.list?) -> Cons.list?:
    def edge_lt?(e1, e2):
        return e1.u < e2.u or (e1.u == e2.u and e1.v < e2.v)
    return Cons.sort[WEdge?](edge_lt?, lst)

###
### BUILDING GRAPHS
###

def example_graph() -> WUGraph?:
    let result = WUGraph(6) # 6-vertex graph from the assignment
    result.set_edge(0, 1, 12)
    result.set_edge(1, 2, 31)
    result.set_edge(1, 3, 56)
    result.set_edge(2, 4, -2)
    result.set_edge(2, 5, 7)
    result.set_edge(3, 4, 9)
    result.set_edge(3, 5, 1)
    return result
    
struct CityMap:
    let graph
    let city_name_to_node_id
    let node_id_to_city_name
    
def cities_to_nodes(d: DICT!):
    d.put("Seattle", 0)
    d.put("Bellevue", 1)
    d.put("Shoreline", 2)
    d.put("Kenmore", 3)
    d.put("Kirkland", 4)
    return d
    
def city_graph() -> WUGraph?:
    let result = WUGraph(5)
    result.set_edge(0, 1, 9.7)
    result.set_edge(1, 4, 4.8)
    result.set_edge(0, 2, 11.6)
    result.set_edge(2, 3, 5.3)
    result.set_edge(0, 3, 13.7)
    result.set_edge(0, 4, 11)
    return result

def my_neck_of_the_woods():
    let node_to_cities = ['Seattle', 'Bellevue', 'Shoreline', 'Kenmore', 'Kirkland'] # nodes to cities
    let d = HashTable(10, first_char_hasher)
    return CityMap(city_graph(), cities_to_nodes(d), node_to_cities)
    
test 'my_neck_of_the_woods test':
    let city_map = my_neck_of_the_woods()
    let city_name_to_node_id = city_map.city_name_to_node_id
    let node_id_to_city_name = city_map.node_id_to_city_name
    
    let city = 'Bellevue'
    let node_id = city_name_to_node_id.get(city)
    
    if node_id is not None:
        let next_door = city_map.graph.get_adjacent(node_id)

        if next_door is not None:
            println("Neighbors of " + city + ":")
            for next_door_node_id in next_door:
                let next_door_city = node_id_to_city_name[next_door_node_id]
                println("- " + next_door_city)
        else:
            println(city + " has no neighbors.")
    else:
        println("City not found in the map.")
        
    
###
### DFS
###

# dfs : WUGRAPH Vertex [Vertex -> any] -> None
# Performs a depth-first search starting at `start`, applying `f`
# to each vertex once as it is discovered by the search.
def dfs(graph: WUGRAPH!, start: Vertex?, f: FunC[Vertex?, AnyC]) -> NoneC:
    let seen = [False; graph.len()]
    def traverse(v: Vertex?, graph: WUGRAPH!, f: FunC[Vertex?, AnyC]):
             #vec(graph.len(), False)
        if seen[v] == False:
            seen[v] = True
            let v_old = v
            f(v)
            for i in Cons.to_vec(graph.get_adjacent(v_old)):
                traverse(i, graph, f)
    traverse(start, graph, f)


# dfs_to_list : WUGRAPH Vertex -> ListOf[Vertex]
# Performs a depth-first search starting at `start` and returns a
# list of all reachable vertices.
#
# This function uses your `dfs` function to build a list in the
# order of the search. It will pass the test below if your dfs visits
# each reachable vertex once, regardless of the order in which it calls
# `f` on them. However, you should test it more thoroughly than that
# to make sure it is calling `f` (and thus exploring the graph) in
# a correct order.
def dfs_to_list(graph: WUGRAPH!, start: Vertex?) -> VertexList?:
    let list = None
    # Add to the front when we visit a node
    dfs(graph, start, lambda new: list = cons(new, list))
    # Reverse to the get elements in visiting order.
    return Cons.rev(list)

###
### TESTING
###

test 'dfs_to_list(example_graph())':
    # Cons.from_vec is a convenience function from the `cons` library that
    # allows you to write a vector (using the nice vector syntax), and get
    # a linked list with the same elements.
    assert sort_vertices(dfs_to_list(example_graph(), 0)) \
        == Cons.from_vec([0, 1, 2, 3, 4, 5])
        
test 'dfs_to_list(city_graph())':
    let city_map = my_neck_of_the_woods()
    let start_city = 'Seattle'
    let start_node_id = city_map.city_name_to_node_id.get(start_city)
    
    assert sort_vertices(dfs_to_list(city_map.graph, start_node_id)) \
        == Cons.from_vec([0, 1, 2, 3, 4])
     
test 'dfs_to_list(single_node)':
    let single_node = WUGraph(1)
    let start_node_id = 0
    
    assert sort_vertices(dfs_to_list(single_node, start_node_id)) \
        == Cons.from_vec([0])
        
test 'dfs_to_list(empty)':
    let empty = WUGraph(0)
    
    assert dfs_to_list(empty, 0) == None
