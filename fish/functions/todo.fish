function todo
  # find .taskell file in current dir on parent dirs
  set TASKELL_FILE .taskell
  while test ! -f $TASKELL_FILE
    set TASKELL_FILE ../$TASKELL_FILE
  end

  if test -f $TASKELL_FILE
    taskell $TASKELL_FILE
  else
    echo "No .taskell file found"
    return 1
  end
end
