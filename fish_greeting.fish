function fish_greeting -d "What's up, fish?"
  set_color brgrey
  uname -npsr
  uptime | sed -e 's/^[[:space:]]*//'
  echo ""
  set_color normal
end
