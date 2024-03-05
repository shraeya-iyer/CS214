#lang dssl2

# HW5: Binary Heap

let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

interface PRIORITY_QUEUE[X]:
    # Returns the number of elements in the priority queue.
    def len(self) -> nat?
    # Returns the smallest element; error if empty.
    def find_min(self) -> X
    # Removes the smallest element; error if empty.
    def remove_min(self) -> NoneC
    # Inserts an element; error if full.
    def insert(self, element: X) -> NoneC

# Class implementing the PRIORITY_QUEUE ADT as a binary heap.
class BinHeap[X] (PRIORITY_QUEUE):
    let _data: VecC[OrC(X, NoneC)]
    let _size: nat?
    let _capacity: nat?
    let _lt?:  FunC[X, X, bool?]

    # Constructs a new binary heap with the given capacity and
    # less-than function for type X.
    def __init__(self, capacity, lt?):
        self._data = [None; capacity]
        # used for length, so size is manipulated when added and subtracted
        self._size = 0
        # added another one (is this aliasing issue) so that can track how many tree originally should have
        self._capacity = capacity
        self._lt? = lt?
    
    # Returns the number of elements in the priority queue.
    def len(self) -> nat?:
        return self._size
        
    # Returns smallest element in the queue, error if none.
    def find_min(self):
        if self.len() == 0:
            error('Queue is empty')
        else:
            return self._data[0]
            
    # swaps the values associated with the 2 given indexes
    def swap(self, i: nat?, j: nat?):
        let old_top = self._data[i]
        self._data[i] = self._data[j]
        self._data[j] = old_top
        
    # reorders the binary heap by swapping a node with its child if its smaller 
    def trickle_down(self):
        for i in range(self.len()):
            let left_child = 2*i+1
            let right_child = 2*i+2
            let smaller_child = None
                
            # check if left child is within valid range and if it's smaller
            if left_child < self.len() and self._lt?(self._data[left_child], self._data[i]):
                smaller_child = left_child
            else:
                smaller_child = i

            # check if right child is within valid range and if it's smaller
            if right_child < self.len() and self._lt?(self._data[right_child], self._data[smaller_child]):
                smaller_child = right_child

            if smaller_child == i:
                # current element is smaller than its children, so no need to trickle down more
                break

            # swap the current element with the smaller child
            self.swap(i, smaller_child)
            i = smaller_child
            
    # Removes the smallest element; error if empty.
    def remove_min(self):
        if self.len() == 0:
            error('Queue is empty')
        else: 
            # swap the last element in the tree with the first element since it's the smallest
            let n = self._data[self.len() - 1]
            self._data[self.len() - 1] = self._data[0]
            self._data[0] = n
            # remove the last element
            self._data[self.len() - 1] = None
            # decrease length
            self._size = self._size - 1
            # trickle down to reorder the tree
            self.trickle_down()
        
    # reorders the binary heap by swapping a node with its parent if its smaller 
    def bubble_up(self, i, element):
        while i is not 0:
            let parent = (i - 1) // 2
            if self._lt?(element, self._data[parent]):
                self.swap(parent, i)
                i = parent
            else:
                break
        
    # Inserts an element; error if full.
    def insert(self, element):
        # if the tree is full, throw an error
        if self.len() == self._capacity:
            error('Tree is full')
        else:
            # the length will be the next unfilled index, know this variable not necessary but helps me visualize
            let next_free_index = self.len()
            # add the element to end of the tree
            self._data[next_free_index] = element
            # increasing the length of the tree
            self._size = self._size + 1
            # if the length is 1, this was the first item inserted and the binheap will already be in order
            if self.len() > 1: 
                # bubble up to reorder tree
                self.bubble_up(next_free_index, element)
  
# Tests for interface methods
test 'insert, insert, remove_min':
    # The `nat?` here means our elements are restricted to `nat?`s.
    let h = BinHeap[nat?](10, λ x, y: x < y)
    h.insert(1)
    assert h.find_min() == 1
    assert h.len() == 1
    
    h.remove_min()
    assert h.len() == 0
    assert_error h.find_min() 
    assert_error h.remove.min()
    

test 'test 2':
    let h = BinHeap[nat?](6, λ x, y: x < y)
    assert h.len() == 0
    h.insert(6)
    assert h.find_min() == 6
    assert h.len() == 1
    
    h.insert(2)
    assert h.find_min() == 2
    assert h.len() == 2
    
    h.insert(3)
    assert h.find_min() == 2
    assert h.len() == 3
    
    h.insert(10)
    assert h.find_min() == 2
    assert h.len() == 4
    
    h.insert(1)
    assert h.find_min() == 1
    assert h.len() == 5
    
    h.insert(15)
    assert h.find_min() == 1
    assert h.len() == 6
    
    assert_error h.insert(16)
    
    h.remove_min()
    assert h.find_min() == 2
    assert h.len() == 5
    
    h.remove_min() 
    assert h.find_min() == 3
    assert h.len() == 4
    
    h.insert(2)
    assert h.find_min() == 2
    assert h.len() == 5
    
test 'test binheap of strings':
    let h = BinHeap[str?](3, λ x, y: x.len() < y.len())
    assert h.len() == 0
    assert_error h.remove_min()
    assert_error h.find_min()
    h.insert("cat")
    assert h.find_min() == "cat"
    assert h.len() == 1
    
    h.insert("cheetah")
    assert h.find_min() == "cat"
    assert h.len() == 2
    
    # duplicate because length of cat and rat are the same
    h.insert("rat")
    assert h.find_min() == "cat"
    assert h.len() == 3
            
    
test 'test duplicates nums':
    let h = BinHeap[nat?](4, λ x, y: x < y)
    assert h.len() == 0
    h.insert(4)
    assert h.find_min() == 4
    assert h.len() == 1
    
    h.insert(4)
    assert h.find_min() == 4
    assert h.len() == 2
    
    h.insert(4)
    assert h.find_min() == 4
    assert h.len() == 3
    
    h.insert(2)
    assert h.find_min() == 2
    assert h.len() == 4
    

# Sorts a vector of Xs, given a less-than function for Xs.
#
# This function performs a heap sort by inserting all of the
# elements of v into a fresh heap, then removing them in
# order and placing them back in v.
def heap_sort[X](v: VecC[X], lt?: FunC[X, X, bool?]) -> NoneC:
    let b = BinHeap[X](v.len(), lt?)
    for i in v:
        b.insert(i)
    for i in range(b.len()):
        v[i] = b.find_min()
        b.remove_min()

# Tests for heap_sort method
test 'heap sort descending':
    let v = [3, 6, 0, 2, 1]
    heap_sort(v, λ x, y: x > y)
    assert v == [6, 3, 2, 1, 0]
    
test 'heap sort ascending':
    let v = [3, 6, 0, 2, 1]
    heap_sort(v, λ x, y: x < y)
    assert v == [0, 1, 2, 3, 6]
    
test 'heap sort strings ascending':
    let v = ["candy", "pumpkin", "bat", "supercalafragalisticexpialidocious"]
    heap_sort(v, λ x, y: x.len() < y.len())
    assert v == ["bat", "candy", "pumpkin", "supercalafragalisticexpialidocious"]

test 'heap sort strings descending':
    let v = ["candy", "pumpkin", "bat", "cat", "brandy"]
    heap_sort(v, λ x, y: x.len() > y.len())
    assert v == ["pumpkin", "brandy", "candy", "bat", "cat"]

# Sorting colleges

struct college:
    let name: str?
    # Where is the college located? Can be "rural", "urban" or "suburban".
    let environment: str?
    # Average salary of graduates five years after graduation.
    let salary: int?
    # Average yearly tuition.
    let tuition: int?
    # Average SAT score of last incoming freshling class: between 400 and 1600.
    let sat: int?
    # Average GPA of last incoming freshling class: between 0.0 and 4.0.
    let gpa: num?
    # Number of full-time students attending the school as of last fall.
    let students: int?
    # Student-to-faculty ratio. E.g., 7000 students and 1000 faculty => 7
    let stf_ratio: num?
    # Acceptance rate. 0.0 = accepts no one. 1.0 = accepts everyone.
    let acceptance: num?

let sample_colleges = \
  [college("Montgomery College", "urban", 70000, 30000, 1500, 3.8, 4000, 8, 0.22),
   college("Vanderwaal University", "rural", 100000, 70000, 1550, 4.0, 1000, 2, 0.01),
   college("Hastings University", "suburban", 70000, 50000, 1530, 3.9, 8500, 6, 0.07),
   college("Marin College", "suburban", 38000, 6000, 1410, 3.9, 1500, 9, 0.39),
   college("Fields University","rural", 54000, 10000, 1360, 3.6, 500, 13, 0.53),
   college("Dilaurentis University", "rural", 58000, 40000, 1400, 3.7, 5000, 8, 0.44)
   ]

# Is `a` a better college than `b`?
# You decide what makes a college better than another, and you can use any
# or all of the information you have about each college to determine that.
def is_better?(a: college?, b: college?) -> bool?:
    let environment_prefs = a.environment == "rural" and b.environment is not "rural"
    let acceptance_pref = a.acceptance < b.acceptance 
    let gpa_pref = a.gpa > b.gpa
    let tuition_pref = a.tuition < b.tuition
    let salary_pref = a.salary > b.salary
    let stf_pref = a.stf_ratio < b.stf_ratio
    
    let money_prefs = tuition_pref or salary_pref
    let academic_prefs = (acceptance_pref and stf_pref) or (gpa_pref and stf_pref)
    
    return money_prefs and academic_prefs and environment_prefs

# Rank the sample colleges above, in order from "best" to "worst".
def rank_colleges() -> VecC[college?]:
    let ranked_colleges = heap_sort(sample_colleges, λ x, y: is_better?(x, y)) 
    return sample_colleges
    
# Testing rank_colleges() to make sure the output was as expected, commented for submission
'''
test 'rank colleges':
    let ranked_colleges = rank_colleges()
    println("%p", ranked_colleges)
'''