module Lexicon  
  
  @lexicon = [
    ['direction', 'north', 'south', 'east', 'west',
     'down', 'up', 'left', 'right', 'back'],
    ['verb', 'go', 'stop', 'kill', 'eat', 'place', 'throw', 'shoot', 'dodge', 'tell'],
    ['stop', 'the', 'in', 'of', 'from', 'at', 'it'],
    ['noun', 'door', 'bear', 'princess', 'cabinet', 'joke', 'bomb', 'them', 'enemy']
  ]
       
  def Lexicon.scan(stuff)
    result = []
    words = stuff.split
    words.each do |word|
      begin  
        word = Integer(word)
        result.push(['number', word])
      rescue      
        if @lexicon[0].include?(word.downcase)          
          word.downcase!
          result.push([@lexicon[0][0], word])
        elsif @lexicon[1].include?(word.downcase)
          word.downcase!
          result.push([@lexicon[1][0], word])
        elsif @lexicon[2].include?(word.downcase)
          word.downcase!
          result.push([@lexicon[2][0], word])
        elsif @lexicon[3].include?(word.downcase)
          word.downcase!
          result.push([@lexicon[3][0], word])
        else
          result.push(['error', word])
        end
      end
    end  
    return result 
  end
end
