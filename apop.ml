(************************************************************
   apop.ml		Created      : Wed Mar  5 08:18:44 2003
  			Last modified: Wed Mar 05 08:45:43 2003
  Compile: ocamlopt.opt apop.ml -o apop #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)
let challenge_regexp = "[^<]*\\(<[^>]+>\\)"
let ok_ack = "+OK"
let is_ok ack =
  String.substring 0 3 = ok_ack

let login ~user ~password ~socket =
  let first_line = Mytcp.receive_one_line s in
  let challenge = 
    if Str.string_match challenge_regexp first_line 0 then
      Str.matched_group 1 first_line
    else
      begin
	prerr_endline "apop.ml:Not matched (challenge)"; exit 1
      end in
  let digest = Digest.to_hex (Digest.string (challenge ^ password) in
  let user_message = Printf.sprintf "APOP %s %s\r\n\r\n" user digest in
  begin
    Mytcp.send_string socket user_message;
    let ack = receive_one_line socket in
    if 
  end
;;
