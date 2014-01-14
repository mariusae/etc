val () = 
  let
    val args = (CommandLine.name(), CommandLine.arguments())
  in
    OS.Process.exit (Main.main args)
  end
