--for Lua 5.4
--Whether moving a Pawn and its Square sideways counts as a Pawn Move for the 50-Move rule and 75-Move rule is to be determined (it seems that it does).
--It is currently assumed that a Pawn can only Promote when moving forward, not when moving it and its Square sideways. This is subject to change.
--Pawn Promotions are currently assumed to be compulsory.
--It is currently assumed that the arrangement of existing versus Void Squares within the 7x9 area must be the same for a repetition of Position to be considered.
--It is currently assumed that permutations of existing Squares are not counted as different in terms of a repetition of Position
print("NOTE: Draws by agreement, Draws by Dead Position, and Resignations are not handled by this program.")
print("If any occur, simply close the program and notify your Opponent.")
print("Resignations and Draws by Agreement follow the same rules as in regular chess.")
print("NOTE: Time control is not supported.")
print("NOTE: You must complete a Move once the game asks which Piece you want to Move!")
print("If you want to Claim a Draw, do that when it asks!")
print("NOTE: Castling is considered a King Move.")
print("To Castle, when asked, enter the King's starting Square and, when asked, the Square you want it to end up on, and the Rook will be moved automatically.")
print("NOTE: Extremely long games may break due to the limit on table length. However, this should never actually be an issue.")
piece_symbols_white={King="K",Voidrider="V",Rook="R",Knight="N",Bishop="B",Pawn="P"}
piece_symbols_black={King="k",Voidrider="v",Rook="r",Knight="n",Bishop="b",Pawn="p"}
files={"a","b","c","d","e","f","g"}
other_players_piece_lists_index={White="black_pieces",Black="white_pieces"}
function new_piece(file,rank,type,color)
 local piece={}
 piece.file=file
 piece.rank=rank
 piece.type=type
 piece.color=color
 return piece
end
function piece_on_square(board,file,rank)
 for piece_number,piece in ipairs(board.white_pieces) do
  if piece.file==file and piece.rank==rank then
   return piece
  end
 end
 for piece_number,piece in ipairs(board.black_pieces) do
  if piece.file==file and piece.rank==rank then
   return piece
  end
 end
 return nil
end
function print_board(board)
 --[[prints Board in the following form:
 Board:
 
 ^v^^^v^
 rnbkbnr
 ^ppppp^
 ^     ^
 ^     ^
 ^     ^
 ^PPPPP^
 RNBKBNR
 ^V^^^V^
 
 --]]
 print("Board:")
 print("")
 for rank=9,1,-1 do
  for file_number_from_a_file,file in ipairs(files) do
   if board[file][rank]=="v" then
    io.write("^")
   else
    local piece_found=false
    for piece_number,piece in ipairs(board.white_pieces) do
     if piece.file==file and piece.rank==rank then
      io.write(piece_symbols_white[piece.type])
      piece_found=true
     end
    end
    for piece_number,piece in ipairs(board.black_pieces) do
     if piece.file==file and piece.rank==rank then
      io.write(piece_symbols_black[piece.type])
      piece_found=true
     end
    end
    if piece_found==false then
     io.write(" ")
    end
   end
  end
  io.write("\n")
 end
 print("")
end
function voidrider_can_ride_through(board,voidrider,file,rank,direction)
 --returns true if the Voidrider can voidride through the Square
 --returns false otherwise
 --should only be called with a Voidrider and a Square in the 7x9 area that is in the correct direction from the Voidrider assuming north is the direction Rank numbers increase
 if board[file][rank]~="v" then
  return false
 end
 if direction=="north" then
  if rank-voidrider.rank==1 then
   return true
  elseif voidrider_can_ride_through(board,voidrider,file,rank-1,"north") then
   return true
  else
   return false
  end
 end
 if direction=="northeast" then
  if rank-voidrider.rank==1 then
   return true
  elseif voidrider_can_ride_through(board,voidrider,utf8.char(utf8.codepoint(file)-1),rank-1,"northeast") then
   return true
  else
   return false
  end
 end
 if direction=="east" then
  if utf8.codepoint(file)-utf8.codepoint(voidrider.file)==1 then
   return true
  elseif voidrider_can_ride_through(board,voidrider,utf8.char(utf8.codepoint(file)-1),rank,"east") then
   return true
  else
   return false
  end
 end
 if direction=="southeast" then
  if utf8.codepoint(file)-utf8.codepoint(voidrider.file)==1 then
   return true
  elseif voidrider_can_ride_through(board,voidrider,utf8.char(utf8.codepoint(file)-1),rank+1,"southeast") then
   return true
  else
   return false
  end
 end
 if direction=="south" then
  if voidrider.rank-rank==1 then
   return true
  elseif voidrider_can_ride_through(board,voidrider,file,rank+1,"south") then
   return true
  else
   return false
  end
 end
 if direction=="southwest" then
  if voidrider.rank-rank==1 then
   return true
  elseif voidrider_can_ride_through(board,voidrider,utf8.char(utf8.codepoint(file)+1),rank+1,"southwest") then
   return true
  else
   return false
  end
 end
 if direction=="west" then
  if utf8.codepoint(voidrider.file)-utf8.codepoint(file)==1 then
   return true
  elseif voidrider_can_ride_through(board,voidrider,utf8.char(utf8.codepoint(file)+1),rank,"west") then
   return true
  else
   return false
  end
 end
 if direction=="northwest" then
  if utf8.codepoint(voidrider.file)-utf8.codepoint(file)==1 then
   return true
  elseif voidrider_can_ride_through(board,voidrider,utf8.char(utf8.codepoint(file)+1),rank-1,"northwest") then
   return true
  else
   return false
  end
 end
end
function piece_is_attacking_square(board,piece,file,rank)
 --returns true if the Piece is attacking the Square
 --returns false otherwise
 --should only be called for Squares in the 7x9 area
 if piece_on_square(board,file,rank)~=nil and piece.color==piece_on_square(board,file,rank).color then --filters out attacks on Pieces of the same color
  return false
 end
 if board[file][rank]=="v" then --filters out attacks on Void Squares
  return false
 end
 if piece.type=="King" then
  --code for if the King is attacking
  if (utf8.codepoint(file)-utf8.codepoint(piece.file))^2+(rank-piece.rank)^2==1 or (utf8.codepoint(file)-utf8.codepoint(piece.file))^2+(rank-piece.rank)^2==2 then
   return true
  else
   return false
  end
 elseif piece.type=="Voidrider" then
  --code for if the Voidrider is attacking
  if rank==piece.rank and utf8.codepoint(file)>utf8.codepoint(piece.file) then
   --code for if the Voidrider is White and attacking to the right or Black and attacking to the left
   if utf8.codepoint(file)-utf8.codepoint(piece.file)==1 then
    return true
   elseif voidrider_can_ride_through(board,piece,utf8.char(utf8.codepoint(file)-1),rank,"east") then
    return true
   else
    return false
   end
  elseif rank==piece.rank and utf8.codepoint(file)<utf8.codepoint(piece.file) then
   --code for if the Voidrider is Black and attacking to the right or White and attacking to the left
   if utf8.codepoint(piece.file)-utf8.codepoint(file)==1 then
    return true
   elseif voidrider_can_ride_through(board,piece,utf8.char(utf8.codepoint(file)+1),rank,"west") then
    return true
   else
    return false
   end
  elseif file==piece.file and rank>piece.rank then
   --code for if the Voidrider is White and attacking forwards or Black and attacking backwards
   if rank-piece.rank==1 then
    return true
   elseif voidrider_can_ride_through(board,piece,file,rank-1,"north") then
    return true
   else
    return false
   end
  elseif file==piece.file and rank<piece.rank then
   --code for if the Voidrider is Black and attacking forwards or White and attacking backwards
   if piece.rank-rank==1 then
    return true
   elseif voidrider_can_ride_through(board,piece,file,rank+1,"south") then
    return true
   else
    return false
   end
  elseif utf8.codepoint(file)-utf8.codepoint(piece.file)==rank-piece.rank and rank>piece.rank then
   --code for if the Voidrider is White and attacking forwards and to the right or Black and attacking backwards and to the left
   if rank-piece.rank==1 then
    return true
   elseif voidrider_can_ride_through(board,piece,utf8.char(utf8.codepoint(file)-1),rank-1,"northeast") then
    return true
   else
    return false
   end
  elseif utf8.codepoint(file)-utf8.codepoint(piece.file)==rank-piece.rank and rank<piece.rank then
   --code for if the Voidrider is Black and attacking forwards and to the right or White and attacking backwards and to the left
   if piece.rank-rank==1 then
    return true
   elseif voidrider_can_ride_through(board,piece,utf8.char(utf8.codepoint(file)+1),rank+1,"southwest") then
    return true
   else
    return false
   end
  elseif utf8.codepoint(file)-utf8.codepoint(piece.file)==-(rank-piece.rank) and rank>piece.rank then
   --code for if the Voidrider is White and attacking forwards and to the left or Black and attacking backwards and to the right
   if rank-piece.rank==1 then
    return true
   elseif voidrider_can_ride_through(board,piece,utf8.char(utf8.codepoint(file)+1),rank-1,"northwest") then
    return true
   else
    return false
   end
  elseif utf8.codepoint(file)-utf8.codepoint(piece.file)==-(rank-piece.rank) and rank<piece.rank then
   --code for if the Voidrider is Black and attacking forwards and to the left or White and attacking backwards and to the right
   if piece.rank-rank==1 then
    return true
   elseif voidrider_can_ride_through(board,piece,utf8.char(utf8.codepoint(file)-1),rank+1,"southeast") then
    return true
   else
    return false
   end
  end
 elseif piece.type=="Rook" then
  --code for if the Rook is attacking
  if rank==piece.rank then
   --code for if the Rook is attacking a Square horizontally
   if utf8.codepoint(file)>utf8.codepoint(piece.file) then
    --code for if the Rook is attacking a Square closer to the g-File than it
    if utf8.codepoint(file)-utf8.codepoint(piece.file)==1 then
     return true
    elseif piece_on_square(board,utf8.char(utf8.codepoint(file)-1),rank)==nil and piece_is_attacking_square(board,piece,utf8.char(utf8.codepoint(file)-1),rank) then
     return true
    else
     return false
    end
   else
    --code for if the Rook is attacking a Square closer to the a-File than it
    if utf8.codepoint(piece.file)-utf8.codepoint(file)==1 then
     return true
    elseif piece_on_square(board,utf8.char(utf8.codepoint(file)+1),rank)==nil and piece_is_attacking_square(board,piece,utf8.char(utf8.codepoint(file)+1),rank) then
     return true
    else
     return false
    end
   end
  elseif file==piece.file then
   --code for if the Rook is attacking a Square vertically
   if rank>piece.rank then
    --code for if the Rook is attacking a Square closer to Black's starting side than it
    if rank-piece.rank==1 then
     return true
    elseif piece_on_square(board,file,rank-1)==nil and piece_is_attacking_square(board,piece,file,rank-1) then
     return true
    else
     return false
    end
   else
    --code for if the Rook is attacking a Square closer to White's starting side than it
    if piece.rank-rank==1 then
     return true
    elseif piece_on_square(board,file,rank+1)==nil and piece_is_attacking_square(board,piece,file,rank+1) then
     return true
    else
     return false
    end
   end
  else
   return false
  end
 elseif piece.type=="Knight" then
  --code for if the Knight is attacking
  if (utf8.codepoint(file)-utf8.codepoint(piece.file))^2+(rank-piece.rank)^2==5 then
   return true
  else
   return false
  end
 elseif piece.type=="Bishop" then
  --code for if the Bishop is attacking
  if utf8.codepoint(file)-utf8.codepoint(piece.file)==rank-piece.rank then
   --code for if the Bishop is attacking forwards and to the right or backwards and to the left
   if rank>piece.rank then
    --code for if the Bishop is White and attacking forwards and to the right or Black and attacking backwards and to the left
    if rank-piece.rank==1 then
     return true
    elseif piece_on_square(board,utf8.char(utf8.codepoint(file)-1),rank-1)==nil and piece_is_attacking_square(board,piece,utf8.char(utf8.codepoint(file)-1),rank-1) then
     return true
    else
     return false
    end
   else
    --code for if the Bishop is Black and attacking forwards and to the right or White and attacking backwards and to the left
    if piece.rank-rank==1 then
     return true
    elseif piece_on_square(board,utf8.char(utf8.codepoint(file)+1),rank+1)==nil and piece_is_attacking_square(board,piece,utf8.char(utf8.codepoint(file)+1),rank+1) then
     return true
    else
     return false
    end
   end
  elseif utf8.codepoint(file)-utf8.codepoint(piece.file)==-(rank-piece.rank) then
   --code for if the Bishop is attacking forwards and to the left or backwards and to the right
   if rank>piece.rank then
    --code for if the Bishop is White and attacking forwards and to the left or Black and attacking backwards and to the right
    if rank-piece.rank==1 then
     return true
    elseif piece_on_square(board,utf8.char(utf8.codepoint(file)+1),rank-1)==nil and piece_is_attacking_square(board,piece,utf8.char(utf8.codepoint(file)+1),rank-1) then
     return true
    else
     return false
    end
   else
    --code for if the Bishop is Black and attacking forward and to the left or White and attacking backwards and to the right
    if piece.rank-rank==1 then
     return true
    elseif piece_on_square(board,utf8.char(utf8.codepoint(file)-1),rank+1)==nil and piece_is_attacking_square(board,piece,utf8.char(utf8.codepoint(file)-1),rank+1) then
     return true
    else
     return false
    end
   end --END
  else
   return false
  end
 else
  --code for if the Pawn is attacking
  if piece.color=="White" then
   if piece.rank+1==rank and (utf8.codepoint(file)-utf8.codepoint(piece.file))^2==1 then
    return true
   else
    return false
   end
  else
   if piece.rank-1==rank and (utf8.codepoint(file)-utf8.codepoint(piece.file))^2==1 then
    return true
   else
    return false
   end
  end
 end
end
function get_attackers(board,file,rank)
 --returns list of attackers of that Square
 --leaves out Pieces of the same color as the Piece on that Square if there is one
 --returns empty table if the Square is Void
 local attacker_list={}
 if board[file][rank]=="v" then
 elseif piece_on_square(board,file,rank)==nil then
  for piece_number,piece in ipairs(board.white_pieces) do
   if piece_is_attacking_square(board,piece,file,rank) then
    attacker_list[#attacker_list+1]=piece
   end
  end
  for piece_number,piece in ipairs(board.black_pieces) do
   if piece_is_attacking_square(board,piece,file,rank) then
    attacker_list[#attacker_list+1]=piece
   end
  end
 elseif piece_on_square(board,file,rank).color=="White" then
  for piece_number,piece in ipairs(board.black_pieces) do
   if piece_is_attacking_square(board,piece,file,rank) then
    attacker_list[#attacker_list+1]=piece
   end
  end
 else
  for piece_number,piece in ipairs(board.white_pieces) do
   if piece_is_attacking_square(board,piece,file,rank) then
    attacker_list[#attacker_list+1]=piece
   end
  end
 end
 return attacker_list
end
function move_is_physically_possible(board,starting_square,ending_square,player)
 --returns whether the Move is "physically possible"
 --takes all Castling restrictions into account for a Castling move except the restriction of not Castling into Check
 --at the time of function call, both starting_square and ending_square should refer to Squares in the 7x9 area, and starting_square contains a Piece belonging to the current Player
 if ending_square==starting_square then --filters out attempts to Move a Piece to the Square it's already on
  return false
 end
 local starting_file=string.sub(starting_square,1,1)
 local starting_rank=tonumber(string.sub(starting_square,2,2))
 local ending_file=string.sub(ending_square,1,1)
 local ending_rank=tonumber(string.sub(ending_square,2,2))
 local moving_piece=piece_on_square(board,starting_file,starting_rank)
 local wrong_change_in_rank_for_pawns=-1
 if player=="Black" then
  wrong_change_in_rank_for_pawns=1
 end
 if board[ending_file][ending_rank]=="v" then
  --the Piece is trying to Move to a Void Square
  board_copy=copy_board(board)
  board_copy[starting_file][starting_rank]="v"
  board_copy[ending_file][ending_rank]=" "
  if board_copy[ending_file][ending_rank+1]~=" " and board_copy[ending_file][ending_rank-1]~=" " and (board_copy[utf8.char(utf8.codepoint(ending_file)-1)]==nil or board_copy[utf8.char(utf8.codepoint(ending_file)-1)][ending_rank]=="v") and (board_copy[utf8.char(utf8.codepoint(ending_file)+1)]==nil or board_copy[utf8.char(utf8.codepoint(ending_file)+1)][ending_rank]=="v") then
   return false
  end
  if moving_piece.type=="Voidrider" then
   --it is a Voidrider trying to Move
   if ending_file==starting_file and ending_rank>starting_rank then
    if voidrider_can_ride_through(board,moving_piece,ending_file,ending_rank,"north") then
     return true
    else
     return false
    end
   elseif ending_file==starting_file and ending_rank<starting_rank then
    if voidrider_can_ride_through(board,moving_piece,ending_file,ending_rank,"south") then
     return true
    else
     return false
    end
   elseif ending_rank==starting_rank and utf8.codepoint(ending_file)<utf8.codepoint(starting_file) then
    if voidrider_can_ride_through(board,moving_piece,ending_file,ending_rank,"west") then
     return true
    else
     return false
    end
   elseif ending_rank==starting_rank and utf8.codepoint(ending_file)>utf8.codepoint(starting_file) then
    if voidrider_can_ride_through(board,moving_piece,ending_file,ending_rank,"east") then
     return true
    else
     return false
    end
   else
    return false
   end
  elseif moving_piece.type=="Pawn" then
   --it is a Pawn trying to Move
   if (utf8.codepoint(ending_file)-utf8.codepoint(starting_file))^2+(ending_rank-starting_rank)^2==1 and ending_rank-starting_rank==wrong_change_in_rank_for_pawns then
    return false
   else
    return true
   end
  else
   --it is neither a Pawn nor a Voidrider trying to Move
   if (utf8.codepoint(ending_file)-utf8.codepoint(starting_file))^2+(ending_rank-starting_rank)^2==1 then
    return true
   else
    return false
   end
  end
 else
  --the Piece is trying to Move to an existing Square
  if moving_piece.type=="Pawn" then
   --it is a Pawn trying to Move
   if starting_file==ending_file and ending_rank-starting_rank==-wrong_change_in_rank_for_pawns then
    --the Pawn is trying to Move 1 Square straight forwards
    if piece_on_square(board,ending_file,ending_rank)~=nil then
     return false
    else
     return true
    end
   elseif (utf8.codepoint(ending_file)-utf8.codepoint(starting_file))^2==1 and ending_rank-starting_rank==-wrong_change_in_rank_for_pawns then
    --the Pawn is trying to Move 1 Square diagonally forwards
    if piece_is_attacking_square(board,moving_piece,ending_file,ending_rank) and piece_on_square(board,ending_file,ending_rank)~=nil then
     return true
    else
     return false
    end
   else
    return false
   end
  else
   --it is not a Pawn trying to Move
   if piece_is_attacking_square(board,moving_piece,ending_file,ending_rank) then
    return true
   else
    if moving_piece.type~="King" or starting_file~="d" then
     return false
    else
     if player=="White" and starting_square=="d2" and (ending_square=="b2" or ending_square=="f2") then
      --White is trying to Castle
      if ending_square=="b2" then
       --White is trying to Castle to the left
       local in_between_square_is_attacked_by_enemy=false
       for attacker_number,attacker in ipairs(get_attackers(board,"c",2)) do
        if attacker.color=="Black" then
         in_between_square_is_attacked_by_enemy=true
        end
       end
       if in_between_square_is_attacked_by_enemy then
        return false
       elseif board.c[2]=="v" then
        return false
       elseif piece_on_square(board,"c",2)~=nil then
        return false
       elseif piece_on_square(board,"b",2)~=nil then
        return false
       elseif board.white_left_castling~=true then
        return false
       elseif #get_attackers(board,"d",2)~=0 then
        return false
       else
        return true
       end
      else
       --White is trying to Castle to the right
       local in_between_square_is_attacked_by_enemy=false
       for attacker_number,attacker in ipairs(get_attackers(board,"e",2)) do
        if attacker.color=="Black" then
         in_between_square_is_attacked_by_enemy=true
        end
       end
       if in_between_square_is_attacked_by_enemy then
        return false
       elseif board.e[2]=="v" then
        return false
       elseif piece_on_square(board,"e",2)~=nil then
        return false
       elseif piece_on_square(board,"f",2)~=nil then
        return false
       elseif board.white_right_castling~=true then
        return false
       elseif #get_attackers(board,"d",2)~=0 then
        return false
       else
        return true
       end
      end
     elseif player=="Black" and starting_square=="d8" and (ending_square=="b8" or ending_square=="f8") then
      --Black is trying to Castle
      if ending_square=="b8" then
       --Black is trying to Castle to the right
       local in_between_square_is_attacked_by_enemy=false
       for attacker_number,attacker in ipairs(get_attackers(board,"c",8)) do
        if attacker.color=="White" then
         in_between_square_is_attacked_by_enemy=true
        end
       end
       if in_between_square_is_attacked_by_enemy then
        return false
       elseif board.c[8]=="v" then
        return false
       elseif piece_on_square(board,"c",8)~=nil then
        return false
       elseif piece_on_square(board,"b",8)~=nil then
        return false
       elseif board.black_right_castling~=true then
        return false
       elseif #get_attackers(board,"d",8)~=0 then
        return false
       else
        return true
       end
      else
       --Black is trying to Castle to the left
       local in_between_square_is_attacked_by_enemy=false
       for attacker_number,attacker in ipairs(get_attackers(board,"e",8)) do
        if attacker.color=="White" then
         in_between_square_is_attacked_by_enemy=true
        end
       end
       if in_between_square_is_attacked_by_enemy then
        return false
       elseif board.e[8]=="v" then
        return false
       elseif piece_on_square(board,"e",8)~=nil then
        return false
       elseif piece_on_square(board,"f",8)~=nil then
        return false
       elseif board.black_left_castling~=true then
        return false
       elseif #get_attackers(board,"d",8)~=0 then
        return false
       else
        return true
       end
      end
     else
      return false
     end
    end
   end
  end
 end
end
function copy_board(board)
 local board_copy={}
 for key,value in pairs(board) do
  if type(value)=="table" then
   board_copy[key]={}
   if key=="white_pieces" or key=="black_pieces" then
    for piece_number,piece in ipairs(board[key]) do
     board_copy[key][piece_number]=new_piece(board[key][piece_number].file,board[key][piece_number].rank,board[key][piece_number].type,board[key][piece_number].color)
    end
   else
    for rank=1,9 do
     board_copy[key][rank]=board[key][rank]
    end
   end
  else
   board_copy[key]=value
  end
 end
 return board_copy
end
function only_update_board(board,starting_square,ending_square)
 --contains only the Board-updating step of update_board
 --does not use io.read()
 --does not handle Promotion; keeps a Pawn as a Pawn
 --does not actually change the board variable; makes and changes a copy instead
 --returns the copy
 --should be called only with a "physically possible" Move
 local board_copy=copy_board(board)
 local starting_file=string.sub(starting_square,1,1)
 local starting_rank=tonumber(string.sub(starting_square,2,-1))
 local ending_file=string.sub(ending_square,1,1)
 local ending_rank=tonumber(string.sub(ending_square,2,-1))
 if starting_square=="d2" then
  board_copy.white_right_castling=false
  board_copy.white_left_castling=false
 elseif starting_square=="d8" then
  board_copy.black_right_castling=false
  board_copy.black_left_castling=false
 elseif starting_square=="a2" or ending_square=="a2" then
  board_copy.white_left_castling=false
 elseif starting_square=="a8" or ending_square=="a8" then
  board_copy.black_right_castling=false
 elseif starting_square=="g2" or ending_square=="g2" then
  board_copy.white_right_castling=false
 elseif starting_square=="g8" or ending_square=="g8" then
  board_copy.black_left_castling=false
 end 
 if board_copy[ending_file][ending_rank]=="v" then
  board_copy[ending_file][ending_rank]=" "
  board_copy[starting_file][starting_rank]="v"
  skip_black_pieces=false
  for piece_number,piece in ipairs(board_copy.white_pieces) do
   if piece.file==starting_file and piece.rank==starting_rank then
    piece.file=ending_file
    piece.rank=ending_rank
    skip_black_pieces=true
    break
   end
  end
  if skip_black_pieces==true then
  else
   for piece_number,piece in ipairs(board_copy.black_pieces) do
    if piece.file==starting_file and piece.rank==starting_rank then
     piece.file=ending_file
     piece.rank=ending_rank
     break
    end
   end
  end
 else
  if board_copy.white_pieces[1].file==starting_file and board_copy.white_pieces[1].rank==starting_rank and starting_file=="d" and (ending_file=="b" or ending_file=="f") then
   board_copy.white_pieces[1].file=ending_file
   local rook_starting_file="a"
   local rook_ending_file="c"
   if ending_file=="f" then
    rook_starting_file="g"
    rook_ending_file="e"
   end
   for piece_number,piece in ipairs(board_copy.white_pieces) do
    if piece.file==rook_starting_file and piece.rank==2 then
     piece.file=rook_ending_file
     break
    end
   end
  elseif board_copy.black_pieces[1].file==starting_file and board_copy.black_pieces[1].rank==starting_rank and starting_file=="d" and (ending_file=="b" or ending_file=="f") then
   board_copy.black_pieces[1].file=ending_file
   local rook_starting_file="a"
   local rook_ending_file="c"
   if ending_file=="f" then
    rook_starting_file="g"
    rook_ending_file="e"
   end
   for piece_number,piece in ipairs(board_copy.black_pieces) do
    if piece.file==rook_starting_file and piece.rank==8 then
     piece.file=rook_ending_file
     break
    end
   end
  else
   skip_black_pieces=false
   --no castling
   for piece_number,piece in ipairs(board_copy.white_pieces) do
    if piece.file==starting_file and piece.rank==starting_rank then
     piece.file=ending_file
     piece.rank=ending_rank
     for opponent_piece_number,opponent_piece in ipairs(board_copy.black_pieces) do
      if opponent_piece.file==ending_file and opponent_piece.rank==ending_rank then
       table.remove(board_copy.black_pieces,opponent_piece_number)
       break
      end
     end
     skip_black_pieces=true
     break
    end
   end
   if skip_black_pieces==false then
    for piece_number,piece in ipairs(board_copy.black_pieces) do
     if piece.file==starting_file and piece.rank==starting_rank then
      piece.file=ending_file
      piece.rank=ending_rank
      for opponent_piece_number,opponent_piece in ipairs(board_copy.white_pieces) do
       if opponent_piece.file==ending_file and opponent_piece.rank==ending_rank then
        table.remove(board_copy.white_pieces,opponent_piece_number)
        break
       end
      end
     end
    end
   end
  end
 end
 return board_copy
end
function check_legality(board,starting_square,ending_square,player)
 if string.find(string.sub(starting_square,1,1),"[abcdefg]")==nil or string.find(string.sub(starting_square,2,2),"[1-9]")==nil or #starting_square~=2 then
  return false --filters out starting squares not on the 7-by-9 area
 elseif string.find(string.sub(ending_square,1,1),"[abcdefg]")==nil or string.find(string.sub(ending_square,2,2),"[1-9]")==nil or #ending_square~=2 then
  return false --filters out ending squares not on the 7-by-9 area
 elseif piece_on_square(board,string.sub(starting_square,1,1),tonumber(string.sub(starting_square,2,2)))==nil then
  return false --filters out trying to pick up a piece that doesn't exist
 elseif piece_on_square(board,string.sub(starting_square,1,1),tonumber(string.sub(starting_square,2,2))).color~=player then
  return false --filters out trying to pick up a piece that belongs to the opponent
 elseif move_is_physically_possible(board,starting_square,ending_square,player)==false then
  return false --filters out physically impossible moves
 elseif player=="White" and #get_attackers(only_update_board(board,starting_square,ending_square),only_update_board(board,starting_square,ending_square).white_pieces[1].file,only_update_board(board,starting_square,ending_square).white_pieces[1].rank)>0 then
  return false --filters out moves by White that leave the White King in Check
 elseif player=="Black" and #get_attackers(only_update_board(board,starting_square,ending_square),only_update_board(board,starting_square,ending_square).black_pieces[1].file,only_update_board(board,starting_square,ending_square).black_pieces[1].rank)>0 then
  return false --filters out moves by Black that leave the Black King in Check
 else
  return true
 end
end
function boards_repeat(board_1,board_2)
 --returns true if the boards are the same, including castling rights
 --returns false otherwise
 if board_1.white_left_castling==board_2.white_left_castling and board_1.black_right_castling==board_2.black_right_castling and board_1.white_right_castling==board_2.white_right_castling and board_1.black_left_castling==board_2.black_left_castling then
 else
  return false
 end
 for file_number_from_a_file,file in ipairs(files) do
  for rank=1,9 do
   if board_1[file][rank]~=board_2[file][rank] then
    return false
   end
   if piece_on_square(board_1,file,rank)==nil and piece_on_square(board_2,file,rank)~=nil then
    return false
   end
   if piece_on_square(board_2,file,rank)==nil and piece_on_square(board_1,file,rank)~=nil then
    return false
   end
   if piece_on_square(board_1,file,rank)~=nil then
    if piece_on_square(board_1,file,rank).type~=piece_on_square(board_2,file,rank).type then
     return false
    end
    if piece_on_square(board_1,file,rank).color~=piece_on_square(board_2,file,rank).color then
     return false
    end
   end
  end
 end
 return true
end
function rank_of_last_square_in_file(board,file,player)
 --returns the rank of the last existing square in the file for that player
 --returns nil if the file is empty
 local last_rank=false
 if player=="White" then
  for rank=1,9 do
   if board[file][rank]==" " then
    last_rank=rank
   end
  end
 else
  for rank=9,1,-1 do
   if board[file][rank]==" " then
    last_rank=rank
   end
  end
 end
 if last_rank then
  return last_rank
 else
  return nil
 end
end
function update_board(board,history,starting_square,ending_square,plays_left)
 --asks for which Piece to Promote to, if any
 --updates board through pass by reference
 --updates history through pass by reference using copy_board
 --checks for Check, Checkmate, and Draw
 --allows the Player to claim Draw if that was the 50-74th Move or 3rd or 4th Repetition
 --returns "none", "check", "checkmate", "draw", et cetera; a boolean stating whether the next Player can immediately Claim a Draw; the new value of plays_left; and a boolean stating whether the board should be shown again
 local starting_file=string.sub(starting_square,1,1)
 local starting_rank=tonumber(string.sub(starting_square,2,-1))
 local ending_file=string.sub(ending_square,1,1)
 local ending_rank=tonumber(string.sub(ending_square,2,-1))
 local repetitions=0
 local game_state="none"
 if piece_on_square(board,starting_file,starting_rank).type=="Pawn" or piece_on_square(board,ending_file,ending_rank)~=nil then
  plays_left=150
 else
  plays_left=plays_left-1
 end
 board=only_update_board(board,starting_square,ending_square) --very important
 if piece_on_square(board,ending_file,ending_rank).type=="Pawn" and ending_rank==rank_of_last_square_in_file(board,ending_file,piece_on_square(board,ending_file,ending_rank).color) then
  print("Which Piece would you like to Promote to? Enter \"Voidrider\", \"Rook\", \"Bishop\", or \"Knight\".")
  promotion=io.read()
  if promotion~="Voidrider" and promotion~="Rook" and promotion~="Bishop" and promotion~="Knight" then
   repeat
    print("You cannot Promote to that piece! Please enter a Piece you can Promote to. Remember to capitalize the Piece name!")
    promotion=io.read()
   until promotion=="Voidrider" or promotion=="Rook" or promotion=="Bishop" or promotion=="Knight"
  end
  piece_on_square(board,ending_file,ending_rank).type=promotion
 end
 history[#history+1]=copy_board(board)
 local might_be_mate=true
 for piece_number,piece in ipairs(board[other_players_piece_lists_index[piece_on_square(board,ending_file,ending_rank).color]]) do
  for file_number_from_a_file,file in ipairs(files) do
   for rank=1,9 do
    if check_legality(board,piece.file..tostring(piece.rank),file..tostring(rank),piece.color) then
     might_be_mate=false
    end
   end
  end
 end
 for before_play_number,previous_board in ipairs(history) do
  if boards_repeat(previous_board,board) then
   repetitions=repetitions+1
  end
 end
 if repetitions>=3 or (piece_on_square(board,ending_file,ending_rank).type~="Pawn" and plays_left<=50) then
  print("Would you like to Claim a Draw? Enter \"yes\" or \"no\".")
  local raw_draw_reply=io.read()
  if raw_draw_reply~="yes" and raw_draw_reply~="no" then
   repeat
    print("Enter \"yes\" or \"no\".")
    raw_draw_reply=io.read()
   until raw_draw_reply=="yes" or raw_draw_reply=="no"
  end
  if raw_draw_reply=="yes" then
   return board,"draw",true,plays_left,false
  end
 end
 if #get_attackers(board,board[other_players_piece_lists_index[piece_on_square(board,ending_file,ending_rank).color]][1].file,board[other_players_piece_lists_index[piece_on_square(board,ending_file,ending_rank).color]][1].rank)~=0 then
  game_state="check"
 end
 if might_be_mate then
  if game_state=="check" then
   game_state="checkmate"
  else
   game_state="draw"
  end
 end
 local can_draw=false
 if repetitions>=3 or plays_left<=50 then
  can_draw=true
  game_state="draw"
 end
 if (repetitions>=5 or plays_left<=0) and game_state=="none" then
  game_state="draw"
 elseif (repetitions>=5 or plays_left<=0) and game_state=="check" then
  game_state="check_and_draw"
 end
 return board,game_state,can_draw,plays_left,true
end
local board={}
board.a={"v"," ","v","v","v","v","v"," ","v"}
board.b={" "," "," "," "," "," "," "," "," "}
board.c={"v"," "," "," "," "," "," "," ","v"}
board.d={"v"," "," "," "," "," "," "," ","v"}
board.e={"v"," "," "," "," "," "," "," ","v"}
board.f={" "," "," "," "," "," "," "," "," "}
board.g={"v"," ","v","v","v","v","v"," ","v"}
board.white_left_castling=true
board.black_right_castling=true --remember right is towards the a-File for Black
board.white_right_castling=true
board.black_left_castling=true
board.white_pieces={new_piece("d",2,"King","White")}
board.white_pieces[2]=new_piece("f",1,"Voidrider","White")
board.white_pieces[3]=new_piece("b",1,"Voidrider","White")
board.white_pieces[4]=new_piece("a",2,"Rook","White")
board.white_pieces[5]=new_piece("g",2,"Rook","White")
board.white_pieces[6]=new_piece("b",2,"Knight","White")
board.white_pieces[7]=new_piece("f",2,"Knight","White")
board.white_pieces[8]=new_piece("c",2,"Bishop","White")
board.white_pieces[9]=new_piece("e",2,"Bishop","White")
board.white_pieces[10]=new_piece("b",3,"Pawn","White")
board.white_pieces[11]=new_piece("c",3,"Pawn","White")
board.white_pieces[12]=new_piece("d",3,"Pawn","White")
board.white_pieces[13]=new_piece("e",3,"Pawn","White")
board.white_pieces[14]=new_piece("f",3,"Pawn","White")
board.black_pieces={new_piece("d",8,"King","Black")}
board.black_pieces[2]=new_piece("f",9,"Voidrider","Black")
board.black_pieces[3]=new_piece("b",9,"Voidrider","Black")
board.black_pieces[4]=new_piece("a",8,"Rook","Black")
board.black_pieces[5]=new_piece("g",8,"Rook","Black")
board.black_pieces[6]=new_piece("b",8,"Knight","Black")
board.black_pieces[7]=new_piece("f",8,"Knight","Black")
board.black_pieces[8]=new_piece("c",8,"Bishop","Black")
board.black_pieces[9]=new_piece("e",8,"Bishop","Black")
board.black_pieces[10]=new_piece("b",7,"Pawn","Black")
board.black_pieces[11]=new_piece("c",7,"Pawn","Black")
board.black_pieces[12]=new_piece("d",7,"Pawn","Black")
board.black_pieces[13]=new_piece("e",7,"Pawn","Black")
board.black_pieces[14]=new_piece("f",7,"Pawn","Black")
local plays_left=150
print_board(board)
local should_be_broken=false
local game_state="none"
local can_draw=false
local history={copy_board(board)}
while true do --gameplay loop
 for index,player in ipairs({"White","Black"}) do
  print("It is "..player.."'s turn.")
  if can_draw then
   print("Would you like to Claim a Draw? Enter \"yes\" or \"no\".")
   raw_draw_reply=io.read()
   if raw_draw_reply~="yes" and raw_draw_reply~="no" then
    repeat
     print("Enter \"yes\" or \"no\".")
     raw_draw_reply=io.read()
    until raw_draw_reply=="yes" or raw_draw_reply=="no"
   end
   if raw_draw_reply=="yes" then
    print("The game is Drawn!")
    should_be_broken=true
    break
   end
  end
  print("Enter the Square of the Piece you wish to Move.")
  local starting_square=io.read()
  print("Enter the Square you wish to Move this Piece to.")
  local ending_square=io.read()
  if check_legality(board,starting_square,ending_square,player)==false then
   repeat
    print("You cannot make that Move! Please make a Legal Move.")
    print("Enter the Square of the Piece you wish to Move.")
    starting_square=io.read()
    print("Enter the Square you wish to Move this Piece to.")
    ending_square=io.read()
   until check_legality(board,starting_square,ending_square,player)
  end
  board,game_state,can_draw,plays_left,show_board=update_board(board,history,starting_square,ending_square,plays_left)
  if show_board then
   print_board(board)
  end
  if game_state=="checkmate" then
   print("That's Checkmate! "..player.." wins!")
   should_be_broken=true
   break
  elseif game_state=="check" then
   print("Check")
  elseif game_state=="draw" then
   print("The game is Drawn!")
   should_be_broken=true
   break
  elseif game_state=="check_and_draw" then
   print("Check")
   print("The game is Drawn!")
   should_be_broken=true
   break
  end
 end
 if should_be_broken then
   break
 end
end
print("Press Enter to exit.")
io.read()

