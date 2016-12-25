(************************************************************
   pop_main.ml		Created      : Sun Mar  2 19:30:56 2003
  			Last modified: Wed Mar 05 21:59:54 2003
  Compile: ocamlc.opt -g str.cma unix.cma url.cmo mytcp.ml pop.ml pop_main.ml -o pop_main #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)

open Pop

let main () =
  let _ = 
    if (Array.length Sys.argv) <> 3 then
      begin
	prerr_endline "usage: pop [username] [password (-_- ;;;;; ]";
	exit 1
      end in
  let pop_port = 110 in
(*  let host = "pop.anet.ne.jp" in*)
(*  let host = "localhost" in*)
  let host = "venus.is.s.u-tokyo.ac.jp" in
  let s = Mytcp.connect host pop_port in
  let rec iter_fetch s c num = 
    if c > num then
      ()
    else 
      begin 
	print_endline "POP:fetching "; flush stdout;
	fetch s c; iter_fetch s (c+1) num
      end in
  let user = Sys.argv.(1) in
  let pass = Sys.argv.(2) in
  begin
(*    let _ = Mytcp.receive_one_line s in*)
(*    login user pass s;*)
    apop_login user pass s;
    let _ = print_endline "POP: login succeeded"; flush stdout in
    let num = Pop.state s in
    let _ = print_endline "POP: asked mail state"; flush stdout in
    let _ = Printf.printf "%d mails has come!\n" num in
    ()
(*    iter_fetch s 1 num;*)
  end

let _ = main ()
