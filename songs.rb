require 'nokogiri'
#require 'queue'

class Song
  def initialize(name, time)
    @name = name
    @clean_name = clean_name(name)
    @time = time
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
  song = Song.new(name, duration)
  nodes[name].push(song)
  edges[song.first_letter].push(song)
end

def duration(nodes, edges)

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

  start_nodes = nodes[start]
  finish_nodes = nodes[finish]

  start_nodes.each do |start_node|
    queue << start_node
    visited[start_node] = true
  end

  final_node = nil
  while (!queue.empty?)
    next_vertex = queue.pop
    edges[next_vertex.last_letter].each do |tail|
      if !visited[tail]
        prev_edge[tail] = next_vertex
        queue << tail
        visited[tail] = true
        if finish_nodes.include?(tail)
          final_node = tail
          break
        end
      end    
    end
  end

  if final_node.nil?
    puts "could not find a path"
  else
    result = [final_node]
    next_edge = final_node
    while (!prev_edge[next_edge].nil?)
      next_edge = prev_edge[next_edge]
      result << next_edge
    end

    result = result.reverse
    puts result
  end
end

start = ARGV[0]
finish = ARGV[1]

shortest_path(start, finish, nodes, edges)


