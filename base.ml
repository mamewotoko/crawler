(************************************************************
   base.ml		Created      : Sun Feb  9 01:27:33 2003
  			Last modified: Sun Feb 09 01:32:42 2003
  Compile: ocamlopt.opt base.ml -o base #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)

let data = [
  "/hoge/moge/";
  "/hoge/ra";
]

let _ =
  List.iter (fun x -> print_endline (Filename.basename x)) data;
  print_endline (Filename.concat "tak" "mamewo")
    
(* 実行結果。前者はbasenameなし。
   Xmamewo:~/project/crawler> ./base
 
   ra 
*)

