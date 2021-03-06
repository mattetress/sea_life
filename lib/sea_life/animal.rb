class SeaLife::Animal
  attr_accessor :url, :name, :distribution, :habitat, :habits, :status, :taxonomy, :short_desc, :longer_desc, :scientific_name
  attr_reader :category
  @@all = []

  def initialize(info)
    add_info(info)
    @@all << self
  end

  def category=(category)
    @category = category
    category.animals << self
  end

  def add_info(info)
    info.each { |k, v| self.send("#{k}=", v) }
  end

  def self.all
    @@all
  end

  def self.find_by_name(name)
    self.all.detect { |animal| animal.name == name }
  end
end
