  .inesprg 1 ; 1x 16KB PRG
  .ineschr 1 ; 1x 8KB CHR
  .inesmap 0 ; NROM, no bank swapping
  .inesmir 1 ; background mirroring - TODO figure out why this matters


;; DECLARE SOME VARIABLES HERE
  .rsset $0000  ;;start variables at ram location 0
  
gamestate  .rs 1  ; .rs 1 means reserve one byte of space
score 	 .rs 2
level      .rs 1
lines      .rs 2


RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2



LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down

NMI:






palette:
  .db $1A,$2A,$30,$0F,  $15,$07,$30,$0F,  $11,$02,$30,$0F;,  ;$22,$27,$17,$0F   ;;background palette
  .db $22,$1C,$15,$14,  $15,$07,$30,$0F;,  ;$22,$1C,$15,$14,  $22,$02,$38,$3C   ;;sprite palette




  .org $FFFA ; where interrupt vectors are stored
  .dw NMI    ; dw = data word, i.e. two bytes
  .dw RESET
  .dw 0      ; TODO figure out if I need external interrupt IRQ


  .bank 2    ; TODO figure out what this really does
  .org $0000 ; point to first point in memory
  .incbin "snaketris.chr"