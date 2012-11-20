require 'bundler'
Bundler.setup

require 'nokogiri'
require 'algorithms'


class Song
  include Comparable

  attr_reader :name, :duration
  def initialize(name, duration)
    @name = name
    @clean_name = clean_name(name)
    @duration = duration
  end

  def clean_name(name)
    name = name.upcase
    name = name.strip
    name = name.gsub(/[^A-Za-z ]/, "")
    name
  end

  def last_letter()
    @clean_name[-1,1]
  end

  def first_letter()
    @clean_name[0]
  end

  def to_s()
    "#{@name}"
  end

  # horrible hack for using priority queue
  def <=>(other)
    self.object_id <=> other.object_id
  end


end


doc = Nokogiri::XML(open('SongLibrary.xml'))

nodes = Hash.new do |hash, key|
  hash[key] = []
end

edges = Hash.new do |hash, key|
  hash[key] = []
end

doc.xpath('/Library/Artist/Song').each do |song|
  name = song.attribute("name").to_s
  duration = song.attribute("duration").to_s
  song = Song.new(name, duration.to_s.to_i)
  nodes[name].push(song)
  edges[song.first_letter].push(song)
end





def shortest_weighted_path(start, finish, nodes, edges)
  infinity = 1/0.0

  prev_edge = {}
  
  duration = {}

  if !nodes.include?(start)
    puts "start does not exist"
    exit 1
  end

  if !nodes.include?(finish)
    puts "finish does not exist"
    exit 1
  end

  queue = Containers::MinHeap.new()

  nodes.each_value do |node_list|
    node_list.each do |node|
      if node.name == start
        key = [node.duration, node]
        queue.push(key, node)
        duration[node] = node.duration
      else
        key = [infinity, node]
        queue.push(key, node)
        duration[node] = infinity
      end
    end
  end

  while (!queue.empty?)
    next_vertex = queue.pop
    vertex_duration = duration[next_vertex]

    if vertex_duration == infinity
      break
    end

    edges[next_vertex.last_letter].each do |tail|

      tail_duration = duration[tail]
      new_tail_duration = vertex_duration + tail.duration

      if new_tail_duration < tail_duration
        original_key = [duration[tail], tail]
        queue.change_key(original_key, [new_tail_duration, tail])
        duration[tail] = new_tail_duration
        prev_edge[tail] = next_vertex
      end  
    end
  end

  best_duration, best_finish_node = nodes[finish].map {|n| [duration[n], n]}.sort_by {|d,n| d}.first

  puts best_duration

  dump_path(prev_edge, nodes[start], best_finish_node)
end

def shortest_path(start, finish, nodes, edges)
  prev_edge = {}

  visited = {}
  visited.default = false

  if !nodes.include?(start)
    puts "start does not exist"
    exit 1
  end

  if !nodes.include?(finish)
    puts "finish does not exist"
    exit 1
  end

  queue = Queue.new

  # for shortest path it doesn't matter...
  start_node = nodes[start].first
  finish_node = nodes[finish].first

  queue << start_node
  visited[start_node] = true

  while (!queue.empty?)
    next_vertex = queue.pop
    edges[next_vertex.last_letter].each do |tail|
      if !visited[tail]
        prev_edge[tail] = next_vertex
        queue << tail
        visited[tail] = true
        if finish_node == tail
          break
        end
      end    
    end
  end


  dump_path(prev_edge, [start_node], finish_node)
end

def dump_path(prev_edge, start_nodes, finish_node)
  result = [finish_node]
  next_edge = finish_node
  while (!prev_edge[next_edge].nil?)
    next_edge = prev_edge[next_edge]
    result << next_edge
  end

  result = result.reverse
 
  if start_nodes.include?(result[0])
    result.each do |song|
      puts "#{song.name} - #{song.duration}"
    end
  else
    puts "cannot find path"
  end  
end

start = ARGV[0]
finish = ARGV[1]

shortest_path(start, finish, nodes, edges)

shortest_weighted_path(start, finish, nodes, edges)


