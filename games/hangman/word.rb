module Games
  class Word
    include Mongoid::Document
    include MongoidExt::Random
    field :c, type: String # content
    field :h, type: String # hint

    index({ c: 1 }, unique: true)

    def as_json(options = {})
      json = super(options)
      json['_id'] = id.to_s
      json
    end
  end
end
