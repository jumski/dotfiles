; Match console.log and apply a muted highlight group
((call_expression
  function: (member_expression
    object: (identifier) @console_log (#eq? @console_log "console")
    property: (property_identifier) @log_method (#eq? @log_method "log")))
 @ConsoleLog)
