# Stubbing object with #handle_asynchronously
# allows us to call the DelayedJob method in
# our interfaces to run the method in a queue
class Object
  def self.handle_asynchronously(param)
    puts "#{self.name}.#{param} called asynchronously"
  end
end
