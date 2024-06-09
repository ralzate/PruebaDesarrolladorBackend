module Games
  class NumericPuzzle
    include Mongoid::Document

    field :size, type: Integer
    field :board, type: Array

  end
end