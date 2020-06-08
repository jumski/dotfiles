# grc overides for ls
if which gls &>/dev/null
  function ls
    gls -F --color
  end

  function l
    gls -lAh --color
  end

  function ll
    gls -l --color
  end

  function la
    gls -A --color
  end
end
