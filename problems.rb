require "byebug"
module Enumerable
    def my_each(&blck)
        i = 0
        while i < self.length
            blck.call(self[i])
            i += 1
        end
        self
    end

    def my_reduce(*args, &blck)
        arr = self.to_a
        case args.length
        when 0
            raise "no block given" if blck == nil
            memo = arr[0]
            arr[1..-1].my_each { |i| memo = blck.call(memo, i) }
        when 1
            if args[0].kind_of?(Symbol)
                iter = args[0].to_proc
                memo = arr[0]
                arr[1..-1].my_each { |i| memo = iter.call(memo, i) }
            else
                raise "no block given" if blck == nil
                memo = args[0]
                arr.my_each { |i| memo = blck.call(memo, i) }
            end
        when 2
            raise TypeError.new("#{args[1]} is not a symbol") if !args[1].kind_of?(Symbol)
            memo, iter = args[0], args[1].to_proc
            arr.my_each { |i| memo = iter.call(memo, i) }
        end
        memo
    end
    alias_method :my_inject, :my_reduce

    def my_select(&blck)
        self.my_reduce([]) { |acc, ele| acc << ele if blck.call(ele); acc }
    end

    def my_reject(&blck)
        self.my_reduce([]) { |acc, ele| acc << ele unless blck.call(ele); acc }
    end

    def my_any?(&blck)
        self.my_reduce(false) { |acc, ele| acc ? acc : (blck.call(ele) ? (return true) : acc) }
    end

    def my_all?(&blck)
        self.my_reduce(true) { |acc, ele| acc ? blck.call(ele) : false }
    end

    def my_none?(&blck)
        self.my_reduce(true) { |acc, ele| acc ? (blck.call(ele) ? (return false) : acc) : acc }
    end
end

class Array
    def my_flatten
        self.my_reduce([]) { |acc, ele| ele.kind_of?(Array) ? acc.concat(ele.my_flatten) : acc << ele; acc }
    end

    def my_zip(*args)
        Array.new(self.length) { |i| 
            arr = []
            arr << self [i]
            args.my_each { |arg| arr << arg[i] }
            arr
        }
    end

    def my_rotate(num=1)
        rotated = Array.new(self.length) { |i| self[(i + num) % self.length] }
    end

    def my_join(separator="")
        joined = ""
        self.my_each { |i| joined += i.to_s + separator }
        separator == "" ? joined : joined.chomp(separator)
    end

    def my_reverse
        Array.new(self.length) { |i| self[self.length-i-1] }
    end
end



return_value = [1, 2, 3].my_each do |num|
    puts num
  end.my_each do |num|
    puts num
  end
  # => 1
  #    2
  #    3
  #    1
  #    2
  #    3
  p return_value  # => [1, 2, 3]

a = [1, 2, 3]
p a.my_select { |num| num > 1 } # => [2, 3]
p a.my_select { |num| num == 4 } # => []


a = [1, 2, 3]
p a.my_reject { |num| num > 1 } # => [1]
p a.my_reject { |num| num == 4 } # => [1, 2, 3]



a = [1, 2, 3]
p a.my_any? { |num| num > 1 } # => true
p a.my_any? { |num| num == 4 } # => false


p a.my_all? { |num| num > 1 } # => false
p a.my_all? { |num| num < 4 } # => true


p [1, 2, 3, [4, [5, 6]], [[[7]], 8]].my_flatten # => [1, 2, 3, 4, 5, 6, 7, 8]



a = [ 4, 5, 6 ]
b = [ 7, 8, 9 ]
p [1, 2, 3].my_zip(a, b) # => [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
p a.my_zip([1,2], [8])   # => [[4, 1, 8], [5, 2, nil], [6, nil, nil]]
p [1, 2].my_zip(a, b)    # => [[1, 4, 7], [2, 5, 8]]

c = [10, 11, 12]
d = [13, 14, 15]
p [1, 2].my_zip(a, b, c, d)    # => [[1, 4, 7, 10, 13], [2, 5, 8, 11, 14]]



a = [ "a", "b", "c", "d" ]
p a.my_rotate         #=> ["b", "c", "d", "a"]
p a.my_rotate(2)      #=> ["c", "d", "a", "b"]
p a.my_rotate(-3)     #=> ["b", "c", "d", "a"]
p a.my_rotate(15)     #=> ["d", "a", "b", "c"]



a = [ "a", "b", "c", "d" ]
p a.my_join         # => "abcd"
p a.my_join("$")    # => "a$b$c$d"



p [ "a", "b", "c" ].my_reverse   #=> ["c", "b", "a"]
p [ 1 ].my_reverse               #=> [1]
