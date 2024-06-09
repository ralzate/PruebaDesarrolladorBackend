module Games
  class HangmanConfig
    include Mongoid::Document
    field :f, type: Float, default: 1.0
    field :dl, type: Float, default: 0.0 # daily limit
  end
end
