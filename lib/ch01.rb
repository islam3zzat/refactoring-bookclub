require 'pry'

class Customer
  attr_reader :name, :rentals

  def initialize(name)
    @name = name
    @rentals = []
  end

  def html_statement
    result = "<h1>Rental Record for <em>#{name}</em>\n</h1>\n"

    rentals.each do |rental|
      # show figures for this rental
      result += "\t" + rental.movie.title + "\t" + rental.charge.to_s + "<br />\n"
    end

    # add footer lines
    result += "<p>Amount owed is <em>#{total_charge}</em></p>\n"
    result += "You earned <em>#{total_frequent_renter_points}</em> frequent renter points"
    result
  end

  def statement
    result = "Rental Record for #{name}\n"

    rentals.each do |rental|
      # show figures for this rental
      result += "\t" + rental.movie.title + "\t" + rental.charge.to_s + "\n"
    end

    # add footer lines
    result += "Amount owed is #{total_charge}\n"
    result += "You earned #{total_frequent_renter_points} frequent renter points"
    result
  end

  def add_rental(rental)
    rentals << rental
  end

  private

  def total_charge
    rentals.inject(0) { |sum, rental| sum + rental.charge }
  end

  def total_frequent_renter_points
    rentals.inject(0) { |sum, rental| sum + rental.frequent_renter_points }
  end

end
class Movie
  REGULAR = 0
  NEW_RELEASE = 1
  CHILDRENS = 2

  attr_reader :title, :price

  def initialize(title, price)
    @title, @price = title, price
  end

  def charge(days_rented)
    price.charge(days_rented)
  end

  def frequent_renter_points(days_rented)
    price.frequent_renter_points(days_rented)
  end

end
class RegularPrice
  def charge(days_rented)
    result = 2
    result += (days_rented - 2) * 1.5 if days_rented > 2
    result
  end

  def frequent_renter_points(days_rented)
    1
  end
end
class NewReleasePrice
  def charge(days_rented)
    days_rented * 3
  end

  def frequent_renter_points(days_rented)
    days_rented > 1 ? 2 : 1
  end
end
class ChildrensPrice
  def charge(days_rented)
    result = 1.5
    result += (days_rented - 3) * 1.5 if days_rented > 3
    result
  end

  def frequent_renter_points(days_rented)
    1
  end
end


class Rental
  attr_reader :movie, :days_rented

  def initialize(movie, days_rented)
    @movie, @days_rented = movie, days_rented
  end


  def frequent_renter_points
    movie.frequent_renter_points(days_rented)
  end

  def charge
    movie.charge(days_rented)
  end
end
