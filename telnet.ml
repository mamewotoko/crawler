(************************************************************
   telnet.ml	Created      : Sun Feb  9 18:55:39 2003
  			Last modified: Mon Feb 10 00:32:02 2003
  Compile: ocamlfind ocamlopt -thread unix.cmxa /usr/local/lib/ocaml/threads/threads.cmxa str.cmxa url.ml http.ml telnet.ml -o telnet #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)

let url = "ftp://ftp.dti.ad.jp/pub/Linux/TurboLinux/"
let port = 80

let read_function sock =
  let c = ref "" in
  let buf = String.make 1 '\000' in
  try
    while true do
(*      if (Thread.wait_timed_read sock 5.0) then*)
	let num = Unix.recv sock buf 0 1 [] in
	if num = 0 then
	  raise End_of_file
	else
	  let ch = String.sub buf 0 num in
	  c := !c^ch;
	  if ch = "\n" then
	    begin
	      print_string !c; flush stdout; c := "";
	    end
    done;
  with 
    End_of_file -> 
      print_string !c; flush stdout; Thread.exit ()

let write_function sock = 
  while true do
    let l = read_line () in
    let _ = print_endline ("HOGE: " ^ l) in
    let size = String.length l in
    ignore (Unix.write sock l 0 size)
  done

let main host port output_option =
  let sock = Http.connect host port in
  let read_thread = Thread.create read_function sock in
  while true do
(*    if Thread.wait_timed_write sock 3.0 then*)
    let l = ((read_line ())^"\r\n") in
    (match output_option with
      Some(o) ->
	output_string o l; flush o
    | None -> ());
    let size = String.length l in
    ignore (Unix.write sock l 0 size)  
  done

let _ = 
  let output_filename = ref None in
  let hostname = ref None in
  let port = ref None in
  let num = ref 0 in
  let specs = 
    [ ("-o", Arg.String(fun x -> output_filename := Some x), 
       "output filename") ] in
  let usage_line =
    Printf.sprintf "usage: %s [host] [port]" Sys.argv.(0) in
  let arg_fun x =
    if !num = 0 then
      hostname := Some x
    else if !num = 1 then
      port := Some (int_of_string x)
    else 
      (begin Arg.usage specs usage_line; exit 1 end);
    incr num in
  let _ = 
    Arg.parse specs arg_fun usage_line in
  let output =
    match !output_filename with
      Some (filename) ->
	Some(open_out filename)
    | None -> None in
  match (!hostname, !port) with
    (Some(hostname), Some(port)) -> 
      main hostname port output;
      (match output with
	Some o -> close_out o
      | None -> ())
  | _ ->
      Arg.usage specs usage_line; exit 1
	
