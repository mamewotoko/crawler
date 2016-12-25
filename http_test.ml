(************************************************************
   http_test.ml		Created      : Tue Jul  1 00:43:08 2003
  			Last modified: Tue Jul 01 12:36:37 2003
  Compile: ocamlc http.cma base64.ml http_test.ml -o http_test #
  FTP Directory: sources/ocaml #
************************************************************)
(**
  例えば、モデム、プリンターの認証が必要なページに対して
リクエストをだして、ログインしてみるテストとか。

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>
*)

let _ =
  let passwd = "id:password" in
  let header = "Authorization: Basic "^(Base64.encode passwd) in
  let (header, content) = Http.get ~header:[header] (Url.of_string "http://192.168.0.1/hogemoge") in
  print_endline header;
  print_endline "--------------------------------------------------";
  print_endline content
