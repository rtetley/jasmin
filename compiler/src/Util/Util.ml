(* * Utility functions (mostly for testing) *)

(* ** Imports and abbreviations *)
open Core_kernel.Std

module F = Format

let pp_bool fmt b = F.fprintf fmt "%s" (if b then "true" else "false")

let pp_string fmt s = F.fprintf fmt "%s" s

let pp_pair sep ppa ppb fmt (a,b) = F.fprintf fmt "%a%s%a" ppa a sep ppb b

let rec pp_list sep pp_elt f l =
  match l with
  | [] -> ()
  | [e] -> pp_elt f e
  | e::l -> F.fprintf f "%a%(%)%a" pp_elt e sep (pp_list sep pp_elt) l

(* FIXME: add "tacerror" like function *)

let fsprintf fmt =
  let buf  = Buffer.create 127 in
  let fbuf = F.formatter_of_buffer buf in
  F.kfprintf
    (fun _ ->
      F.pp_print_flush fbuf ();
      (Buffer.contents buf))
    fbuf fmt

let linit l = List.rev l |> List.tl_exn |> List.rev

let equal_pair equal_a equal_b (a1,b1) (a2, b2) =
  equal_a a1 a2 && equal_b b1 b2

let equal_list equal_elem xs ys =
  List.length xs = List.length ys &&
  List.for_all2_exn ~f:equal_elem xs ys

let get_opt def o = Option.value ~default:def o

(* ** Exceptional functions with more error reporting
 * ------------------------------------------------------------------------ *)

let map_find_exn ?(err=failwith) m pp pr =
  match Map.find m pr with
  | Some x -> x
  | None ->
    let bt = try raise Not_found with _ -> Backtrace.get () in
    err (fsprintf "map_find_exn %a failed, not in domain:\n%a\n%s"
           pp pr (pp_list "," pp) (Map.keys m)
           (Backtrace.to_string bt))

let list_map2_exn ~err ~f xs ys =
  try List.map2_exn ~f xs ys
  with Invalid_argument _ -> 
    err (List.length xs) (List.length ys)

let list_iter2_exn ~err ~f xs ys =
  try List.iter2_exn ~f xs ys
  with Invalid_argument _ -> 
    err (List.length xs) (List.length ys)

let hashtbl_find_exn ?(err=failwith) m pp pr =
  match Hashtbl.find m pr with
  | Some x -> x
  | None ->
    err (fsprintf "map_find_preg %a failed, not in domain:\n%a"
           pp pr (pp_list "," pp) (Hashtbl.keys m))
