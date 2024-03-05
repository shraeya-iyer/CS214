#lang dssl2

# HW3: Dictionaries

let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

import sbox_hash

# A signature for the dictionary ADT. The contract parameters `K` and
# `V` are the key and value types of the dictionary, respectively.
interface DICT[K, V]:
    # Returns the number of key-value pairs in the dictionary.
    def len(self) -> nat?
    # Is the given key mapped by the dictionary?
    # Notation: `key` is the name of the parameter. `K` is its contract.
    def mem?(self, key: K) -> bool?
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, key: K) -> V
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, key: K, value: V) -> NoneC
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, key: K) -> NoneC
    # The following method allows dictionaries to be printed
    def __print__(self, print)

# Struct for each node in the list/table
struct _cons:
    let key
    let value
    let next: OrC(_cons?, NoneC)
    
class AssociationList[K, V] (DICT):
    #Fields
    let _head
    
    # Initialize fields
    def __init__(self):
        self._head = None

    # Allows dictionaries to be printed
    def __print__(self, print):
        print("#<object:AssociationList head=%p>", self._head)

    # Returns the number of key value pairs in the dictionary
    def len(self): 
        let counter = 0
        let current = self._head
        while current:
            counter = counter + 1
            current = current.next
        return counter
    
    # Is the given key mapped by the dictionary?
    def mem?(self, K):
        let current = self._head
        if self.len() == 0:
            return False
        else:
            while current:
                if current.key == K:
                    return True
                current = current.next
            return False
                
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, K):
        let current = self._head
        if self.mem?(K):
            while current:
                if current.key == K:
                    return current.value
                current = current.next 
        else:
            error("Given key is not present")   
    
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.    
    def put(self, K, V):
        let current = self._head 
        if self.mem?(K):
            while current:
                if current.key == K:
                    current.value = V
                current = current.next
        else:
            self._head = _cons(K, V, self._head)
            
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, K):
        let current = self._head
        if self.mem?(K):
            if self._head.key == K:
                self._head = current.next
            else:
                while current.next:
                    if current.next.key == K:
                        current.next = current.next.next
                        return
                    current = current.next
           
# Test Suite
test 'yOu nEeD MorE tEsTs':
    let a = AssociationList()
    assert not a.mem?('hello')
    a.put('hello', 5)
    assert a.len() == 1
    assert a.mem?('hello')
    assert a.get('hello') == 5
    a.del('hello')
    assert a.len() == 0
    
    a.put('hi', 2)
    a.put('hola', 3)
    a.put('bonjour', 4)
    
    assert not a.mem?('hello')
    assert a.mem?('hi')
    assert a.mem?('bonjour')
    
    assert a.len() == 3
    
    assert a.get('hi') == 2
    assert a.get('hola') == 3
    assert a.get('bonjour') == 4
    assert_error a.get('hello')
    
    assert a.len() == 3
    a.del('hola')
    assert a.len() == 2
    a.del('hi')
    assert a.len() == 1
    a.del('bonjour')
    assert a.len() == 0
    a.del('hello') #shouldn't produce an error, should just do nothing
    
    a.put('hi', 2)
    assert a.get('hi') == 2
    
    a.put('hi', 5)
    assert a.get('hi') == 5
    


class HashTable[K, V] (DICT):
    # Fields
    let _hash
    let _size
    let _nbuckets
    let _data

    # Initializing fields
    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash
        self._nbuckets = nbuckets
        self._data = [0; nbuckets] 
        self._size = 0

    # This avoids trying to print the hash function, since it's not really
    # printable and isn’t useful to see anyway:
    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)
              
    # Helper function that abstracts code to hash the key and determine the bucket number
    def hasher_helper(self, K):
        let hash_number = self._hash(K)
        let bucket_number = hash_number % self._nbuckets
        return bucket_number
    
    # Returns the number of key-value pairs in the dictionary.
    def len(self):
        return self._size
        
    # Is the given key mapped by the dictionary?
    def mem?(self, K):
        if self._data[self.hasher_helper(K)] == 0:
            return False
        else:
            self._data[self.hasher_helper(K)].mem?(K)
    
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, K):
        if self._data[self.hasher_helper(K)] == 0:
            error("Given key is not present")
        else:
            self._data[self.hasher_helper(K)].get(K)
        
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, K, V):
        let shh = self.hasher_helper(K)
        if self._data[shh] == 0:
            self._data[shh] = AssociationList()
            self._data[shh].put(K, V) #is supposed to call the put method in association list class
            self._size = self._size + 1
        else:
            if self.mem?(K):
                self._data[shh].put(K, V)
            else:
                self._data[shh].put(K, V)
                self._size = self._size + 1
       
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, K):
        if self.mem?(K):
            self._data[self.hasher_helper(K)].del(K)
            self._size = self._size - 1
            
# first_char_hasher(String) -> Natural
# A simple and bad hash function that just returns the ASCII code 
# of the first character.
# Useful for debugging because it's easily predictable.
def first_char_hasher(s: str?) -> int?:
    if s.len() == 0:
        return 0
    else:
        return int(s[0]) 

test 'yOu nEeD MorE tEsTs, part 2':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    assert h.mem?('hello')
    assert h.get('hello') == 5
    
    h.del('hello')
    
    assert h.len() == 0
    
    h.put('bonjour', 6)
    h.put('bonsoir', 8)
    h.put('bonnuit', 10)
    
    assert h.len() == 3
    
    assert not h.mem?('hello')
    assert h.mem?('bonjour')
    assert h.mem?('bonsoir')
    assert h.mem?('bonnuit')
    
    assert h.get('bonsoir') == 8
    assert_error h.get('hello')
    assert h.get('bonnuit') == 10
    assert h.get('bonjour') == 6
    
    h.del('bonnuit')
    assert h.len() == 2
    h.del('bonjour')
    assert h.len() == 1
    h.del('bonsoir')
    assert h.len() == 0
    
    let j = HashTable(12, first_char_hasher) 
    h.put('apple', 4)
    h.put('pear', 7)
    h.put('apricot', 4)
    h.put('peach', 8)
    
    # checks to see that when there are multiple items in the 
    # same bucket, deleting one does not delete the other
    h.del('apple')
    assert_error h.get('apple')
    assert h.get('apricot') == 4
    # no error is thrown when attempt to remove a node that isnt there
    h.del('orange')
    
test 'gradedTestFailures':
    let o = HashTable(10, int)
    o.put(5, 'five')
    o.put(5, 'bees')
    assert o.len() == 1
    
test 'gradedTestFailures, part 2':
    let o = HashTable(10, int)
    o.put(5, 'five')
    o.del(6)
    assert o.get(5) == 'five'
    
test 'gradedTestFailures, part 3':
    let o = HashTable(10, int)
    o.put(5, 'five')
    o.del(6)
    assert o.len() == 1
    
test 'stress_test, part 1':
    let o = HashTable(10, int)
    for count in range(512):
        o.put(5, 'five')

test 'stress_test, part 2':
    let o = HashTable(10, int)
    for count in range(1024):
        o.put(5, 'five')
    
# Struct to feed into the value
struct _consV:
    let french_word
    let eng_pronounciation
    
def compose_phrasebook(d: DICT!) -> DICT?:
    d.put("Bonjour", _consV("Good Morning", "BOHN-joor"))
    d.put("Toilette", _consV("Toilet", "Twah-let"))
    d.put("Aimer", _consV("To Like", "Em-ai"))
    d.put("Merci", _consV("Thank you", "Mer-cee"))
    d.put("Cafe", _consV("Coffee", "Calf-ai"))
    return d
    

test "AssociationList phrasebook":
    let d = AssociationList()
    compose_phrasebook(d)
    assert d.get("Merci").eng_pronounciation == "Mer-cee"

test "HashTable phrasebook":
    let d = HashTable(10, first_char_hasher)
    compose_phrasebook(d)
    assert d.get("Merci").eng_pronounciation == "Mer-cee"
    
