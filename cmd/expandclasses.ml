open Core.Std
open Printf

exception Invalid_line

let rec seekline ic l =
  let l' = input_line ic in
  if l <> l' then seekline ic l

let rec readlines ic ls =
  try
    let l = input_line ic in
    readlines ic (l::ls)
  with End_of_file ->
    List.rev ls

let readone f = 
  In_channel.with_file f ~f:(fun ic ->
    let () = seekline ic "class names:" in
    let ls = readlines ic [] in
    List.map ~f:(fun l ->
      let l = String.strip l in
      match String.split l ~on:' ' with
      | [f; "->"; c] -> (c, f)
      | _ -> raise Invalid_line
    ) ls
  )

let rec tails = function
| [] -> []
| hd :: [] -> [[hd]]
| hd :: tl -> [hd] :: (tails tl |> List.map ~f:(fun tl -> hd :: tl))

let candidatesof s =
  String.split s ~on:'.' |> 
  tails |> 
  List.map ~f:(String.concat ~sep:".") |>
  List.rev

let candidates s = 
  String.split s ~on:' ' |> List.concat_map ~f:candidatesof

let substr sub str =
  let n = String.length sub in
  let m = String.length str in

  let rec isprefix i j =
    if i = n then true 
    else if sub.[i] = str.[j] then isprefix (i+1) (j+1)
    else false
  in

  let rec go j =
    if j > (m-n) then -1
    else if isprefix 0 j then j
    else go (j+1)
  in

  go 0

let rec scandigits s i =
  if i = (String.length s) then [] else
  match Char.get_digit s.[i] with
  | Some d -> d :: scandigits s (i+1)
  | None -> []

let mknum ds = 
  let rec go m = function
  | [] -> 0
  | d :: ds -> d*m + (go (m*10) ds)
  in go 1 (List.rev ds)

let scannum s i =
  match scandigits s i with
  | [] -> None
  | ds -> Some (mknum ds)

let scanlnum s i =
  if i >= (String.length s) || s.[i] <> ':' then None else scannum s (i+1)

let rec process tab ic =
  match In_channel.input_line ic with
  | None -> ()
  | Some l -> 
    let matches = candidates l |> 
      List.filter_map ~f:(Hashtbl.find tab) |>
      List.concat_map ~f:(fun found ->
        let base = Filename.basename found in
        let basei = substr base l in
        scanlnum l (basei + (String.length base)) |> Option.to_list |>
        List.map ~f:(fun n ->
          let pre = String.slice l 0 basei in
          let post = String.slice l (basei+(String.length base)) (String.length l) in
          String.concat_array [|pre(*;"@ "*);found;post|]
        );
      ) in

    let l' = match matches with 
      | fst :: _ ->  fst
      | _ -> l in
      
    Out_channel.output_string stdout l';
    Out_channel.newline stdout;
    Out_channel.flush stdout;

    process tab ic

let () =
  let basedir = Sys.argv.(1) in
  let pantsdir = basedir ^/ ".pants.d/scalac/analysis_cache" in
  try
    let ents = Array.to_list (Sys.readdir pantsdir) |> 
      List.map ~f:( fun e -> pantsdir ^/ e) |> 
      List.filter ~f:(fun e -> String.is_suffix e ~suffix:".relations") |> 
      List.concat_map ~f:readone |>
      List.map ~f:(fun (c, f) -> (c, basedir ^/ f)) in
    let tab = Hashtbl.of_alist_exn ents ~hashable:String.hashable in
    process tab stdin

  with _ ->
    (* Conservatively act as 'cat' *)
    In_channel.iter_lines stdin ~f:(fun l ->
      Out_channel.output_string stdout l;
      Out_channel.newline stdout;
      Out_channel.flush stdout
    )
