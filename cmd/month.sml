structure Main =
struct

exception BadMonth

local
  val oneDay = Time.fromSeconds (60*60*24)
  open Time
  open Date
in
  fun day1 d = fromTimeLocal ((toTime d)+oneDay)
end

val lower = String.implode o map Char.toLower o String.explode

fun weekDayString d =
  case d of 
    Date.Mon => "Mon" | Date.Tue => "Tue" | Date.Wed => "Wed" | Date.Thu => "Thu"
  | Date.Fri => "Fri" | Date.Sat => "Sat" | Date.Sun => "Sun"

fun monthString m =
  case m of
    Date.Jan => "Jan" | Date.Feb => "Feb" | Date.Mar => "Mar" | Date.Apr => "Apr"
  | Date.May => "May" | Date.Jun => "Jun" | Date.Jul => "Jul" | Date.Aug => "Aug"
  | Date.Sep => "Sep" | Date.Oct => "Oct" | Date.Nov => "Nov" | Date.Dec => "Dec"


fun monthFromString s =
  case lower s of
    "jan" => SOME Date.Jan | "feb" => SOME Date.Feb | "mar" => SOME Date.Mar
  | "apr" => SOME Date.Apr | "may" => SOME Date.May | "jun" => SOME Date.Jun
  | "jul" => SOME Date.Jul | "aug" => SOME Date.Aug | "sep" => SOME Date.Sep
  | "oct" => SOME Date.Oct | "nov" => SOME Date.Nov | "dec" => SOME Date.Dec
  | _ => raise BadMonth


fun printDate d =
  let
    val wd = Date.weekDay d
    val day = Date.day d
  in
    print ((Int.toString day)^" "^(weekDayString wd)^"\n")
  end

fun enum first =
  let
    val month = Date.month first
    fun go d =
      let
        val month' = Date.month d
        val t = Date.toTime d
        val d' = day1 d
      in
        if month <> month' then () 
        else printDate d before go d'
      end
  in
    go first
  end
  
fun usage () = 
  OS.Process.failure

fun main (name, [month, year]) =
  let
    val m = monthFromString month
    val y = Int.fromString year
  in
    case (m, y) of
      (SOME m, SOME y) => main' (m, y)
    | _ => usage ()
  end
| main (name, [month]) = main (name, [month, "2014"])
| main (name, nil) = main (name, ["Jan", "2014"])
| main (name, _) = usage()

and main' (m, y) =
  let
    val first = Date.date {
      year = y, month = m, day = 1, 
      hour = 0, minute = 0, second = 0, 
      offset = NONE}
  in
    enum first;
    OS.Process.success
  end

end
