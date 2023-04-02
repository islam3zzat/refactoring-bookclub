require "minitest"
require "minitest/autorun"
require_relative "../lib/ch01"

describe Customer do
  subject { Customer.new("Smith") }
  let(:rent) do
    lambda { |movie, days| subject.add_rental(Rental.new(movie, days)) }
  end
  let(:regular_movie) { Movie.new "Regent", RegularPrice.new }
  let(:new_movie) { Movie.new "Newton", NewReleasePrice.new }
  let(:childrens_movie) { Movie.new "Chills", ChildrensPrice.new }

  it "has a name" do
    assert_equal "Smith", subject.name
  end

  it "keeps a record of rentals" do
    rent[:movie1, 2]
    rent[:movie2, 7]

    assert_equal 2, subject.rentals.length
    assert_equal :movie1, subject.rentals[0].movie
    assert_equal :movie2, subject.rentals[1].movie
  end

  describe "#statement" do
    it "outputs a String" do
      assert_instance_of String, subject.statement
    end

    it "includes a header line with the customer’s name" do
      assert_includes subject.statement, "Rental Record for Smith"
    end

    describe "rental costs for 1 day" do
      before do
        rent[regular_movie, 1]
        rent[new_movie, 1]
        rent[childrens_movie, 1]
      end

      it "includes movie title and fee for each rented movie" do
        s = subject.statement
        assert_match /^\tRegent\t2$/, s
        assert_match /^\tNewton\t3$/, s
        assert_match /^\tChills\t1\.5$/, s
      end

      it "includes the total fee for all rentals" do
        assert_includes subject.statement, "Amount owed is 6.5"
      end

      it "includes frequent renter points earned" do
        assert_includes subject.statement, "You earned 3 frequent renter points"
      end
    end

    describe "frequent renter points" do
      it "bonus point for each new release movie rented for 2 or more days" do
        rent[new_movie, 1]
        rent[new_movie, 2] # <-- bonus point
        rent[regular_movie, 3]
        assert_includes subject.statement, "You earned 4 frequent renter points"
      end
    end

    describe "regular movie, more than two days" do
      it "costs 2 dollars plus 1.5 dollars for each additional day" do
        rent[regular_movie, 4]
        assert_match /^\tRegent\t#{2 + 1.5 * 2}$/, subject.statement
      end
    end

    describe "childrens movie, more than three days" do
      it "costs 1.5 dollars plus 1.5 dollars for each additional day" do
        rent[childrens_movie, 6]
        assert_match /^\tChills\t#{1.5 + 1.5 * 3}$/, subject.statement
      end
    end

    describe "complete example with different numbers" do
      it "prints the statement as expected" do
        #                          fee     points
        # =======================================
        rent[regular_movie, 2] # 2       1
        rent[regular_movie, 3] # 3.5     1
        rent[new_movie, 1] # 3       1
        rent[new_movie, 3] # 9       2
        rent[childrens_movie, 3] # 1.5     1
        rent[childrens_movie, 4] # 3       1
        # =======================================
        #              total:      22.0    7

        expected = <<~STATEMENT.chomp
          Rental Record for Smith
          \tRegent\t2
          \tRegent\t3.5
          \tNewton\t3
          \tNewton\t9
          \tChills\t1.5
          \tChills\t3.0
          Amount owed is 22.0
          You earned 7 frequent renter points
        STATEMENT
        assert_equal expected, subject.statement
      end
    end
  end

  describe "#html_statement" do
    it "outputs a String" do
      assert_instance_of String, subject.html_statement
    end

    it "includes a header line with the customer’s name" do
      assert_includes subject.html_statement,
                      "<h1>Rental Record for <em>Smith</em>\n</h1>"
    end

    describe "rental costs for 1 day" do
      before do
        rent[regular_movie, 1]
        rent[new_movie, 1]
        rent[childrens_movie, 1]
      end

      it "includes movie title and fee for each rented movie" do
        s = subject.html_statement
        assert_match %r{^\tRegent\t2<br />$}, s
        assert_match %r{^\tNewton\t3<br />$}, s
        assert_match %r{^\tChills\t1\.5<br />$}, s
      end

      it "includes the total fee for all rentals" do
        assert_includes subject.html_statement,
                        "<p>Amount owed is <em>6.5</em></p>\n"
      end

      it "includes frequent renter points earned" do
        assert_includes subject.html_statement,
                        "You earned <em>3</em> frequent renter points"
      end
    end

    describe "frequent renter points" do
      it "bonus point for each new release movie rented for 2 or more days" do
        rent[new_movie, 1]
        rent[new_movie, 2] # <-- bonus point
        rent[regular_movie, 3]
        assert_includes subject.html_statement,
                        "You earned <em>4</em> frequent renter points"
      end
    end

    describe "regular movie, more than two days" do
      it "costs 2 dollars plus 1.5 dollars for each additional day" do
        rent[regular_movie, 4]
        assert_match %r{^\tRegent\t#{2 + 1.5 * 2}<br />$},
                     subject.html_statement
      end
    end

    describe "childrens movie, more than three days" do
      it "costs 1.5 dollars plus 1.5 dollars for each additional day" do
        rent[childrens_movie, 6]
        assert_match %r{^\tChills\t#{1.5 + 1.5 * 3}<br />$},
                     subject.html_statement
      end
    end

    describe "complete example with different numbers" do
      it "prints the statement as expected" do
        #                          fee     points
        # =======================================
        rent[regular_movie, 2] # 2       1
        rent[regular_movie, 3] # 3.5     1
        rent[new_movie, 1] # 3       1
        rent[new_movie, 3] # 9       2
        rent[childrens_movie, 3] # 1.5     1
        rent[childrens_movie, 4] # 3       1
        # =======================================
        #              total:      22.0    7

        expected = <<~STATEMENT.chomp
          <h1>Rental Record for <em>Smith</em>\n</h1>
          \tRegent\t2<br />
          \tRegent\t3.5<br />
          \tNewton\t3<br />
          \tNewton\t9<br />
          \tChills\t1.5<br />
          \tChills\t3.0<br />
          <p>Amount owed is <em>22.0</em></p>
          You earned <em>7</em> frequent renter points
        STATEMENT
        assert_equal expected, subject.html_statement
      end
    end
  end
end

describe Rental do
  subject { Rental.new(:movie, 5) }

  it "remembers a movie" do
    assert_equal :movie, subject.movie
  end

  it "remembers the number of days" do
    assert_equal 5, subject.days_rented
  end
end
