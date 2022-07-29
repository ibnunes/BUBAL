(* BUBAL --- Barely Usable Brainfuck Assembly Language
 * Igor Nunes, 2022
 * This code is just a proof-of-concept.
 *)

(* Grammars and association list *)
let bf2bubal = [
    ('>', "FORW");
    ('<', "BACK");
    ('+', "INC");
    ('-', "DEC");
    ('[', "LBL");
    (']', "JNZ");
    ('.', "OUT");
    (',', "GET")
  ]

let assoctbl = Hashtbl.create 8
let () =
  let rec loadtbl = function
  | (bf, bubal) :: xs -> let () = Hashtbl.add assoctbl bf bubal in loadtbl xs
  | []                -> ()
  in loadtbl bf2bubal

let bfopers = List.map fst bf2bubal
let bfoperwithargs = List.filteri (fun i _ -> i < 4) bfopers
let bubalopers = List.map snd bf2bubal


let convert s =
  let grpcount = ref 0 in
  let groups : string Stack.t = Stack.create () in
  let code = ref "" in
  let top = String.length s in
  let save o c =
    let () = code := !code ^ Hashtbl.find assoctbl o ^ " " in
    let () = if List.mem o bfoperwithargs then code := !code ^ (string_of_int c) in
      code := !code ^ "\n"
  in
  let rec aux i oper count =
    if i < top then
    let () = if s.[i] <> oper && oper <> ' ' then save oper count in
    match s.[i] with
    | '[' -> (
        let grpname = "grp" ^ (string_of_int !grpcount) in
        let () = grpcount := !grpcount + 1 in
        let () = Stack.push grpname groups in
        let () = code := !code ^ Hashtbl.find assoctbl s.[i] ^ " " ^ grpname ^ "\n" in
          aux (i + 1) ' ' 0
      )
    | ']' -> (
        let grpname = Stack.pop groups in
        let () = code := !code ^ Hashtbl.find assoctbl s.[i] ^ " " ^ grpname ^ "\n" in
          aux (i + 1) ' ' 0
      )
    | c when c = oper -> aux (i + 1) s.[i] (count + 1)
    | _               -> aux (i + 1) s.[i] 1
  in let () = aux 0 s.[0] 0 in
    !code ^ "STOP\n"


let get_program () =
  let rec try_read s =
  try
    let c = input_char (Stdlib.stdin) in
    if List.mem c bfopers then
      try_read (s ^ String.make 1 c)
    else
      try_read s
  with End_of_file -> s
  in try_read ""


(* Main block *)
let () =
  let bubalcode = get_program () |> convert in
    print_endline bubalcode
