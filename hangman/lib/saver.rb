class Saver

  attr_reader :game, :path, :file, :saves, :current_save
  attr_accessor :id, :time, :game_state

  def initialize(current_match)
    @game = current_match
    @saves = get_saves 
    @game_state ||= {}
  end

  def save
    @current_save = {
      id: generate_id,
      time: Time.now.getutc.to_i,
      state: get_game_state
    }
    @file = File.open(($save_path + @current_save[:time].to_s + "_hangman_save.json"), "w") do |f|
      f.write(JSON.dump(@current_save))
    end
  end

  def load(id)
    @saves.each do |save|
      return save if save[:id] == id.to_i
    end
  end

  def get_game_state
    game_state = {}
    game_state[:word] = @game.word
    game_state[:current_turn] = @game.current_turn
    game_state[:player_guesses] = @game.player_guesses
    @game_state = game_state
  end

  def generate_id
    id = 0
    @saves.each do |save|
      id = save[:id] unless id > save[:id]
    end
    id + 1
  end

  def get_saves
    saves = []

    # select and load every file in the save directory
    Dir.foreach($save_path) do |item|
      next if item == '.' or item == '..' or item == '.DS_Store'
      tmp_file = File.open($save_path + item, "r")
      saves << JSON.load(tmp_file)
    end
    
    # convert hash keys into symbols
    saves.each_with_index do |save, index|
      saves[index] = symbolize_keys(save)
    end

    @saves = saves  
  end

  def symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
      new_key = case key
                when String then key.to_sym
                else key
                end
      new_value = case value
                  when Hash then symbolize_keys(value)
                  else value
                  end
      result[new_key] = new_value
      result
    }
  end

end