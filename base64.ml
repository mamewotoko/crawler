(************************************************************
   base64.ml		Created      : Sat Mar  8 19:56:35 2003
  			Last modified: Sat Jun 28 04:20:16 2003
  Compile: ocamlc.opt -g base64.ml -o base64 #
  FTP Directory: sources/ocaml #
************************************************************)
(**
  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>
   3 octet をグループ化して 24 bit の列と考える。このビット列を
  先頭から順に 6 bit の列に分けていく。この 6 bit をインデックスと
  して encode_table をひいた結果をエンコード結果とする。
  3 octet が 4 octet に変換される。
*)

let encode_table =
[| 'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'; 'I'; 'J'; 
   'K'; 'L'; 'M'; 'N'; 'O'; 'P'; 'Q'; 'R'; 'S'; 'T';
   'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'; 'a'; 'b'; 'c'; 'd'; 
   'e'; 'f'; 'g'; 'h'; 'i'; 'j'; 'k'; 'l'; 'm'; 'n';
   'o'; 'p'; 'q'; 'r'; 's'; 't'; 'u'; 'v'; 'w'; 'x';
   'y'; 'z'; '0'; '1'; '2'; '3'; '4'; '5'; '6'; '7';
   '8'; '9'; '+'; '/'; |]

let ascii_table_size = 127

let delimiter_char = '='

let decode_table =
  let result = Array.make ascii_table_size (-1) in
  begin
    Array.iteri (fun i c -> result.(Char.code c) <- i) encode_table;
    result
  end

let source_unit_size = 3 
let encoded_unit_size = 4
      
let encode str =
  let input_length = String.length str in
  let times = input_length / 3 in
  let remain = input_length mod source_unit_size in
  let last_input_pos = times * source_unit_size in
  let last_output_pos = times * encoded_unit_size in
  let output_length = last_output_pos + (if remain = 0 then 0 else 4) in
  let result = String.make output_length '\000' in
  let encode_last () =
    let c1 = Char.code str.[last_input_pos] in
    begin
      result.[last_output_pos] <- encode_table.(c1 lsr 2);
	result.[last_output_pos+3] <- delimiter_char;
      if remain = 1 then 
	begin
	  result.[last_output_pos+1] <- encode_table.((0x3 land c1) lsl 4);
	  result.[last_output_pos+2] <- delimiter_char;
	end
      else if remain = 2 then
	let c2 = Char.code str.[last_input_pos+1] in
	begin
	  result.[last_output_pos+1] <- encode_table.(((0x3 land c1) lsl 4) lor (c2 lsr 4));
	  result.[last_output_pos+2] <- encode_table.((c2 land 0xF) lsl 2);
	end
    end in
  let rec iter input_pos output_pos = 
    if input_pos = last_input_pos then
      if remain <> 0 then
	encode_last ()
      else ()
    else
      let c1 = Char.code str.[input_pos] in
      let c2 = Char.code str.[input_pos+1] in
      let c3 = Char.code str.[input_pos+2] in
      begin
	result.[output_pos]   <- encode_table.(c1 lsr 2);
	result.[output_pos+1] <- encode_table.(((0x3 land c1) lsl 4) lor (c2 lsr 4));
	result.[output_pos+2] <- encode_table.(((c2 land 0xF) lsl 2) lor (c3 lsr 6));
	result.[output_pos+3] <- encode_table.(0x3F land c3);
	iter (input_pos + source_unit_size) (output_pos + encoded_unit_size)
      end in
  iter 0 0; result

let decode str =
  let input_length = String.length str in
  let _ = if input_length mod 4 <> 0 then
    Printf.fprintf stderr
      "The length of Base64 encoded data is irregural!: %d" input_length in
  (* to be modified *)
  let additional =
    if str.[input_length-2] = delimiter_char then 1
    else if str.[input_length-1] = delimiter_char then 2
    else 0 in
  let times = 
    input_length / encoded_unit_size - (if additional = 0 then 0 else 1)in
  let last_input_pos = 
    times * encoded_unit_size in
  let last_output_pos =
    times * source_unit_size in
  let output_length = times * source_unit_size + additional in
  let result = String.make output_length '\000' in
  let decode_last () =
    let c1 = decode_table.(Char.code str.[last_input_pos]) in
    let c2 = decode_table.(Char.code str.[last_input_pos+1]) in
    if additional = 1 then
      result.[last_output_pos]   <- Char.chr((c1 lsl 2) lor (c2 lsr 4))
    else 
      let c3 = decode_table.(Char.code str.[last_input_pos+2]) in
      begin
	result.[last_output_pos]   <- Char.chr((c1 lsl 2) lor (c2 lsr 4));
	result.[last_output_pos+1] <- Char.chr(((c2 land 0xF) lsl 4) lor (c3 lsr 2));
      end in
  let rec iter input_pos output_pos =
    if input_pos = last_input_pos then 
      if additional <> 0 then
	decode_last ()
      else ()
    else 
      let c1 = decode_table.(Char.code str.[input_pos]) in
      let c2 = decode_table.(Char.code str.[input_pos+1]) in
      let c3 = decode_table.(Char.code str.[input_pos+2]) in
      let c4 = decode_table.(Char.code str.[input_pos+3]) in
	begin
	  result.[output_pos]   <- Char.chr((c1 lsl 2) lor (c2 lsr 4));
	  result.[output_pos+1] <- Char.chr(((c2 land 0xF) lsl 4) lor (c3 lsr 2));
	  result.[output_pos+2] <- Char.chr(((c3 land 0x3) lsl 6) lor c4);
	  iter (input_pos + encoded_unit_size) (output_pos + source_unit_size)
	end in
  iter 0 0; result
    
(*let _ =*)
(*  print_endline (decode (encode "増山隆ほhogemogeくちゃくが"))*)
