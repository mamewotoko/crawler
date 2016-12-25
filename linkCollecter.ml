(************************************************************
   linkCollecter.ml	Created      : Sat Feb  8 23:18:42 2003
  			Last modified: Sat Feb 08 23:42:26 2003
  Compile: ocamlopt.opt linkCollecter.ml -o linkCollecter #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)

let link_regexp = 
  Str.regexp_case_fold "<a href=\"\\([^\"]+\\)\">"

let collect_matched regexp str =
  let size = String.length str in
  let rec iter pos lst =
    try
      let new_pos = 
	Str.search_forward regexp str pos in
      if Str.string_match regexp str new_pos then
	let url = Str.matched_group 1 str in
	iter (Str.match_end ()) (url::lst)
      else
	assert false
    with
      Not_found -> List.rev lst in
  iter 0 []

let collect_link str =
  collect_matched link_regexp str

(* test *)
(*let _ =*)
(*  let url = "http://127.0.0.1" in*)
(*  let content = Http.get (Url.of_string url) in*)
(*  let _ = print_endline content; flush stdout in*)
(*  List.iter print_endline (collect_link content)*)
