Gem::Specification.new do |s|
  s.name        = 'pleasant_grove'
  s.version     = '0.0.8'
  s.date        = '2020-08-20'
  s.summary     = "PostgreSQL helpers"
  s.description = "Classes for representing PostgreSQL tables, columns, and query results"
  s.authors     = ["Thom Boyer"]
  s.email       = 'thom@boyers.org'
  s.files       = ["lib/pleasant_grove.rb",
                   "lib/pleasant_grove/result.rb",
                   "lib/pleasant_grove/column.rb",
                   "lib/pleasant_grove/table.rb"]
  s.homepage    = 'https://rubygems.org/gems/pleasant_grove'
  s.license     = 'MIT'

  s.add_runtime_dependency "pg", ["~> 1.2"]
  s.add_runtime_dependency "elastic_tabstops", ["~> 0.1"]
end
