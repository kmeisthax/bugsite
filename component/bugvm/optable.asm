INCLUDE "bugsite.inc"

SECTION "BugVM Opcode Table", ROM0[$3E00]
BugVM_OpcodeTable::
    dw $5E9,$5E9,$5E9,$671,$5E9,$5E9,$68C,$6C0; 0
    dw $6CA,$6D7,$6E2,$6ED,$6F8,$705,$712,$723; 8
    dw $752,$763,$772,$784,$796,$7A1,$7A9,$7C3; 16
    dw $7ED,$80B,$80C,$80D,$80E,$80F,$820,PatchSupport_OpCustom; 24
    dw PatchSupport_OpCustom,PatchSupport_OpCustom,PatchSupport_OpCustom,PatchSupport_OpCustom,PatchSupport_OpCustom,PatchSupport_OpCustom,PatchSupport_OpCustom,PatchSupport_OpCustom; 32
    dw PatchSupport_OpCustom,PatchSupport_OpCustom,PatchSupport_OpCustom,PatchSupport_OpCustom,$831,$5E9,$5E9,$835; 40
    dw $836,$837,$838,$839,$83A,$87B,$87C,$887; 48
    dw $8AC,$8BB,$8DB,$8DC,$8DD,$8DE,$941,$8F0; 56
    dw $919,$91A,$5E9,$5E9,$93C,$93D,$93E,$550; 64
    dw $540,$93F,$19E6,$1A3D,$A84,$962,$3749,$375D; 72
    dw $C54,$973,$4174,$4189,$AA0,$AA1,$AA2,$AA3; 80
    dw $AA4,$ABF,$AED,$97C,$98C,$2D72,$2E22,$9C6; 88
    dw $A12,$A29,$21BE,$21D1,$5E9,$1B2D,$5E9,$A49; 96
    dw $23C5,$2527,$91B,$83B,$1334,$141E,$2775,$2788; 104
    dw $13B4,$1497,$1BAC,$5E9,$210D,$2F0E,$C78,$A8B; 112
    dw $3269,$27BB,$19ED,$2D8D,$3739,$C24,$C63,$264C; 120
    dw $15C3,$5E9,$ADA,$5E9,$1620,$1D1C,$1C92,$1621; 128
    dw $133C,$1629,$1659,$398,$324F,$265C,$289C,$2161; 136
    dw $483,$484,$27B3,$485,$486,$487,$399,$5E9; 144
    dw $5E9,$488,$5E9,$39B,$39A,$3761,$3768,$165A; 152
    dw $42A,$1668,$3FE,$540,$550,$162A,$235E,$2386; 160
    dw $1FF2,$482,$166F,$2E77,$2FE,$B05,$397,$1622; 168
    dw $1677,$1670,$B2D,$AFC,$B1B,$26D9,$586,$596; 176
    dw $3849,$3893,$38C9,$39C,$BB2,$15F,$2F7A,$2F99; 184
    dw $168D,$169C,$395,$396,$48E,$26AD,$27D8,$206C; 192
    dw $20B9,$20C2,$393,$32C7,$32D5,$394,$1D07,$2877; 200
    dw $2F9E,$2FA4,$A39,$5E9,$5E9,$48A,$48B,$48C; 208
    dw $48D,$A1D,$3C8B,$16BC,$16D2,$16E2,$1700,$5E9; 216
    dw $18CA,$1715,$456,$1661,$1631,$1638,$3901,$560; 224
    dw $573,$20E3,$163F,$4A9,$4B6,$4C3,$4F9,$4DE; 232
    dw $516,$3CD,$533,$20CB,$B10,$272C,$2702,$3CAD; 240
    dw $2137,$2DF1,$16AB,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF; 255