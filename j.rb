def loo
  @_str = "\e[1;33m Wait "
  system 'ping www.google.com &'
  for i in 1..100 do
    printf("\r#{@_str}|")
    printf("\r\e[0m")
    sleep(0.1)
    printf("\r#{@_str}/")
    printf("\r\e[0m")
    sleep(0.1)
    printf("\r#{@_str}-")
    printf("\r\e[0m")
    sleep(0.1)
    printf("\r#{@_str}\\")
    printf("\r\e[0m")
    sleep(0.1)
    printf("\r#{@_str}|")
    printf("\r\e[0m")
  end
  loo
end
loo