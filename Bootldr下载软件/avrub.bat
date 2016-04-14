@rem auto create by AVRUBD at 2012/9/20 16:15:36
avr-gcc.exe  -mmcu=atmega128 -Wall -gdwarf-2  -Os -fsigned-char -MD -MP  -c  bootldr.c
avr-gcc.exe -mmcu=atmega128  -Wl,-section-start=.text=0x1F800 bootldr.o     -o Bootldr.elf
avr-objcopy -O ihex -R .eeprom  Bootldr.elf Bootldr.hex
@pause
