(************************************************************
   http.ml		Created      : Sat Feb  8 19:40:34 2003
  			Last modified: Tue Jul 01 00:47:39 2003
  Compile: ocamlc.opt -a -o http.cma -g str.cma unix.cma mytcp.ml url.cmo http.ml #
  Compile: ocamlc.opt -g str.cma unix.cma mytcp.ml url.cmo http.ml -o http #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)
exception Error of string

(* 決めうち。 直すべきでしょう *)
let http_port = 80

open Url

let split_regexp = Str.regexp "\r\n\r\n"

let get ?(header = []) url =
  if url.protocol <> HTTP then
    raise (Error ("irregural protocol"))
  else
    let header_string =
      let rec iter = function
	  [] -> ""
	| hd::tl -> hd^"\r\n"^(iter tl) in
      iter header in
    let request_string =
(*      Printf.sprintf "GET %s HTTP/1.1\r\nHost: %s\r\n%s" url.path url.hostname header_string in*)
      Printf.sprintf "GET %s HTTP/1.0\r\n%s\r\n" url.path header_string in
(*    let _ = print_endline  request_string;  flush stdout   in*)
    let s = Mytcp.connect url.hostname http_port in
    let buf = String.make 1 '\000' in
    let c = ref "" in
    let size =
      Unix.write s request_string 0 (String.length request_string) in
(*    let _ = Printf.printf "size = %d" size in*)
    try
      while true do
	let num = Unix.read s buf 0 1 in
	if num = 0 then
	  raise End_of_file
	else
	  c := !c^(String.sub buf 0 1)
      done;
      (* dummy *)
      ("hoge", !c)
    with
      End_of_file ->
	let content = !c in
	let size = String.length content in
	let pos = Str.search_forward split_regexp content 0 in
	let head = String.sub content 0 pos in
	let content_init_pos = Str.match_end () in
	let content = 
	  String.sub content content_init_pos (size - content_init_pos) in
	(head, content)

