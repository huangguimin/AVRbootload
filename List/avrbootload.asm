
;CodeVisionAVR C Compiler V2.05.0 Professional
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega128
;Program type             : Boot Loader
;Clock frequency          : 16.000000 MHz
;Memory model             : Small
;Optimize for             : Size
;(s)printf features       : int, width
;(s)scanf features        : int, width
;External RAM size        : 0
;Data Stack size          : 1024 byte(s)
;Heap size                : 0 byte(s)
;Promote 'char' to 'int'  : Yes
;'char' is unsigned       : No
;8 bit enums              : No
;global 'const' stored in FLASH: Yes
;Enhanced core instructions    : On
;Smart register allocation     : On
;Automatic register allocation : On

	#pragma AVRPART ADMIN PART_NAME ATmega128
	#pragma AVRPART MEMORY PROG_FLASH 131072
	#pragma AVRPART MEMORY EEPROM 4096
	#pragma AVRPART MEMORY INT_SRAM SIZE 4351
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU RAMPZ=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU XMCRA=0x6D
	.EQU XMCRB=0x6C

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x10FF
	.EQU __DSTACK_SIZE=0x0400
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

	.CSEG
	.ORG 0xF000

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000
	JMP  0xF000

_startupString:
	.DB  0x54,0x79,0x70,0x65,0x20,0x27,0x64,0x27
	.DB  0x20,0x64,0x6F,0x77,0x6E,0x6C,0x6F,0x61
	.DB  0x64,0x2C,0x20,0x4F,0x74,0x68,0x65,0x72
	.DB  0x73,0x20,0x72,0x75,0x6E,0x20,0x61,0x70
	.DB  0x70,0x2E,0xA,0xD,0x0
_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF THE BOOT LOADER
	LDI  R31,1
	OUT  MCUCR,R31
	LDI  R31,2
	OUT  MCUCR,R31
	STS  XMCRB,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

	LDI  R24,1
	OUT  RAMPZ,R24

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x500

	.CSEG
;/*****************************************************
;采用串行接口实现Boot_load应用的实例
;华东师大电子系 马 潮 2004.07
;Compiler:    ICC-AVR 6.31
;Target:    Mega128
;Crystal:    16Mhz
;Used:        T/C0,USART0
;*****************************************************/
;#include <mega128.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif
;#include <delay.h>
;#include <stdio.h>
;
;//#define UPDATE_USB      1
;
;
;
;#define SPM_PAGESIZE 256          //M128的一个Flash页为256字节(128字)
;#define BAUD 38400                //波特率采用38400bps
;#define CRYSTAL 16000000          //系统时钟16MHz
;
;//计算和定义M128的波特率设置参数
;#define BAUD_SETTING (unsigned char)((unsigned long)CRYSTAL/(16*(unsigned long)BAUD)-1)
;#define BAUD_H (unsigned char)(BAUD_SETTING>>8)
;#define BAUD_L (unsigned char)BAUD_SETTING
;#define DATA_BUFFER_SIZE SPM_PAGESIZE        //定义接收缓冲区长度
;
;//定义Xmoden控制字符
;#define XMODEM_NUL 0x00
;#define XMODEM_SOH 0x01
;#define XMODEM_STX 0x02
;#define XMODEM_EOT 0x04
;#define XMODEM_ACK 0x06
;#define XMODEM_NAK 0x15
;#define XMODEM_CAN 0x18
;#define XMODEM_EOF 0x1A
;#define XMODEM_RECIEVING_WAIT_CHAR 'C'
;
;//定义全局变量
;const uchar startupString[]="Type 'd' download, Others run app.\n\r";
;/*
;const uchar a4String1[]="AT+UART=38400,0,0\r\n\0";
;const uchar a4String2[]="AT+UART?\r\n\0";
;*/
;uchar data[DATA_BUFFER_SIZE];
;unsigned long address = 0;
;
;#pragma warn-
;//擦除(code=0x03)和写入(code=0x05)一个Flash页
;void boot_page_ew(uint p_address, uchar code)
; 0000 0032 {

	.CSEG
_boot_page_ew:
; 0000 0033         RAMPZ = 0;
;	p_address -> Y+1
;	code -> Y+0
	LDI  R30,LOW(0)
	OUT  0x3B,R30
; 0000 0034 
; 0000 0035     #asm
; 0000 0036         ldd r30,y+1
        ldd r30,y+1
; 0000 0037         ldd r31,y+2
        ldd r31,y+2
; 0000 0038         ld r20,y
        ld r20,y
; 0000 0039         STS 0X68,r20
        STS 0X68,r20
; 0000 003A     #endasm
; 0000 003B     #asm("spm");                    //对指定Flash页进行操作
	spm
; 0000 003C 
; 0000 003D }
	ADIW R28,3
	RET
;#pragma warn+
;
;#pragma warn-
;//填充Flash缓冲页中的一个字
;void boot_page_fill(uint address,uint data)
; 0000 0043 {
_boot_page_fill:
; 0000 0044     #asm
;	address -> Y+2
;	data -> Y+0
; 0000 0045         ldd r30,y+2  //Z寄存器中为缓冲页地址
        ldd r30,y+2  //Z寄存器中为缓冲页地址
; 0000 0046         ldd r31,y+3
        ldd r31,y+3
; 0000 0047         ld r0,y
        ld r0,y
; 0000 0048         ldd r1,y+1   //R0R1中为一个字的数据
        ldd r1,y+1   //R0R1中为一个字的数据
; 0000 0049         LDI r20,0x01
        LDI r20,0x01
; 0000 004A         STS 0X68,r20
        STS 0X68,r20
; 0000 004B     #endasm
; 0000 004C     #asm("spm");   //将R0R1中的数据写入Z寄存器中的缓冲页地址
	spm
; 0000 004D }
	RJMP _0x2060002
;#pragma warn+
;
;#pragma warn-
;//等待一个Flash页的写完成
;void wait_page_rw_ok(void)
; 0000 0053 {
_wait_page_rw_ok:
; 0000 0054       while(SPMCSR & 0x40)
_0x3:
	LDS  R30,104
	ANDI R30,LOW(0x40)
	BREQ _0x5
; 0000 0055      {
; 0000 0056          while(SPMCSR & 0x01);
_0x6:
	LDS  R30,104
	ANDI R30,LOW(0x1)
	BRNE _0x6
; 0000 0057          SPMCSR = 0x11;
	LDI  R30,LOW(17)
	STS  104,R30
; 0000 0058          #asm
; 0000 0059             spm
            spm
; 0000 005A          #endasm
; 0000 005B      }
	RJMP _0x3
_0x5:
; 0000 005C }
	RET
;#pragma warn+
;//更新一个Flash页的完整处理
;void write_one_page(void)
; 0000 0060 {
_write_one_page:
; 0000 0061     uint i;
; 0000 0062     boot_page_ew(address,0x03);                    //擦除一个Flash页
	ST   -Y,R17
	ST   -Y,R16
;	i -> R16,R17
	CALL SUBOPT_0x0
	LDI  R30,LOW(3)
	ST   -Y,R30
	RCALL _boot_page_ew
; 0000 0063     wait_page_rw_ok();                            //等待擦除完成
	RCALL _wait_page_rw_ok
; 0000 0064     for(i=0;i<SPM_PAGESIZE;i+=2)                //将数据填入Flash缓冲页中
	__GETWRN 16,17,0
_0xA:
	__CPWRN 16,17,256
	BRSH _0xB
; 0000 0065     {
; 0000 0066         boot_page_fill(i, (data[i]|((uint)(data[i+1])<<8)));
	ST   -Y,R17
	ST   -Y,R16
	LDI  R26,LOW(_data)
	LDI  R27,HIGH(_data)
	ADD  R26,R16
	ADC  R27,R17
	LD   R26,X
	CLR  R27
	MOVW R30,R16
	__ADDW1MN _data,1
	LD   R31,Z
	LDI  R30,LOW(0)
	OR   R30,R26
	OR   R31,R27
	ST   -Y,R31
	ST   -Y,R30
	RCALL _boot_page_fill
; 0000 0067     }
	__ADDWRN 16,17,2
	RJMP _0xA
_0xB:
; 0000 0068     boot_page_ew(address,0x05);                    //将缓冲页数据写入一个Flash页
	CALL SUBOPT_0x0
	LDI  R30,LOW(5)
	ST   -Y,R30
	RCALL _boot_page_ew
; 0000 0069     wait_page_rw_ok();                            //等待写入完成
	RCALL _wait_page_rw_ok
; 0000 006A }
	RJMP _0x2060001
;//从RS232发送一个字节
;void uart_putchar(uchar c)
; 0000 006D {
_uart_putchar:
; 0000 006E     while(!(UCSR0A & 0x20));
;	c -> Y+0
_0xC:
	SBIS 0xB,5
	RJMP _0xC
; 0000 006F     UDR0 = c;
	LD   R30,Y
	OUT  0xC,R30
; 0000 0070 }
	ADIW R28,1
	RET
;
;void USART_Send_string(flash uchar *data)
; 0000 0073 {
_USART_Send_string:
; 0000 0074     uint i = 0;
; 0000 0075     while(data[i] != '\0')
	ST   -Y,R17
	ST   -Y,R16
;	*data -> Y+2
;	i -> R16,R17
	__GETWRN 16,17,0
_0xF:
	MOVW R30,R16
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADD  R30,R26
	ADC  R31,R27
	ELPM R30,Z
	CPI  R30,0
	BREQ _0x11
; 0000 0076     uart_putchar(data[i++]);
	MOVW R30,R16
	__ADDWRN 16,17,1
	ADD  R30,R26
	ADC  R31,R27
	ELPM R30,Z
	ST   -Y,R30
	RCALL _uart_putchar
	RJMP _0xF
_0x11:
; 0000 0077 }
	LDD  R17,Y+1
	LDD  R16,Y+0
_0x2060002:
	ADIW R28,4
	RET
;//从RS232接收一个字节
;int uart_getchar(void)
; 0000 007A {
_uart_getchar:
; 0000 007B     unsigned char status,res;
; 0000 007C     if(!(UCSR0A & 0x80)) return -1;
	ST   -Y,R17
	ST   -Y,R16
;	status -> R17
;	res -> R16
	SBIC 0xB,7
	RJMP _0x12
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x2060001
; 0000 007D     status = UCSR0A;
_0x12:
	IN   R17,11
; 0000 007E     res = UDR0;
	IN   R16,12
; 0000 007F     if (status & 0x1c) return -1;        // If error, return -1
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BREQ _0x13
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x2060001
; 0000 0080     return res;
_0x13:
	MOV  R30,R16
	LDI  R31,0
	RJMP _0x2060001
; 0000 0081 }
;//等待从RS232接收一个有效的字节
;uchar uart_waitchar(void)
; 0000 0084 {
_uart_waitchar:
; 0000 0085     int c;
; 0000 0086     do
	ST   -Y,R17
	ST   -Y,R16
;	c -> R16,R17
_0x15:
; 0000 0087     {
; 0000 0088         c=uart_getchar();
	RCALL _uart_getchar
	MOVW R16,R30
; 0000 0089     }
; 0000 008A     while(c==-1);
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	CP   R30,R16
	CPC  R31,R17
	BREQ _0x15
; 0000 008B     return (uchar)c;
	MOV  R30,R16
_0x2060001:
	LD   R16,Y+
	LD   R17,Y+
	RET
; 0000 008C }
;//计算CRC
;uint calcrc(uchar *ptr, uchar count)
; 0000 008F {
_calcrc:
; 0000 0090     uint recalcrc = 0;
; 0000 0091     uchar i,j = 0;
; 0000 0092 
; 0000 0093     while (count >= ++j)
	CALL __SAVELOCR4
;	*ptr -> Y+5
;	count -> Y+4
;	recalcrc -> R16,R17
;	i -> R19
;	j -> R18
	__GETWRN 16,17,0
	LDI  R18,0
_0x17:
	SUBI R18,-LOW(1)
	LDD  R26,Y+4
	CP   R26,R18
	BRLO _0x19
; 0000 0094     {
; 0000 0095         recalcrc = recalcrc ^ (uint)*ptr++ << 8;
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	LD   R30,X+
	STD  Y+5,R26
	STD  Y+5+1,R27
	MOV  R31,R30
	LDI  R30,0
	__EORWRR 16,17,30,31
; 0000 0096         i = 8;
	LDI  R19,LOW(8)
; 0000 0097         do
_0x1B:
; 0000 0098         {
; 0000 0099             if (recalcrc & 0x8000)
	SBRS R17,7
	RJMP _0x1D
; 0000 009A                 recalcrc = recalcrc << 1 ^ 0x1021;
	MOVW R30,R16
	LSL  R30
	ROL  R31
	LDI  R26,LOW(4129)
	LDI  R27,HIGH(4129)
	EOR  R30,R26
	EOR  R31,R27
	MOVW R16,R30
; 0000 009B             else
	RJMP _0x1E
_0x1D:
; 0000 009C                 recalcrc = recalcrc << 1;
	LSL  R16
	ROL  R17
; 0000 009D         }while(--i);
_0x1E:
	SUBI R19,LOW(1)
	CPI  R19,0
	BRNE _0x1B
; 0000 009E     }
	RJMP _0x17
_0x19:
; 0000 009F     return recalcrc;
	MOVW R30,R16
	CALL __LOADLOCR4
	ADIW R28,7
	RET
; 0000 00A0 }
;
;#ifdef  UPDATE_USB
;//----------------------------------------------U盘模式-----------------------------------------------------------------
;
;/* 附加的USB操作状态定义 */
;#define		ERR_USB_UNKNOWN		0xFA	/* 未知错误,不应该发生的情况,需检查硬件或者程序错误 */
;#define		TRUE	1
;#define		FALSE	0
;#define	SER_SYNC_CODE1		0x57			/* 启动操作的第1个串口同步码 */
;#define	SER_SYNC_CODE2		0xAB			/* 启动操作的第2个串口同步码 */
;#define	CMD01_GET_STATUS	0x22			/* 获取中断状态并取消中断请求 */
;#define	CMD0H_DISK_CONNECT	0x30			/* 主机文件模式/不支持SD卡: 检查磁盘是否连接 */
;#define	CMD0H_DISK_MOUNT	0x31			/* 主机文件模式: 初始化磁盘并测试磁盘是否就绪 */
;
;/************串口1发送一个数据********************/
;
;void USART_Send_word_1(uchar data)
;{
;    while (!(UCSR1A & (1<<UDRE1)));        //等待发送缓冲器为空；
;    UDR1 = data;        //将数据放入缓冲器，发送数据；
;}
;
;uchar USART_Receive_1(void)
;{
;// 等待接收数据
;    uint i = 0;
;    while(!(UCSR1A & (1<<RXC1))){if((++i)>65530)return 0;};
;    return UDR1;
;}
;/*
;void USART_Send_string_1(uchar *data,uchar length)
;{
;    uchar i;
;   for(i = 0; i < length; i++)
;    USART_Send_word_1(data[i]);
;}*/
;
;void xWriteCH376Cmd(uchar mCmd)  /* 向CH376写命令 */
;{
;	USART_Send_word_1(SER_SYNC_CODE1);
;    USART_Send_word_1(SER_SYNC_CODE2);  /* 启动操作的第2个串口同步码 */
;	USART_Send_word_1(mCmd);  /* 串口输出 */
;}
;
;void xWriteCH376Data(uchar mData)  /* 向CH376写数据 */
;{
;	USART_Send_word_1(mData);  /* 串口输出 */
;}
;
;uchar xReadCH376Data( void )  /* 从CH376读数据 */
;{
;	return USART_Receive_1();  /* 串口输入 */
;}
;
;uchar CH376GetIntStatus( void )  /* 获取中断状态并取消中断请求 */
;{
;	uchar	s;
;	xWriteCH376Cmd(CMD01_GET_STATUS);
;	s = xReadCH376Data();
;	return(s);
;}
;
;uchar Wait376Interrupt(void)  /* 等待CH376中断(INT#低电平)，返回中断状态码, 超时则返回ERR_USB_UNKNOWN */
;{
;	long	i;
;	for( i = 0; i < 5000000; i ++ ) {  /* 计数防止超时,默认的超时时间,与单片机主频有关 */
;		if(USART_Receive_1()) return(CH376GetIntStatus( ));  /* 检测到中断 */
;/* 在等待CH376中断的过程中,可以做些需要及时处理的其它事情 */
;	}
;	return(ERR_USB_UNKNOWN);  /* 不应该发生的情况 */
;}
;
;uchar CH376SendCmdWaitInt(uchar mCmd)  /* 发出命令码后,等待中断 */
;{
;	xWriteCH376Cmd(mCmd);
;	return Wait376Interrupt();
;}
;
;/* 查询CH376中断(INT#低电平) */
;uchar Query376Interrupt(void)
;{
;    return USART_Receive_1();
;}
;
;uchar CH376DiskConnect(void)/*检查U盘是否连接*/
;{
;    if (Query376Interrupt( )) CH376GetIntStatus( );  /* 检测到中断 */
;    return(CH376SendCmdWaitInt(CMD0H_DISK_CONNECT));
;}
;#define	CMD50_WRITE_VAR32	0x0D			/* 设置指定的32位文件系统变量 */
;void CH376WriteVar32(uchar var, unsigned long dat )  /* 写CH376芯片内部的32位变量 */
;{
;	xWriteCH376Cmd(CMD50_WRITE_VAR32);
;	xWriteCH376Data(var);
;	xWriteCH376Data((uchar)dat);
;	xWriteCH376Data((uchar)((uint)dat >> 8));
;	xWriteCH376Data((uchar)(dat >> 16));
;	xWriteCH376Data((uchar)(dat >> 24));
;}
;
;
;uchar CH376DiskMount(void)  /* 初始化磁盘并测试磁盘是否就绪 */
;{
;	return(CH376SendCmdWaitInt(CMD0H_DISK_MOUNT));
;}
;#define	CMD10_SET_FILE_NAME	0x2F			/* 主机文件模式: 设置将要操作的文件的文件名 */
;#define	DEF_SEPAR_CHAR1		0x5C			/* 路径名的分隔符 '\' */
;#define	DEF_SEPAR_CHAR2		0x2F			/* 路径名的分隔符 '/' */
;#define	VAR_CURRENT_CLUST	0x64			/* 当前文件的当前簇号(总长度32位,低字节在前) */
;#define	CMD0H_FILE_OPEN		0x32			/* 主机文件模式: 打开文件或者目录(文件夹),或者枚举文件和目录(文件夹) */
;
;uchar CH376FileOpen(uchar * name)  /* 在根目录或者当前目录下打开文件或者目录(文件夹) */
;{
;   /* 设置将要操作的文件的文件名 */
;   	uchar	c;
;	xWriteCH376Cmd( CMD10_SET_FILE_NAME );
;	c = *name;
;	xWriteCH376Data(c);
;	while (c)
;    {
;		name++;
;		c = *name;
;		if (c == DEF_SEPAR_CHAR1 || c == DEF_SEPAR_CHAR2) c = 0;  /* 强行将文件名截止 */
;		xWriteCH376Data(c);
;	}
;	if (name[0] == DEF_SEPAR_CHAR1 || name[0] == DEF_SEPAR_CHAR2) CH376WriteVar32( VAR_CURRENT_CLUST, 0 );
;	return(CH376SendCmdWaitInt(CMD0H_FILE_OPEN));
;}
;
;#define	CMD1H_FILE_CLOSE	0x36			/* 主机文件模式: 关闭当前已经打开的文件或者目录(文件夹) */
;uchar CH376FileClose(uchar UpdateSz)  /* 关闭当前已经打开的文件或者目录(文件夹) */
;{
;    xWriteCH376Cmd(CMD1H_FILE_CLOSE);
;	xWriteCH376Data(UpdateSz);
;	return(Wait376Interrupt());
;}
;
;#define	CMD01_RD_USB_DATA0	0x27			/* 从当前USB中断的端点缓冲区或者主机端点的接收缓冲区读取数据块 */
;uchar CH376ReadBlock(uchar * buf)  /* 从当前主机端点的接收缓冲区读取数据块,返回长度 */
;{
;	uchar s, l;
;	xWriteCH376Cmd(CMD01_RD_USB_DATA0);
;	s = l = xReadCH376Data( );  /* 长度 */
;	if(l)
;    {
;		do {
;			*buf = xReadCH376Data( );
;			buf ++;
;		} while ( -- l );
;	}
;	return( s );
;}
;
;#define	CMD2H_BYTE_READ		0x3A			/* 主机文件模式: 以字节为单位从当前位置读取数据块 */
;#define	USB_INT_DISK_READ	0x1D			/* USB存储器请求数据读出 */
;#define	CMD0H_BYTE_RD_GO	0x3B			/* 主机文件模式: 继续字节读 */
;uchar CH376ByteRead(uchar * buf, uint ReqCount, uint * RealCount )  /* 以字节为单位从当前位置读取数据块 */
;{
;	uchar	s;
;	xWriteCH376Cmd(CMD2H_BYTE_READ);
;	xWriteCH376Data((uchar)ReqCount);
;	xWriteCH376Data((uchar)(ReqCount>>8));
;	if (RealCount) *RealCount = 0;
;	while ( 1 )
;    {
;		s = Wait376Interrupt( );
;		if (s == USB_INT_DISK_READ)
;        {
;			s = CH376ReadBlock(buf);  /* 从当前主机端点的接收缓冲区读取数据块,返回长度 */
;			xWriteCH376Cmd(CMD0H_BYTE_RD_GO);
;			buf += s;
;			if (RealCount) *RealCount += s;
;		}
;		else return(s);  /* 错误 */
;	}
;}
;
;
;unsigned long CH376Read32bitDat( void )  /* 从CH376芯片读取32位的数据并结束命令 */
;{
;	uchar	c0, c1, c2, c3;
;	c0 = xReadCH376Data( );
;	c1 = xReadCH376Data( );
;	c2 = xReadCH376Data( );
;	c3 = xReadCH376Data( );
;	return(((unsigned long)c3 << 24) | ((unsigned long)c2 << 16) | ((unsigned long)c1 << 8) | c0 );
;}
;
;#define	CMD14_READ_VAR32	0x0C			/* 读取指定的32位文件系统变量 */
;unsigned long CH376ReadVar32(uchar var)  /* 读CH376芯片内部的32位变量 */
;{
;	xWriteCH376Cmd(CMD14_READ_VAR32);
;	xWriteCH376Data(var);
;	return(CH376Read32bitDat( ) );  /* 从CH376芯片读取32位的数据并结束命令 */
;}
;
;#define	VAR_FILE_SIZE		0x68			/* 当前文件的长度(总长度32位,低字节在前) */
;unsigned long CH376GetFileSize(void)  /* 读取当前文件长度 */
;{
;	return(CH376ReadVar32(VAR_FILE_SIZE));
;}
;//--------------------------------------------------END--------------------------------------------------------------
;#endif
;//退出Bootloader程序，从0x0000处执行应用程序
;void quit(void)
; 0000 016E {
_quit:
; 0000 016F       uart_putchar('O');uart_putchar('K');
	LDI  R30,LOW(79)
	ST   -Y,R30
	RCALL _uart_putchar
	LDI  R30,LOW(75)
	ST   -Y,R30
	RCALL _uart_putchar
; 0000 0170       uart_putchar(0x0d);uart_putchar(0x0a);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _uart_putchar
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _uart_putchar
; 0000 0171      while(!(UCSR0A & 0x20));            //等待结束提示信息回送完成
_0x1F:
	SBIS 0xB,5
	RJMP _0x1F
; 0000 0172      MCUCR = 0x01;
	LDI  R30,LOW(1)
	OUT  0x35,R30
; 0000 0173      MCUCR = 0x00;                    //将中断向量表迁移到应用程序区头部
	LDI  R30,LOW(0)
	OUT  0x35,R30
; 0000 0174      RAMPZ = 0x00;                    //RAMPZ清零初始化
	OUT  0x3B,R30
; 0000 0175      #asm("jmp 0x0000")        //跳转到Flash的0x0000处，执行用户的应用程序
	jmp 0x0000
; 0000 0176 }
	RET
;
;
;#define	CMD11_CHECK_EXIST	0x06			/* 测试通讯接口和工作状态 */
;#define	CMD11_SET_USB_MODE	0x15			/* 设置USB工作模式 */
;#define	CMD_RET_SUCCESS		0x51			/* 命令操作成功 */
;#define	CMD_RET_ABORT		0x5F			/* 命令操作失败 */
;#define	USB_INT_SUCCESS		0x14			/* USB事务或者传输操作成功 */
;#define	ERR_MISS_FILE		0x42			/* 指定路径的文件没有找到,可能是文件名称错误 */
;//主程序
;void main(void)
; 0000 0181 {
_main:
; 0000 0182     uint i = 0;
; 0000 0183     uint timercount = 0;
; 0000 0184     uchar packNO = 1;
; 0000 0185     uint bufferPoint = 0;
; 0000 0186     uint crc;
; 0000 0187 #ifdef  UPDATE_USB
; 0000 0188     uchar s;
; 0000 0189     uint j;
; 0000 018A     unsigned long UpdateSize = 0;
; 0000 018B     uint LabCount = 0,lastdatanum = 0;
; 0000 018C     uchar string[50] = {0};
; 0000 018D #endif
; 0000 018E 
; 0000 018F //初始化M128的USART0
; 0000 0190     UBRR0L = BAUD_L;            //Set baud rate
	SBIW R28,4
	LDI  R30,LOW(0)
	STD  Y+2,R30
	STD  Y+3,R30
;	i -> R16,R17
;	timercount -> R18,R19
;	packNO -> R21
;	bufferPoint -> Y+2
;	crc -> Y+0
	__GETWRN 16,17,0
	__GETWRN 18,19,0
	LDI  R21,1
	LDI  R30,LOW(25)
	OUT  0x9,R30
; 0000 0191     UBRR0H = BAUD_H;
	LDI  R30,LOW(0)
	STS  144,R30
; 0000 0192     UCSR0B = ((1<<RXEN0)|(1<<TXEN0));        //接收器与发送器使能；
	LDI  R30,LOW(24)
	OUT  0xA,R30
; 0000 0193     UCSR0C = (1<<USBS0)|(3<<UCSZ00);        //设置帧格式: 8 个数据位, 1 个停止位；
	LDI  R30,LOW(14)
	STS  149,R30
; 0000 0194 #ifdef  UPDATE_USB
; 0000 0195 //初始化M128的USART1
; 0000 0196     UBRR1L = 8;
; 0000 0197     UBRR1H = 0;
; 0000 0198     UCSR1B = ((1<<RXEN1)|(1<<TXEN1));        //接收器与发送器使能；
; 0000 0199     UCSR1C = (1<<USBS1)|(3<<UCSZ10);        //设置帧格式: 8 个数据位, 1 个停止位；
; 0000 019A #endif
; 0000 019B //初始化M128的T/C0，15ms自动重载
; 0000 019C     OCR0 = 0x75;
	LDI  R30,LOW(117)
	OUT  0x31,R30
; 0000 019D     TCCR0 = 0x0F;
	LDI  R30,LOW(15)
	OUT  0x33,R30
; 0000 019E     TCNT0 = 0;
	LDI  R30,LOW(0)
	OUT  0x32,R30
; 0000 019F 
; 0000 01A0     DDRB.0 = 1;
	SBI  0x17,0
; 0000 01A1     PORTB.0 = 1;
	SBI  0x18,0
; 0000 01A2     /*
; 0000 01A3     USART_Send_string(a4String1);
; 0000 01A4     while(uart_getchar()!='O');
; 0000 01A5     while(uart_getchar()!='K');
; 0000 01A6     USART_Send_string(a4String2);
; 0000 01A7     while(uart_getchar()!='O');
; 0000 01A8     while(uart_getchar()!='K');
; 0000 01A9     */
; 0000 01AA     USART_Send_string(startupString);//向PC机发送开始提示信息
	LDI  R30,LOW(_startupString*2)
	LDI  R31,HIGH(_startupString*2)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _USART_Send_string
; 0000 01AB     while(1)
_0x26:
; 0000 01AC     {
; 0000 01AD         if(uart_getchar()=='d')break;
	RCALL _uart_getchar
	CPI  R30,LOW(0x64)
	LDI  R26,HIGH(0x64)
	CPC  R31,R26
	BREQ _0x28
; 0000 01AE         if(TIFR&0x02)
	IN   R30,0x36
	SBRS R30,1
	RJMP _0x2A
; 0000 01AF         {
; 0000 01B0             if(++timercount>500) //若没有进入串口升级模式，则进入U盘升级模式 200*15ms=3s
	MOVW R30,R18
	ADIW R30,1
	MOVW R18,R30
	CPI  R30,LOW(0x1F5)
	LDI  R26,HIGH(0x1F5)
	CPC  R31,R26
	BRLO _0x2B
; 0000 01B1             {
; 0000 01B2 #ifdef  UPDATE_USB
; 0000 01B3 
; 0000 01B4                 sprintf((char*)string,"Enter the USB_Disk Update!\n",UpdateSize);
; 0000 01B5                 USART_Send_string(string);
; 0000 01B6                 //++++++++++++++++初始化CH376S++++++++++++++++++++++++
; 0000 01B7                 //CH376_PORT_INIT( );  /* 接口硬件初始化 */
; 0000 01B8 	            xWriteCH376Cmd(CMD11_CHECK_EXIST);  /* 测试单片机与CH376之间的通讯接口 */
; 0000 01B9 	            xWriteCH376Data(0x65);
; 0000 01BA 	            s = xReadCH376Data( );
; 0000 01BB 	            if (s != 0x9A)
; 0000 01BC                     uart_putchar(ERR_USB_UNKNOWN);  /* 通讯接口不正常,可能原因有:接口连接异常,其它设备影响(片选不唯一),串口波特率,一直在复位,晶振不工作 */
; 0000 01BD 	            xWriteCH376Cmd(CMD11_SET_USB_MODE);  /* 设备USB工作模式 */
; 0000 01BE 	            xWriteCH376Data(0x06);
; 0000 01BF 	            s = xReadCH376Data( );
; 0000 01C0 	            if (s != CMD_RET_SUCCESS)
; 0000 01C1                 {
; 0000 01C2                     sprintf((char*)string,"USB_Disk is wrong init!\n",UpdateSize);
; 0000 01C3                     USART_Send_string(string);
; 0000 01C4                     quit();
; 0000 01C5                 }
; 0000 01C6                 //++++++++++++++++++++++END+++++++++++++++++++++++++++++++++
; 0000 01C7                 //检查U盘是否连接好
; 0000 01C8                 i = 0;
; 0000 01C9                 while(CH376DiskConnect() != USB_INT_SUCCESS)
; 0000 01CA                 {
; 0000 01CB                     if(++i > 5)
; 0000 01CC                     {
; 0000 01CD                         sprintf((char*)string,"USB_Disk is not Connection!\n",UpdateSize);
; 0000 01CE                         USART_Send_string(string);
; 0000 01CF                         quit();
; 0000 01D0                     }
; 0000 01D1                     delay_ms(100);
; 0000 01D2                 }
; 0000 01D3                 i = 0;
; 0000 01D4                 // 对于检测到USB设备的,最多等待10*50mS
; 0000 01D5                 if(CH376DiskMount() != USB_INT_SUCCESS)
; 0000 01D6                 {
; 0000 01D7                     if(++i > 5)
; 0000 01D8                     {
; 0000 01D9                         sprintf((char*)string,"USB_Disk Test Wrong!\n",UpdateSize);
; 0000 01DA                         USART_Send_string(string);
; 0000 01DB                         quit();
; 0000 01DC                     }
; 0000 01DD                     delay_ms(100);
; 0000 01DE                 }
; 0000 01DF                 //打开升级文件
; 0000 01E0                 s = CH376FileOpen("J8A-1.U");//每台机子，对应升级文件。
; 0000 01E1                 if (s == ERR_MISS_FILE) //没有找到升级文件则退出
; 0000 01E2                 {
; 0000 01E3                     CH376FileClose(TRUE);
; 0000 01E4                     sprintf((char*)string,"I can't fined the Update_File!\n",UpdateSize);
; 0000 01E5                     USART_Send_string(string);
; 0000 01E6                     quit();
; 0000 01E7                 }
; 0000 01E8                 UpdateSize = CH376GetFileSize();
; 0000 01E9                 sprintf((char*)string,"The Update_File size is :%dl\n",UpdateSize);
; 0000 01EA                 USART_Send_string(string);
; 0000 01EB 
; 0000 01EC                 LabCount = UpdateSize/SPM_PAGESIZE;
; 0000 01ED                 lastdatanum = UpdateSize%SPM_PAGESIZE;
; 0000 01EE                 if(lastdatanum)
; 0000 01EF                     LabCount++;
; 0000 01F0                 if(LabCount > (512-32))//mega128的flash页数
; 0000 01F1                 {
; 0000 01F2                     sprintf((char*)string,"The Update_File size is too big!",UpdateSize);
; 0000 01F3                     USART_Send_string(string);
; 0000 01F4                     CH376FileClose(FALSE);
; 0000 01F5                     quit();
; 0000 01F6                 }
; 0000 01F7                 //读取升级文件数据
; 0000 01F8                 for(i = 0; i < LabCount; i++)
; 0000 01F9                 {
; 0000 01FA 
; 0000 01FB                     if(lastdatanum && (i == (LabCount - 1)))
; 0000 01FC                     {
; 0000 01FD                         CH376ByteRead(data, lastdatanum, NULL);
; 0000 01FE                         for(j = lastdatanum; j < SPM_PAGESIZE; j++)
; 0000 01FF                             data[j] = 0xFF;
; 0000 0200                     }
; 0000 0201                     else
; 0000 0202                         CH376ByteRead(data, SPM_PAGESIZE, NULL);
; 0000 0203                     write_one_page();
; 0000 0204                     address = address + SPM_PAGESIZE;    //Flash页加1
; 0000 0205                 }
; 0000 0206                 //write_one_page();         //收到256字节写入一页Flash中
; 0000 0207                 //address = address + SPM_PAGESIZE;    //Flash页加1
; 0000 0208                 //关闭文件
; 0000 0209                 CH376FileClose(FALSE);
; 0000 020A #endif
; 0000 020B                 quit();
	RCALL _quit
; 0000 020C             }
; 0000 020D             TIFR=TIFR|0x02;
_0x2B:
	IN   R30,0x36
	ORI  R30,2
	OUT  0x36,R30
; 0000 020E         }
; 0000 020F     }
_0x2A:
	RJMP _0x26
_0x28:
; 0000 0210     //每秒向PC机发送一个控制字符"C"，等待控制字〈soh〉
; 0000 0211     while(uart_getchar()!= XMODEM_SOH)        //receive the start of Xmodem
_0x2C:
	RCALL _uart_getchar
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BREQ _0x2E
; 0000 0212     {
; 0000 0213          if(TIFR & 0x02)              //timer0 over flow
	IN   R30,0x36
	SBRS R30,1
	RJMP _0x2F
; 0000 0214         {
; 0000 0215             if(++timercount > 100)                   //wait about 1 second
	MOVW R30,R18
	ADIW R30,1
	MOVW R18,R30
	CPI  R30,LOW(0x65)
	LDI  R26,HIGH(0x65)
	CPC  R31,R26
	BRLO _0x30
; 0000 0216             {
; 0000 0217                 uart_putchar(XMODEM_RECIEVING_WAIT_CHAR);   //send a "C"
	LDI  R30,LOW(67)
	ST   -Y,R30
	RCALL _uart_putchar
; 0000 0218                 timercount = 0;
	__GETWRN 18,19,0
; 0000 0219             }
; 0000 021A             TIFR = TIFR&0x02;
_0x30:
	IN   R30,0x36
	ANDI R30,LOW(0x2)
	OUT  0x36,R30
; 0000 021B         }
; 0000 021C     }
_0x2F:
	RJMP _0x2C
_0x2E:
; 0000 021D     //开始接收数据块
; 0000 021E     do
_0x32:
; 0000 021F     {
; 0000 0220         if ((packNO == uart_waitchar()) && (packNO ==(~uart_waitchar())))
	RCALL _uart_waitchar
	CP   R30,R21
	BRNE _0x35
	RCALL _uart_waitchar
	COM  R30
	CP   R30,R21
	BREQ _0x36
_0x35:
	RJMP _0x34
_0x36:
; 0000 0221         {    //核对数据块编号正确
; 0000 0222             for(i=0;i<128;i++)             //接收128个字节数据
	__GETWRN 16,17,0
_0x38:
	__CPWRN 16,17,128
	BRSH _0x39
; 0000 0223             {
; 0000 0224                 data[bufferPoint]= uart_waitchar();
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	SUBI R30,LOW(-_data)
	SBCI R31,HIGH(-_data)
	PUSH R31
	PUSH R30
	RCALL _uart_waitchar
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0225                 bufferPoint++;
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ADIW R30,1
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 0226             }
	__ADDWRN 16,17,1
	RJMP _0x38
_0x39:
; 0000 0227             crc = (uint)(uart_waitchar())<<8;
	RCALL _uart_waitchar
	MOV  R31,R30
	LDI  R30,0
	ST   Y,R30
	STD  Y+1,R31
; 0000 0228             crc = crc | uart_waitchar();        //接收2个字节的CRC效验字
	RCALL _uart_waitchar
	LD   R26,Y
	LDD  R27,Y+1
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	ST   Y,R30
	STD  Y+1,R31
; 0000 0229             if(calcrc(&data[bufferPoint-128],128) == crc)    //CRC校验验证
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	SUBI R30,LOW(128)
	SBCI R31,HIGH(128)
	SUBI R30,LOW(-_data)
	SBCI R31,HIGH(-_data)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(128)
	ST   -Y,R30
	RCALL _calcrc
	MOVW R26,R30
	LD   R30,Y
	LDD  R31,Y+1
	CP   R30,R26
	CPC  R31,R27
	BRNE _0x3A
; 0000 022A             {    //正确接收128个字节数据
; 0000 022B                 while(bufferPoint >= SPM_PAGESIZE)
_0x3B:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CPI  R26,LOW(0x100)
	LDI  R30,HIGH(0x100)
	CPC  R27,R30
	BRLO _0x3D
; 0000 022C                 {    //正确接受256个字节的数据
; 0000 022D                     write_one_page();         //收到256字节写入一页Flash中
	RCALL _write_one_page
; 0000 022E                     address = address + SPM_PAGESIZE;    //Flash页加1
	LDS  R30,_address
	LDS  R31,_address+1
	LDS  R22,_address+2
	LDS  R23,_address+3
	__ADDD1N 256
	STS  _address,R30
	STS  _address+1,R31
	STS  _address+2,R22
	STS  _address+3,R23
; 0000 022F                     bufferPoint = 0;
	LDI  R30,LOW(0)
	STD  Y+2,R30
	STD  Y+2+1,R30
; 0000 0230                 }
	RJMP _0x3B
_0x3D:
; 0000 0231                 uart_putchar(XMODEM_ACK);      //正确收到一个数据块
	LDI  R30,LOW(6)
	ST   -Y,R30
	RCALL _uart_putchar
; 0000 0232                 packNO++;                      //数据块编号加1
	SUBI R21,-1
; 0000 0233             }
; 0000 0234             else
	RJMP _0x3E
_0x3A:
; 0000 0235             {
; 0000 0236                 uart_putchar(XMODEM_NAK);     //要求重发数据块
	LDI  R30,LOW(21)
	ST   -Y,R30
	RCALL _uart_putchar
; 0000 0237             }
_0x3E:
; 0000 0238         }
; 0000 0239         else
	RJMP _0x3F
_0x34:
; 0000 023A         {
; 0000 023B             uart_putchar(XMODEM_NAK);           //要求重发数据块
	LDI  R30,LOW(21)
	ST   -Y,R30
	RCALL _uart_putchar
; 0000 023C         }
_0x3F:
; 0000 023D     }while(uart_waitchar()!=XMODEM_EOT);          //循环接收，直到全部发完
	RCALL _uart_waitchar
	CPI  R30,LOW(0x4)
	BREQ _0x33
	RJMP _0x32
_0x33:
; 0000 023E     uart_putchar(XMODEM_ACK);                    //通知PC机全部收到
	LDI  R30,LOW(6)
	ST   -Y,R30
	RCALL _uart_putchar
; 0000 023F 
; 0000 0240     if(bufferPoint) write_one_page();        //把剩余的数据写入Flash中
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	SBIW R30,0
	BREQ _0x40
	RCALL _write_one_page
; 0000 0241     quit();                //退出Bootloader程序，从0x0000处执行应用程序
_0x40:
	RCALL _quit
; 0000 0242 }
	ADIW R28,4
_0x41:
	RJMP _0x41
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG

	.CSEG

	.CSEG

	.DSEG
_data:
	.BYTE 0x100
_address:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	LDS  R30,_address
	LDS  R31,_address+1
	ST   -Y,R31
	ST   -Y,R30
	RET


	.CSEG
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:
