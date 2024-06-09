module Panel
  class Api < Sinatra::Base
    set(:require_json_web_token) do |_token_is_required|
      condition do
        token = request.env['HTTP_AUTH_TOKEN']
        unless JwtHelper.valid_token?(token)
          halt 401, Oj.dump(success: false, error: 'Invalid token.')
        end
      end
    end

    post '/panel/authenticate' do
      if params[:username].blank? || params[:password].blank?
        return Oj.dump(success: false, error: 'Username and Password are required.')
      end

      user = User.authenticate(params[:username], params[:password])
      return Oj.dump(success: false, error: 'Username or Password incorrect.') unless user

      user_info = {
        user_id: user.id.to_s,
        username: user.nick
      }

      token = JwtHelper.generate_token(user_info)
      return Oj.dump(token: token, success: true)
    end

    get '/panel/hangman/words', require_json_web_token: true do
      return Oj.dump(Games::Word.all.map(&:as_json))
    end

    get '/panel/hangman', require_json_web_token: true do
      hc = Games::HangmanConfig.first
      hc = Games::HangmanConfig.create unless hc

      return Oj.dump(
        dl: hc.dl,
        f: hc.f
      )
    end

    post '/panel/hangman', require_json_web_token: true do
      hc = Games::HangmanConfig.first
      hc = Games::HangmanConfig.create unless hc

      hc.set(dl: params[:dl].to_f) if params[:dl]

      return Oj.dump(
        success: true
      )
    end

    post '/panel/hangman/words', require_json_web_token: true do
      word = Games::Word.new(
        c: params['c'],
        h: params['h']
      )

      if word.save
        return Oj.dump(
          success: true,
          object: word.as_json,
          message: "'#{word.c}' ya esta disponible para los jugadores"
        )
      else
        return Oj.dump(success: false, error: "No pudo guardar '#{word.c}'")
      end
    end

    delete '/panel/hangman/words/:id', require_json_web_token: true do
      word = Games::Word.find(params[:id])

      if word.delete
        return Oj.dump(
          success: true,
          message: "Se ah borrado '#{word.c}'"
        )
      else
        return Oj.dump(success: false, error: "No pudo borrar' #{word.c}'")
      end
    end

    post '/panel/numeric_puzzle/start' do
      size = params[:size].to_i
      puzzle = Games::NumericPuzzle.create(size: size, board: generate_board(size))
      Oj.dump(success: true, puzzle_id: puzzle.id)
    end

    post '/panel/numeric_puzzle/move' do
      puzzle = Games::NumericPuzzle.find(params[:puzzle_id])
      row = params[:row].to_i
      col = params[:col].to_i

      if puzzle.valid_move?(row, col)
        puzzle.make_move(row, col)
        if puzzle.solved?
          Oj.dump(success: true, message: 'Juego completado', board: puzzle.board)
        else
          Oj.dump(success: true, message: 'Movimiento exitoso', board: puzzle.board)
        end
      else
        Oj.dump(success: false, error: 'Movimiento inválido')
      end
    end

    get '/panel/numeric_puzzle/status' do
      puzzle = Games::NumericPuzzle.find(params[:puzzle_id])
      Oj.dump(board: puzzle.board, solved: puzzle.solved?)
    end

    private

    def generate_board(size)
      numbers = (1..size**2 - 1).to_a.shuffle  
      numbers << nil  

      board = []
      numbers.each_slice(size) do |row|
        board << row
      end

      board
    end
  end
end
