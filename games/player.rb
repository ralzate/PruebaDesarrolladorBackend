class Player
  include Mongoid::Document

  field :c, type: Hash, default: {}
  field :fk, type: String
  field :t, type: Float

  index({ fk: 1 }, unique: 1)

  def record(game, count = 1, date = Time.current)
    inc = {
      :"c.y#{date.year}.m#{date.month}.d#{date.day}.#{game}" => count,
      :"c.y#{date.year}.m#{date.month}.#{game}" => count,
      :"c.y#{date.year}.#{game}" => count,
      :"c.t.#{game}" => count,
      :t => count
    }

    self.class.collection.find('_id' => id).update_one({ :$inc => inc }, upsert: true)
  end

  def count(game, deep = 'd', date = Time.current)
    return 0 if c.blank?
    return (c['t'] || {})[game].to_i if deep == 't'

    y = c["y#{date.year}"]
    return 0 unless y

    m = y["m#{date.month}"]
    return y[game].to_i if deep == 'y'

    return 0 unless m
    return m[game].to_i if deep == 'm'

    d = m["d#{date.day}"]
    return d[game].to_i
  end
end
