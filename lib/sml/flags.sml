signature FLAGS = sig
  type 'a flagger = string*'a*string -> 'a ref
  exception FlagAlreadyDefined
  
  val int: int flagger
  val bool: bool flagger
  val string: string flagger
  
  val printDoc: unit -> unit
  
  val args: unit -> string list
  
  val parse: string*string list -> unit
end

structure Flags:> FLAGS = 
struct

type 'a flagger = string*'a*string -> 'a ref
exception FlagAlreadyDefined

type flag = {
  flag: string, 
  doc: string,
  set: string -> bool, 
  show: unit -> string
}

val flags: flag list ref = ref []
val argv: string list ref = ref []
val name = ref ""

local
  fun mk (p: string -> 'a option, s: 'a -> string): (string*'a*string -> 'a ref) =
    fn (f, def, doc) =>
      let
        val r = ref def
        fun set v =
          case p v of
            SOME v' => true before (r := v')
          | NONE => false
        fun show () = s (!r)
      in
        if (List.exists (fn {flag, ...} => flag=f) (!flags)) 
          then raise FlagAlreadyDefined 
          else ();
        flags := {flag=f, doc=doc, set=set, show=show} :: !flags;
        r
      end
  fun parseBool "" = SOME true
  | parseBool x = Bool.fromString x
in
  val int = mk (Int.fromString, Int.toString)
  val string = mk (String.fromString, String.toString)
  val bool = mk (parseBool, Bool.toString)
end

val helpFlag = bool ("help", false, "show help")
 
fun printDoc () =
  let
    val banner = (!name)^":"
  in
    print (banner^"\n") before print' (!flags)
  end
and print' nil = ()
  | print' ({flag, doc, show, ...}::fs) = 
      (print ("  -"^flag^"="^(show ())^": "^doc^"\n")) before (print' fs)

fun args () = !argv

fun parse (name', args) = (
  name := name';
  argv := [];
  parse' args;
  argv := List.rev (!argv);
   if (!helpFlag) then (printDoc (); OS.Process.terminate OS.Process.success) else ()
)

and parse' nil = ()
  | parse' (f::fs) =
      if parseOne f then parse' fs else
        (argv := f :: !argv) before parse' fs

and parseOne f =
  let
    val (f', a) = split f
    val f'' = if isFlag f' then SOME (String.extract(f', 1, NONE)) else NONE
    val f''' = (Option.join o Option.map flagOf) f''
  in
    case f''' of
      SOME set => set(a)
    | NONE => false
  end

and flagOf which = 
  let 
    val f = List.find (fn x => (#flag x) = which) (!flags)
  in
    Option.map #set f
  end

and split f =
  case String.fields (fn x => x = #"=") f of
    a :: b :: nil => (a, b)
  | a :: bs => (a, String.concat bs)
  | nil => raise Match

and isFlag f = String.isPrefix "-" f

end
