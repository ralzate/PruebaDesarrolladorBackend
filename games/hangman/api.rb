module Games
  class HangmanApi < Sinatra::Base
    get '/hangman/:pid' do
      @game = Hangman.where(pid: params[:pid]).first
      player = Player.where(fk: params[:pid]).first
      player = Player.create!(fk: params[:pid]) unless player

      if @game.nil?
        player.record('hangman')
        if hangman.dl.nonzero? && player.count('hangman') >= hangman.dl
          return Oj.dump(
            state: 'overlimit'
          )
        end

        word = Word.random
        @game = Hangman.new(
          pid: params[:pid]
        )
        @game.word = word
        @game.save!
      elsif @game.state != 'playing'
        player.record('hangman')
        if hangman.nonzero? && player.count('hangman') >= hangman.dl
          return Oj.dump(
            state: 'overlimit'
          )
        end
        @game.start
        @game.save
      end

      hint = @game.should_provide_hint? ? @game.h : nil

      Oj.dump(
        word: @game.c,
        hint: hint,
        attempts: @game.a.to_a,
        chances: 8 - @game.f,
        win: false,
        failures: @game.f
      )
    end

    get '/hangman/:pid/try/:letter' do
      @game = Hangman.where(pid: params[:pid]).first
      ok = @game.try(params[:letter][0])
      r = Oj.dump(
        word: @game.c,
        attempts: @game.a.to_a,
        success: ok,
        state: @game.state,
        chances: 8 - @game.f,
        failures: @game.f
      )

      if @game.state != 'playing'
        if @game.win?
          points = ((8 - @game.f) * hangman.f.to_f).round
          Superlikers.new.record('hangman', @game.pid, 'chances' => points)
        end
      end
      r
    end

    def hangman
      @hangman ||= Games::HangmanConfig.first || Games::HangmanConfig.create
    end
  end
end
