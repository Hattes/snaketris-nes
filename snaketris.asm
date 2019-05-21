  .inesprg 1 ; 1x 16KB PRG
  .ineschr 1 ; 1x 8KB CHR
  .inesmap 0 ; NROM, no bank swapping
  .inesmir 1 ; background mirroring - TODO figure out why this matters


RESET:


NMI:






  .org $FFFA ; where interrupt vectors are stored
  .dw NMI    ; dw = data word, i.e. two bytes
  .dw RESET
  .dw 0      ; TODO figure out if I need external interrupt IRQ


  .bank 2    ; TODO figure out what this really does
  .org $0000 ; point to first point in memory
  .incbin "snaketris.chr"