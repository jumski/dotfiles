M862.3 P "[printer_model]" ; printer model check
M862.1 P[nozzle_diameter] ; nozzle diameter check
M115 U3.9.0 ; tell printer latest fw version
G90 ; use absolute coordinates
M83 ; extruder relative mode

M104 S160 ; set extruder temp BEFORE BED LEVEL

M140 S[first_layer_bed_temperature] ; set bed temp
M190 S[first_layer_bed_temperature] ; wait for bed temp

M109 S160 ; wait for extruder temp TEMP 160 instead of first_layer temp

G28 W ; home all without mesh bed level
M104 S[first_layer_temperature]  ; set extruder temp
G80 ; mesh bed leveling
M109 S[first_layer_temperature] ; wait for extruder temp

G1 Y-3.0 F1000.0 ; go outside print area
G92 E0.0
G1 X60.0 E9.0 F1000.0 ; intro line
G1 X100.0 E12.5 F1000.0 ; intro line
G92 E0.0
M221 S{if layer_height<0.075}100{else}95{endif}

; Don't change E values below. Excessive value can damage the printer.
{if print_settings_id=~/.*(DETAIL @MK3|QUALITY @MK3).*/}M907 E430 ; set extruder motor current{endif}
{if print_settings_id=~/.*(SPEED @MK3|DRAFT @MK3).*/}M907 E538 ; set extruder motor current{endif}
