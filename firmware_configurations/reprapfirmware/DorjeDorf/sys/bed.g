; bed.g
; called to perform automatic bed compensation via G32
;
; generated by RepRapFirmware Configuration Tool v3.1.3 on Sun Jul 12 2020 20:53:52 GMT+0200 (Central European Summer Time)
M561 ; clear any bed transform

; Home, but only if homing is needed
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  G28

M98 P"/macros/Home/z_current_low.g"

while true
  if iterations = 5
    abort "Too many auto calibration attempts"
  
  G30 K0 P0 X15 Y25 Z-99999 ; probe near front left belt
  if result != 0
    continue
  
  G30 K0 P1 X15 Y265 Z-99999 ; probe near back left belt
  if result != 0
    continue
  
  G30 K0 P2 X255 Y265 Z-99999 ; probe near back right belt 
  if result != 0
    continue

  G30 K0 P3 X255 Y25 Z-99999 S4 ; probe near front right belt 
  if result != 0
    continue


  if move.calibration.initial.deviation <= 0.01
    break

  ; If there were too many errors or the deviation is too high - abort and notify user  
  echo "Repeating calibration because deviation is too high (" ^ move.calibration.initial.deviation ^ "mm)"
; end loop
echo "Auto calibration successful, deviation", move.calibration.initial.deviation ^ "mm"

M98 P"/macros/Home/z_current_high.g"

; Perform nozzle cleaning
M98 P"/macros/Maintenance/nozzle_brush.g"

; rehome z
G28 Z