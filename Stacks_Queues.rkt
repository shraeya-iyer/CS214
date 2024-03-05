#lang dssl2

# HW2: Stacks and Queues

let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

import ring_buffer

interface STACK[T]:
    def push(self, element: T) -> NoneC
    def pop(self) -> T
    def empty?(self) -> bool?

# Defined in the `ring_buffer` library; copied here for reference.
# Do not uncomment! or you'll get errors.
# interface QUEUE[T]:
#     def enqueue(self, element: T) -> NoneC
#     def dequeue(self) -> T
#     def empty?(self) -> bool?

# Linked-list node struct (implementation detail):
struct _cons:
    let data
    let next: OrC(_cons?, NoneC)

###
### ListStack
###

class ListStack[T] (STACK):

    # Fields
    let head

    # Constructs an empty ListStack
    def __init__ (self): 
        self.head = None
        
    ## Methods
    # Checks whether the stack is empty or not
    def empty?(self):
        if self.head == None:
            return True
        else:
            return False
            
    # Adds an element to the head of a stack
    def push(self, element: T):
        self.head = _cons(element, self.head)  
    
    # Removes an element from the head of the stack
    def pop(self):
        if self.empty?() == True:
            error('No elements in stack')
        else:
            let poppedVariable = self.head.data
            self.head = self.head.next
            return poppedVariable       

test "Stack tests":
    
    let s = ListStack()
    s.push("box")
    assert s.pop() == "box"
    
    s.push("paper")
    s.push("ton")
    assert s.pop() == "ton"
    assert s.pop() == "paper"
    assert_error s.pop()
    assert s.empty?() == True
    
    s.push("container")
    assert s.empty?() == False
    

###
### ListQueue
###

class ListQueue[T] (QUEUE):

    # Fields
    let head
    let tail

    # Constructs an empty ListQueue
    def __init__ (self):
        self.head = None
        self.tail = None
        
    ## Methods
    # Checks whether the ListQueue is empty or not
    def empty?(self):
        if (self.head == None):
            return True
        else:
            return False
    # Adds an element to the end of a ListQueue    
    def enqueue(self, element: T):
        if self.empty?():
            let a = _cons(element, None)
            self.tail = a
            self.head = a
        elif self.head.next == None: 
            let b = _cons(element, None)
            self.head.next = b
            self.tail = b
        else:
            self.tail.next = _cons(element, None)
            self.tail = self.tail.next
            
    # Removes an element from the beginning of the queue and returns the removed element
    def dequeue(self):
        if self.empty?():
            error('No elements in queue')
        else:
            let dequeuedVariable = self.head.data
            self.head = self.head.next
            return dequeuedVariable
            
# Tests for ListQueue
test "Queue tests":
    let q = ListQueue()
    q.enqueue(2)

    #testing the else clause in the if statement in the empty? method
    assert q.empty?() == False
    
    #testing the else clause in the if statement in the dequeue method
    assert q.dequeue() == 2
    
    # testing the first if clause in the enqueue method
    q.enqueue(5)
    
    #testing the elif clause in the if statement in the enqueue method
    q.enqueue(7)
    
    #testing the else clause in the if statement in the enqueue method
    q.enqueue(9)

    #testing the else clause in the if statement in the dequeue method
    assert q.dequeue() == 5
    assert q.dequeue() == 7
    assert q.dequeue() == 9
    
    #testing the first if clause in the empty? method
    assert q.empty?() == True
    
    #testing the first if clause in the dequeue method
    assert_error q.dequeue()
    

###
### Playlists
###

struct song:
    let title: str?
    let artist: str?
    let album: str?

# Enqueue five songs of your choice to the given queue, then return the first
# song that should play.
def fill_playlist (q: QUEUE!):
    q.enqueue(song("Nights", "Frank Ocean", "Blonde"))
    q.enqueue(song("Infatuation", "Takeoff", "The Last Rocket"))
    q.enqueue(song("love.", "Kid Cudi", "The Boy Who Flew To The Moon (Vol. 1)"))
    q.enqueue(song("16", "Baby Keem", "The Melodic Blue"))
    q.enqueue(song("Fashion Killa", "A$AP Rocky", "LONG.LIVE.A$AP (Deluxe Version)"))
    q.dequeue()

test "ListQueue playlist":
    let ep = ListQueue() #ep: empty playlist
    assert fill_playlist(ep) == song("Nights", "Frank Ocean", "Blonde")

# To construct a RingBuffer: RingBuffer(capacity)
test "RingBuffer playlist":
    let ep = RingBuffer(5)
    assert fill_playlist(ep) == song("Nights", "Frank Ocean", "Blonde")
    
