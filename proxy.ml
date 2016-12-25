(************************************************************
   proxy.ml		Created      : Fri Feb 15 22:18:25 2002
  			Last modified: Sun Mar 02 20:35:48 2003
  FTP Directory: sources/ocaml #
  Compile: ocamlfind ocamlopt -thread unix.cmxa threads.cmxa str.cmxa url.ml mytcp.ml proxy.ml -o proxy #

#! /home/tak/bin/mytop
  mytopの作り方
  >  ocamlmktop unix.cma -custom -o mytop
************************************************************)

open Mytcp
exception Error of string

module Unix = UnixLabels

let listen_num = 5

let request_split_regexp = Str.regexp "\\(\r\n\\)+"
let line_split_regexp = Str.regexp " +"

let proxy ~output ~tag (sourcesock, destsock, filename) =
  let output_message output message =
    let message_with_tag =
      match tag with
	Some tag -> tag ^ "\n" ^ message
      | None -> message in
    output_string output message_with_tag; flush output in
  let file_output = 
    match filename with
      Some f -> Some (open_out f)
    | None -> None in
  try
    while true do
      let message = receive_one_line sourcesock in
      ignore (send_string destsock message);
      output_message output message;
      match file_output with
	Some output ->
	  output_message output message
      | None -> ()
    done
  with
    Unix.Unix_error (id, s, p) ->
      print_endline ((Unix.error_message id) ^ "\n" ^ s ^ " " ^p); exit 1  
  | End_of_file -> 
      flush stdout; Thread.exit ()
;;

let session ~realhost ~realport 
    ~client_message_filename ~server_message_filename
    (serv_sock, addr) =
  let p_to_r_file = open_out "P2R.txt" in
  let r_to_p_file = open_out "R2P.txt" in
  let sock = Mytcp.connect realhost realport in
  let send_thread =
    Thread.create (proxy ~output:stdout ~tag:None)
      (serv_sock, sock, client_message_filename) in
  let receive_thread = 
    Thread.create (proxy  ~output:stdout  ~tag:None)
      (sock, serv_sock, server_message_filename) in
  List.iter Thread.join [send_thread; receive_thread]
;;

let serve ~realhost ~realport ~proxyhost ~proxyport
    ~client_message_filename ~server_message_filename =
  let _ = 
    Printf.printf "REALHOST: %s\nREALPORT: %d\nPROXYHOST: %s\nPROXYPORT %d\n"
    realhost realport proxyhost proxyport; flush stdout in
  let s = 
    Unix.socket
      ~domain:Unix.PF_INET ~kind:Unix.SOCK_STREAM ~protocol:0 in
  let handler = (fun i -> Unix.close s) in
  let _ =
    begin
      Sys.set_signal Sys.sigint (Sys.Signal_handle(handler))
    end in
  let host_ip =
    (Unix.gethostbyname proxyhost).Unix.h_addr_list.(0) in
  begin
    Unix.bind s ~addr:(Unix.ADDR_INET(host_ip, proxyport));
    Unix.listen s ~max:listen_num; (* maxは受け付ける接続数 *)
    let session_function =
      session ~realhost:realhost ~realport:realport
    	~client_message_filename:client_message_filename
	~server_message_filename:server_message_filename in
    (*  handle_unix_error を使うために acceptの遅延 *)
    let start () = session_function (Unix.accept s) in
      while true do
	Unix.handle_unix_error start ()
      done
  end;;

let _ =
  let realport = ref 80 in
  let realhost = ref "127.0.0.1" in
  let proxyport = ref 8080 in
  let proxyhost = ref "127.0.0.1" in
  let client_message_filename = ref None in
  let server_message_filename = ref None in
  let specs = 
    [ ("-realport", Arg.Int(fun x -> realport := x), "real server port");
      ("-realhost", Arg.String(fun x -> realhost := x), "real server hostname");
      ("-proxyport", Arg.Int(fun x -> proxyport := x), "proxy server port");
      ("-proxyhost", Arg.String(fun x -> proxyhost := x), "proxy server hostname");
      ("-clientmessage", Arg.String(fun x -> client_message_filename := Some x), 
       "client message is saved to this file");
      ("-servermessage", Arg.String(fun x -> server_message_filename := Some x), 
       "server message is saved to this file");
    ] in
  let usage_line = Printf.sprintf "%s [options]" Sys.argv.(0) in
  let _ = Arg.parse specs ignore usage_line in
  serve ~realhost:!realhost ~realport:!realport
    ~proxyhost:!proxyhost ~proxyport:!proxyport
    ~client_message_filename:!client_message_filename
    ~server_message_filename:!server_message_filename
