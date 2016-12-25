(************************************************************
   stat.ml		Created      : Sun Feb  9 03:55:56 2003
  			Last modified: Sun Feb 09 03:56:26 2003
  Compile: ocamlopt.opt unix.cmxa stat.ml -o stat #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)
let _ = 
  Unix.stat "sonnafile"
