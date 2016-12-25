(************************************************************
   pop.ml		Created      : Mon Feb 10 00:00:07 2003
  			Last modified: Wed Mar 05 09:22:26 2003
  Compile: ocamlc.opt pop.ml -i -c #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

2003/ 3/ 5
  apop_login を追加した
*)

open Mytcp

exception POPError of string

let ack_regexp = Str.regexp "+OK"
let error_regexp = Str.regexp "-ERR"
let ack_delimiter_regexp = Str.regexp "\\( \\|\r\n\\)+"

let send_and_dispose_ack socket m = 
  ignore (send_string socket m);
  let ack = receive_one_line socket in
(*  let _ = print_endline ack in*)
  if not (Str.string_match ack_regexp ack 0) then
    raise (POPError(m))
  else () 
;;

let receive_ack_linebased_tokens ~socket num =
  let rec iter c lst =
    if c >= num then
      lst
    else
      let ack = receive_one_line socket in
      let tokens = Str.split ack_delimiter_regexp ack in
      let size = List.length tokens in
      iter (c+size) (lst@tokens) in
  iter 0 []
;;

let challenge_regexp = Str.regexp "[^<]*\\(<[^>]+>\\)"
let ok_ack = "+OK"
let is_ok ack =
  String.sub ack 0 3 = ok_ack

let apop_login ~user ~password ~socket =
  let first_line = Mytcp.receive_one_line socket in
  let challenge = 
    if Str.string_match challenge_regexp first_line 0 then
      Str.matched_group 1 first_line
    else
      begin
	prerr_endline "pop.ml:Not matched (challenge)"; exit 1
      end in
  let digest = Digest.to_hex (Digest.string (challenge ^ password)) in
  let user_message = Printf.sprintf "APOP %s %s\r\n\r\n" user digest in
  begin
    ignore (Mytcp.send_string socket user_message);
    let ack = receive_one_line socket in
    is_ok ack
  end
;;

let login ~user ~password ~socket =
  let user_message = "USER " ^ user ^ "\r\n" in
  let password_message = "PASS " ^ password ^ "\r\n" in
  List.iter (send_and_dispose_ack socket) [user_message; password_message]
;;

(*let login ~user ~password ~socket =*)
(*  let user_message = "USER " ^ user ^ "\r\n" in*)
(*  let password_message = "PASS " ^ password ^ "\r\n" in*)
(*  begin*)
(*    ignore (receive_one_line socket);*)
(*    ignore (send_string socket user_message);*)
(*    ignore (receive_one_line socket);*)
(*    ignore (send_string socket password_message);*)
(*    let ack = receive_one_line socket in*)
(*    if Str.string_match ack_regexp ack 0 then*)
(*      true*)
(*    else if Str.string_match error_regexp ack 0 then*)
(*      false*)
(*    else*)
(*      raise (POPError("I don't know!!: " ^ ack))*)
(*  end*)
(*;;*)

    
let state ~socket =
  let first_command = "STAT\r\n" in
  let _ = send_string socket first_command in
  let mail_state =
    receive_ack_linebased_tokens socket 3 in
  match mail_state with
    [ok; n; maybe_size] ->
      if ok = "+OK" then
	int_of_string n
      else 
	raise (POPError("I cannot understand ack of STAT: "))
  | _ ->
      raise (POPError("I cannot understand ack of STAT: "))
	
let fetch_mail ~socket =
  let first_command = "UIDL\r\n" in
  let _ = send_string socket first_command in
  let ack = receive_one_line socket in
  let res = receive_one_line socket in
  match Str.split ack_delimiter_regexp res with
    id::tail ->
      let fetch_command = ("RETR " ^ id ^ "\r\n") in 
      ()
  | _ -> raise (POPError(res))
;;

(*let fetch_ack_regexp = Str.regexp "^+OK \\(\\d+\\) octets\r\n"*)
let fetch_ack_regexp = Str.regexp "^+OK"

let fetch ~socket id =
  let sid = string_of_int id in
  let fetch_command = ("RETR " ^ sid ^ "\r\n") in 
  let _ = send_string socket fetch_command in
  let ack_tokens = receive_ack_linebased_tokens socket 2 in
  match ack_tokens with
    ok::_ ->
      if ok <> "+OK" then
	  raise (POPError(ok))
      else
	let content = receive_until_pattern socket "\r\n.\r\n" in
	let content_size = String.length content in
	let real_content = String.sub content 0 (content_size-3) in
	(* do something *)
	begin
	  print_string real_content;
	end
  | _ ->
      begin
	let ack = List.fold_right (fun x y -> x^" "^y) ack_tokens "" in
	raise (POPError(ack))
      end
