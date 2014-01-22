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
  case s of
    "Jan" => SOME Date.Jan | "Feb" => SOME Date.Feb | "Mar" => SOME Date.Mar
  | "Apr" => SOME Date.Apr | "May" => SOME Date.May | "Jun" => SOME Date.Jun
  | "Jul" => SOME Date.Jul | "Aug" => SOME Date.Aug | "Sep" => SOME Date.Sep
  | "Oct" => SOME Date.Oct | "Nov" => SOME Date.Nov | "Dec" => SOME Date.Dec
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
