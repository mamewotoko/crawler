(************************************************************
   ftp.ml		Created      : Sun Feb  9 18:33:23 2003
  			Last modified: Sun Feb 09 18:43:50 2003
  Compile: ocamlopt.opt unix.cmxa str.cmxa url.ml http.ml ftp.ml -o ftp #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)

(*#use "proxy.ml"*)

let receive_message_from_connected_socket s =
  let c = ref "" in
  let buf = String.make 1 '\000' in
  try
    while true do
      let num = Unix.recv s buf 0 1 [] in
      if num = 0 then
	raise End_of_file
      else
	c := !c^(String.sub buf 0 num)
    done;
    "hoge"
  with End_of_file -> !c

let test () =
  let port = 21 in
  let url = "ftp://ftp.dti.ad.jp/pub/Linux/TurboLinux/" in
  let u = Url.of_string url in
  let host = u.Url.hostname in
  let _ = print_endline host; flush stdout in
  let sock = Http.connect host port in
  print_endline s; flush stdout

let _ = test ()
