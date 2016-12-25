(************************************************************
   grp.ml		Created      : Sun Feb  9 02:14:29 2003
  			Last modified: Sun Feb 09 02:16:48 2003
  Compile: ocamlopt.opt str.cmxa grp.ml -o grp #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)

let r = Str.regexp "\\(html\\|gif\\)"

let _ =
  if Str.string_match r "html" 0 then
    print_endline "matched"
  else
    print_endline "NOT matched"
