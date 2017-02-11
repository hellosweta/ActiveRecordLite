class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) do
        # instance_variable_set("@#{name}")
        instance_variable_get("@#{name}")
      end
    end

    names.each do |name|
      method_name = "#{name}=".to_sym
      define_method(method_name) do |value|
        instance_variable_set("@#{name}", value)
      end
    end



  end
end
# def name
#   @name
#
# end
#
# def name= (value)
#
# end
