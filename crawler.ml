(************************************************************
   crawler.ml		Created      : Sun Feb  9 00:56:42 2003
  			Last modified: Sun Dec 25 11:31:20 2016
  Compile: ocamlopt.opt crawler.ml -o crawler #
  FTP Directory: sources/ocaml #
************************************************************)
(**

  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>

*)
(* TODO: config by file or command line *)
let config_level = 4
let config_init_url = "http://mamewo.ddo.jp/"
                        
module URLCrawler =
  struct
    module NodeSet = Set.Make(String)
    let dfs get_next nodes level =
      let rec iter_iter current_level nodes p =
	List.fold_right (iter current_level) nodes p
      and iter current_level node ((result, visited) as p) =
	if current_level = level || NodeSet.mem node visited then
	  p
	else
	  let next_nodes = get_next node in
	  let next_level = 
	    if (current_level < 0) then current_level 
	    else current_level + 1 in
	  iter_iter (current_level+1)
	    next_nodes (node::result, NodeSet.add node visited) in
      fst (iter_iter 0 nodes ([], NodeSet.empty))
  end

(*module URLCrawler = *)
(*  NormalGraph(Set.Make(String)) *)
    
let default_filename = "index.html"
let base_dir = "result"

let regexp = Str.regexp "\\(^.*/\\)[^/]*\\.\\(html?\\|gif\\|jpeg\\|jpg\\|png\\)?$"

let assume_base url =
  if (String.sub url 0 6) = "mailto" then
    raise (Url.IrreguralURL (url))
  else if Str.string_match regexp url 0 then
    Str.matched_group 1 url
  else
    (url ^ "/")
	
let to_full_url path relative = 
  let full_regexp = Str.regexp "http://" in
  if Str.string_match full_regexp relative 0 then
    relative
  else
    let base = assume_base path in
    Filename.concat path relative

let split_regexp = Str.regexp "/"
let make_path path =
  let pathlst = Str.split split_regexp path in
  let rec iter h = function
      [] -> ()
    | head::tail ->
	let new_dir = h^head^"/" in
	(try
	    ignore (Unix.stat new_dir)
	  with
	    Unix.Unix_error(Unix.ENOENT, _, _) ->
	    Unix.mkdir new_dir 0o775);
	iter new_dir tail in
  iter "" pathlst
      
let mark_regexp = Str.regexp "\\([^#]*\\)/\\([^#/]*\\)\\(#.*\\)?$"

(** customized (not generic) *)
let get_next init_path url_string =
  print_endline ("get_next: "^url_string);
  let url = Url.of_string url_string in
  let content = snd (Http.get url) in
  (** mark¤ò¤È¤ë *)
  let path, filename = 
    let target = url.Url.path in
    if Str.string_match mark_regexp target 0 then
      (Str.matched_group 1 target, Str.matched_group 2 target)
    else
      assert false in
  let file_path = Filename.concat base_dir path in
  let _ = make_path file_path in
  let local_filename =
    let fname =
      if String.length filename > 0 then
        filename
      else
        "_empty" in
    Filename.concat (Filename.concat base_dir path) fname in
  let _ = print_endline ("output: "^local_filename) in
  let output =
    open_out local_filename in
  let _ =
    print_endline ("writing " ^ local_filename); flush stdout;
    output_string output content; close_out output in
  List.fold_right
    (fun x l -> 
      try 
	let full_url = to_full_url ("http://" ^ url.Url.hostname ^ path) x in
	print_endline ("full_url: "^full_url);
	full_url::l
      with Url.IrreguralURL _ -> l)
    (LinkCollecter.collect_link content) []
  
let init_url = config_init_url
let init_path = assume_base init_url

let crawl ?(level = -1) urls =
  URLCrawler.dfs (get_next init_path) urls level

let _ = 
(*  List.iter print_endline (get_next init_path init_url)*)
  (*  print_endline init_path;*)
  try
    crawl ~level:config_level [init_url]
  with
    Unix.Unix_error(error_code, function_name, param) as e ->
    print_endline (Unix.error_message error_code);
    raise e
