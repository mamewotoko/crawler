(************************************************************
   whynot_crawler.ml		Created      : Sun Feb  9 00:56:42 2003
  			Last modified: Fri Feb 14 11:24:09 2003
  Compile: ocamlc.opt -g url.ml http.ml linkCollecter.ml whynot_crawler.ml -o whynot_crawler #
  FTP Directory: sources/ocaml #
************************************************************)
(**
   なんでだろう〜、なんでだろうってやつです。だって、どちらも
   string だよ。NodeSet.elt = string と言う事実が晒されていない
  のかなぁ。かんがえようっと
  @author Takashi Masuyama <mamewo@dk9.so-net.ne.jp>
*)

module NormalGraph = 
  functor (X : Set.OrderedType) ->
  struct
    (** 集めるだけ。規模がでかいと困りますね *)
    module NodeSet = Set.Make(X) 

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
      fst (iter_iter level nodes ([], NodeSet.empty))
  end

module URLCrawler = 
  NormalGraph(struct type t = string let compare = compare end)
    
let default_filename = "index.html"
let base_dir = "result"

let get_next url_string =
  let url = Url.of_string url_string in
  let (_, content) = Http.get url in
  let path = url.Url.path in
  let filename = 
    let tmp = Filename.basename path in
    if tmp = "" then default_filename
    else tmp in
  let output = open_out (Filename.concat base_dir filename) in
  let _ =
    print_endline ("writing "^filename); flush stdout;
    output_string output content; close_out output in
  LinkCollecter.collect_link content
    
let crawl ?(level = -1) urls =
  URLCrawler.dfs get_next urls level

let init_url =
  "http://web.archive.org/web/20011121074632/www.sankei.co.jp/kusano/tokyolittle/tokyolittleback.html"

let _ = 
  crawl ~level:3 [init_url]
