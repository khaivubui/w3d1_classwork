# == Schema Information
#
# Table name: countries
#
#  name        :string       not null, primary key
#  continent   :string
#  area        :integer
#  population  :integer
#  gdp         :integer

require_relative './sqlzoo.rb'

# BONUS QUESTIONS: These problems require knowledge of aggregate
# functions. Attempt them after completing section 05.

def highest_gdp
  # Which countries have a GDP greater than every country in Europe? (Give the
  # name only. Some countries may have NULL gdp values)
  execute(<<-SQL)
    SELECT name
    FROM countries
    WHERE gdp > (
      SELECT MAX(gdp)
      FROM countries
      WHERE continent = 'Europe'
    )
  SQL
end

def largest_in_continent
  # Find the largest country (by area) in each continent. Show the continent,
  # name, and area.
  execute(<<-SQL)
    SELECT countries.continent, countries.name, max_area_per_continent.max_area
    FROM countries
    JOIN (
      SELECT continent, MAX(area) AS max_area
      FROM countries
      GROUP BY continent
    ) AS max_area_per_continent
    ON countries.area = max_area_per_continent.max_area
  SQL
end

def large_neighbors
  # Some countries have populations more than three times that of any of their
  # neighbors (in the same continent). Give the countries and continents.
  execute(<<-SQL)
    SELECT countries.name, countries.continent
    FROM countries
    JOIN (
      SELECT countries.continent, MAX(countries.population) as second_max
      FROM countries
      JOIN (
        SELECT continent, MAX(population) as max_population
        FROM countries
        GROUP BY continent
      ) AS max_population
      ON max_population.continent = countries.continent
      WHERE countries.population < max_population.max_population
      GROUP BY countries.continent
    )
    AS second_max_pop
    ON second_max_pop.continent = countries.continent
    WHERE countries.population > (second_max_pop.second_max * 3)
  SQL
end
