require "test/unit"
require_relative "../lib/ch01"

class CustomerTest < Test::Unit::TestCase
  def setup
    @customer = Customer.new("John Doe")
    @movie = Movie.new("Gone with the Wind", Movie::REGULAR)
    @rental = Rental.new(@movie, 3)
    @customer.add_rental(@rental)
  end

  def test_statement
    expected_statement =
      "Rental Record for John Doe\n\tGone with the Wind\t3.5\nAmount owed is 3.5\nYou earned 1 frequent renter points"
    assert_equal(expected_statement, @customer.statement)
  end
end
