class DerivedGenreCalculatorHelper
  attr_accessor :calculator

  delegate :genre_util, to: :calculator

  def initialize(calculator)
    @calculator = calculator
  end

  def calculate_name_embedded_points_for(obj)
    genre_util.genres_in_name(obj.name).map do |name|
      {point_type: 'name', genre_name: name, value: 0.5, source: obj}
    end
  end
end
