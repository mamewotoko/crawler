(************************************************************
   mkdir.ml		Created      : Sun Feb  9 03:57:07 2003
  			Last modified: Sun Feb 09 04:14:02 2003
  Compile: ocamlopt.opt unix.cmxa str.cmxa mkdir.ml -o mkdir #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)
let split_regexp = Str.regexp "/"
let make_path path =
  let pathlst = Str.split split_regexp path in
  let rec iter h = function
      [] -> ()
    | head::tail ->
	let new_dir = h^head^"/" in
	try 
	  ignore (Unix.stat new_dir); print_endline "already exists"; exit 1
	with
	  Unix.Unix_error(Unix.ENOENT, _, _) ->
	    Unix.mkdir new_dir 0o775; iter new_dir tail
	| e -> raise e in
  iter "" pathlst

let _ =
  make_path "very/long/directory" 
