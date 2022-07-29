(* Instruction set *)
type tinstruction =
  | Forw of int             (* Fundamental *)
  | Back of int
  | Inc  of int
  | Dec  of int
  | Get  of (unit -> int)
  | Out  of (int -> unit)
  | Lbl  of string
  | Jnz  of string
  | Set  of int             (* Extended *)
  | Cell of int
  | Jmp  of string
  | Stop

let string_of_instruction = function
  | Forw n -> "FORW  " ^ (string_of_int n)
  | Back n -> "BACK  " ^ (string_of_int n)
  | Inc  n -> "INC   " ^ (string_of_int n)
  | Dec  n -> "DEC   " ^ (string_of_int n)
  | Get  _ -> "GET   "
  | Out  _ -> "OUT   "
  | Lbl  s -> "LBL   " ^ s
  | Jnz  s -> "JNZ   " ^ s
  | Set  n -> "SET   " ^ (string_of_int n)
  | Cell n -> "CELL  " ^ (string_of_int n)
  | Jmp  s -> "JMP   " ^ s
  | Stop   -> "STOP"

(* Program definition *)
type tcode    = tinstruction array
type tindex   = (string, int) Hashtbl.t
type tprogram = {code : tcode; index : tindex}

(* Exceptions and execution handling *)
exception InvalidInstruction of string
exception UnknownInstruction of string
exception Comment


(* Default constants and functions *)
let _default_code_size  = 128
let _default_index_size = _default_code_size / 8
let _default_cell_number = 65536

(* Debugging *)
let _debug f = (let () = print_string "[DEBUG] " in Printf.printf) f
let _code f  = (let () = print_string "\t" in Printf.printf) f

(*
let inst_get () =
  let termio = Unix.tcgetattr Unix.stdin in
  let () =
      Unix.tcsetattr Unix.stdin Unix.TCSADRAIN
          { termio with Unix.c_icanon = false } in
  let res = input_char stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSADRAIN termio;
  Char.code res
*)

let inst_get () = (read_line ()).[0] |> Char.code

let inst_out i = Char.chr i |> print_char


(* Tape *)
class tape = object (self)
  val cells : int array = Array.make _default_cell_number 0
  val mutable ptr = 0
  method forw n = let () = ptr <- ptr + n in cells.(ptr)
  method back n = let () = ptr <- ptr - n in cells.(ptr)
  method inc  n = let () = cells.(ptr) <- cells.(ptr) + n in cells.(ptr)
  method dec  n = let () = cells.(ptr) <- cells.(ptr) - n in cells.(ptr)
  method get  f = let () = cells.(ptr) <- f () in cells.(ptr)
  method out  f = let () = f (cells.(ptr)) in cells.(ptr)
  method set  n = let () = cells.(ptr) <- n in cells.(ptr)
  method cell n = let () = ptr <- n in cells.(ptr)
  (* method _dump () = Array.iteri (fun i c -> Printf.printf "| %05d | %10d |\n" i c) cells *)
end

class machine prgm tape = object (self)
  val program : tprogram = prgm
  val t = tape
  val mutable ptr = 0
  val mutable lastvalue = 0
  val mutable _flag_waszero = false
  
  method _update () = _flag_waszero <- (lastvalue = 0)

  method jnz  s  = if not _flag_waszero then self#jmp s else lastvalue
  method jmp  s  = ptr <- Hashtbl.find program.index s; lastvalue
  method next () = ptr <- ptr + 1

  method run  () =
    if program.code.(ptr) = Stop then () else begin
      let () = lastvalue <- (
        match program.code.(ptr) with
        | Forw n -> t#forw n
        | Back n -> t#back n
        | Inc  n -> t#inc n
        | Dec  n -> t#dec n
        | Get  f -> t#get f
        | Out  f -> t#out f
        | Lbl  s -> lastvalue
        | Jnz  s -> self#jnz s
        | Set  n -> t#set n
        | Cell n -> t#cell n
        | Jmp  s -> self#jmp s
        | Stop   -> lastvalue   (* It shouldn't reach this point *)
      ) in
      let () = self#_update () in
      let () = self#next () in
        self#run ()
    end
end



(* Tokenizing and parsing *)
let instruction_of_string s =
  if s = "" then raise Comment else   (* It shouldn't reach this point *)
  let (inst, arg) =
    match String.split_on_char ' ' s with
    | inst :: []        -> (String.uppercase_ascii inst, "")
    | inst :: arg :: [] -> (String.uppercase_ascii inst, arg)
    | _                 -> raise (InvalidInstruction s)
  in match inst with
  | "FORW" -> Forw (int_of_string arg)
  | "BACK" -> Back (int_of_string arg)
  | "INC"  -> Inc  (int_of_string arg)
  | "DEC"  -> Dec  (int_of_string arg)
  | "GET"  -> Get  inst_get
  | "OUT"  -> Out  inst_out
  | "LBL"  -> Lbl  arg
  | "JNZ"  -> Jnz  arg
  | "SET"  -> Set  (int_of_string arg)
  | "CELL" -> Cell (int_of_string arg)
  | "JMP"  -> Jmp  arg
  | "STOP" -> Stop
  | ";"    -> raise Comment   (* It shouldn't reach this point *)
  | _ -> raise (UnknownInstruction s)


let tokenize (table, lines) =
  let () = _debug "%s\n" "tokenize()" in
  let index = Hashtbl.create _default_index_size in
  let code = Array.init lines (
    fun i ->
      let inst = Hashtbl.find table i |> instruction_of_string in
      let () = match inst with
      | Lbl arg -> Hashtbl.add index arg i
      | _       -> ()
      in inst
  ) in {code = code; index = index}


let get_program () =
  let () = _debug "%s\n" "get_program()" in
  let code = Hashtbl.create _default_code_size in
  let rec try_read i =
    try
      let s = read_line () in
      (* let () = _code "%05d\t%s\n" i s in *)
      if s <> "" && s.[0] <> ';' then
        let () = Hashtbl.add code i s
        in try_read (i + 1)
      else try_read i
    with End_of_file -> i
  in let lines = try_read 0 in
  let () = _debug "%d lines were read.\n" lines in
    (code, lines)


(* Auxiliary debug functions *)
let print_code  = Array.iteri (fun i s -> Printf.printf "\t%05d\t%s\n" i (string_of_instruction s))
let print_index = Hashtbl.iter (fun s i -> Printf.printf "\t%05d\t%20s\n" i s)

(* Main block *)
let () =
  let () = print_endline "BUBAL 0.0.0-alpha, by Igor Nunes" in
  let program = get_program () |> tokenize in
  let () = _debug "Label Index:\n" in
  let () = print_index program.index in
  let () = print_endline "\nLoading the BUBAL machine...\n" in
  let t = new tape in
  let mach = new machine program t in
  let () = print_endline "=== RUN ===\n" in
  let () = mach#run () in
    print_endline "\n===========\nDone!"

(*
  With contributions from
  https://stackoverflow.com/questions/13410159/how-to-read-a-character-in-ocaml-without-a-return-key
*)