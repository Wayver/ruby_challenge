

# inputs must be strings of only lower case alphanumeric characters.

# define class "Node" to explore possible word combinations
# it matches first characters in a string to all possible words
# if the remaining characters start with a word,
# it recurses on the remaining characters corresponding to each match

class Node

  @@finalists = []
  @@id = 0
  @@all_nodes = {}
  attr_reader :seeds
  attr_reader :sent
  attr_reader :id
  attr_reader :parent  
  
  def self.finalist
     @@finalists
  end
  
  def self.id
    @@id
  end

  def self.all_nodes
    @@all_nodes
  end

  def initialize(input, dict, parent="none")
    
    @sent = input     # original/remaining sentence input
    @seeds = []       # array for info going to new nodes.
    @scount = 0       # counts the seeds
    @flowers = []     # array of nodes made from seeds
    @dict = dict      # dictionary used to evaluate the node
    @parent = parent  # set parent node
      
    @dict.each { |wtype,list|
      list.each { |inst|
        grow_new_node = false 
      
	# check if a word can be found at the start of remaining string
	# if so, store pertinent information
	 	    
      	if @sent[0..inst.length - 1] == inst  
	  @seeds.push({})
	  @seeds[@scount][:word] = @sent[0..inst.length - 1]
	  @seeds[@scount][:future] = "1" 
	  @seeds[@scount][:type] = wtype
          @@id += 1
          @seeds[@scount][:id] = @@id
	  @seeds[@scount][:parent] = @parent
	  @seeds[@scount][:sent] = @sent
	  grow_new_node = true

	  # a word has been found, but the future of the tree is uncertain
	  # look ahead for possible future words 

	  hope = false
	  @dict.each { |swtype,slist|
	    slist.each { |point|
	      if @sent[inst.length..inst.length + point.length-1] == point
	        hope = true
	      end
	    } 
          }
          
          if hope
	    @seeds[@scount][:future] = @sent[inst.length..-1]
          end
        end
		
      # check if the word being matched is the last remaining word in the string
      # if it is, it is a finalist
		
      if inst.length == @sent.length 
        if inst == @sent[0..inst.length - 1]
	  if @sent[@sent.length-inst.length..-1] == inst
            @seeds[@scount][:future] = "0"
	    @@finalists.push(@seeds[@scount])
         end
       end
     end

      # grow_new_node was set true, a new seed has been created
      if grow_new_node == true
        @scount += 1
      end
      }
    }

   # all seeds with a future grow into new nodes

   @seeds.each { |beginning|
      @@all_nodes[beginning[:id]] = beginning
     if beginning[:future] != "0" && beginning[:future] != "1"
       @flowers.push(Node.new(beginning[:future], @dict, beginning[:id]))
     end
   }
  end

end


def step_back(winner,keepers) 
   
  if winner[:parent] != "none"
    ancestor = Node.all_nodes[winner[:parent]]
    keepers.push([winner[:word], winner[:type]])
    step_back(ancestor, keepers)
  end   	
  
  if winner[:parent] == "none"
    keepers.push([winner[:word], winner[:type]])
  end     	
end

# begin main body

# declare dictionary
dictionary = {}
dictionary["nouns"] = ["abcd", "c", "def", "h", "ij", "cde"]
dictionary["verbs"] = ["bc", "fg", "g", "hij", "bcd"]
dictionary["articles"] = ["a", "ac", "e"]

# acceptable sentence criteria:
# all words can be found in dictionary
# must contain at least one verb
# must have a noun or at least two articles

# create original node
orig = Node.new(ARGV[0], dictionary)

#Node.all_nodes.each { |node| puts(node) }
total_results = []
result_count = 0

Node.finalist.each { |survivor|
  total_results.push([])
  step_back(survivor, total_results[result_count])
  result_count += 1
}


# assess each finalist for word count criteria
# this could be wrapped into finalist data in the future

compiled_result = []
total_results.each { |entry|

v_c = 0
a_c = 0
n_c = 0

  entry.each { |word,type|
   
  case type
	  
  when "verbs"
    v_c += 1

  when "articles"
    a_c += 1

  when "nouns"
    n_c += 1
  end
  }

  if v_c >= 1
    if n_c >=1 || a_c >= 2
      new_sentence = ""
      entry.reverse.each { |thing|
	new_sentence << thing[0] << " "
      }
      compiled_result.push(new_sentence.rstrip)
    end
  end 
}

puts("#{compiled_result}")


