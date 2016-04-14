
#pragma used+
sfrb PINF=0;
sfrb PINE=1;
sfrb DDRE=2;
sfrb PORTE=3;
sfrb ADCL=4;
sfrb ADCH=5;
sfrw ADCW=4;      
sfrb ADCSRA=6;
sfrb ADMUX=7;
sfrb ACSR=8;
sfrb UBRR0L=9;
sfrb UCSR0B=0xa;
sfrb UCSR0A=0xb;
sfrb UDR0=0xc;
sfrb SPCR=0xd;
sfrb SPSR=0xe;
sfrb SPDR=0xf;
sfrb PIND=0x10;
sfrb DDRD=0x11;
sfrb PORTD=0x12;
sfrb PINC=0x13;
sfrb DDRC=0x14;
sfrb PORTC=0x15;
sfrb PINB=0x16;
sfrb DDRB=0x17;
sfrb PORTB=0x18;
sfrb PINA=0x19;
sfrb DDRA=0x1a;
sfrb PORTA=0x1b;
sfrb EECR=0x1c;
sfrb EEDR=0x1d;
sfrb EEARL=0x1e;
sfrb EEARH=0x1f;
sfrw EEAR=0x1e;   
sfrb SFIOR=0x20;
sfrb WDTCR=0x21;
sfrb OCDR=0x22;
sfrb OCR2=0x23;
sfrb TCNT2=0x24;
sfrb TCCR2=0x25;
sfrb ICR1L=0x26;
sfrb ICR1H=0x27;
sfrw ICR1=0x26;   
sfrb OCR1BL=0x28;
sfrb OCR1BH=0x29;
sfrw OCR1B=0x28;  
sfrb OCR1AL=0x2a;
sfrb OCR1AH=0x2b;
sfrw OCR1A=0x2a;  
sfrb TCNT1L=0x2c;
sfrb TCNT1H=0x2d;
sfrw TCNT1=0x2c;  
sfrb TCCR1B=0x2e;
sfrb TCCR1A=0x2f;
sfrb ASSR=0x30;
sfrb OCR0=0x31;
sfrb TCNT0=0x32;
sfrb TCCR0=0x33;
sfrb MCUCSR=0x34;
sfrb MCUCR=0x35;
sfrb TIFR=0x36;
sfrb TIMSK=0x37;
sfrb EIFR=0x38;
sfrb EIMSK=0x39;
sfrb EICRB=0x3a;
sfrb RAMPZ=0x3b;
sfrb XDIV=0x3c;
sfrb SPL=0x3d;
sfrb SPH=0x3e;
sfrb SREG=0x3f;
#pragma used-

#asm
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
#endasm

#pragma used+

void delay_us(unsigned int n);
void delay_ms(unsigned int n);

#pragma used-

const char startupString[]="Type 'd' download, Others run app.\n\r";
char data[256                  ];
long address = 0;

void boot_page_ew(long p_address,char code)
{
#asm("mov r30,r16")
#asm("mov r31,r17")
#asm("out 0x3b,r18");            
(*(unsigned char *) 0x68) = code;                
#asm("spm");                    
}        

void boot_page_fill(unsigned int address,int data)
{
#asm("mov r30,r16")
#asm("mov r31,r17")             
#asm("mov r0,r18")
#asm("mov r1,r19");            
(*(unsigned char *) 0x68) = 0x01;
#asm("spm");
}

void wait_page_rw_ok(void)
{
while((*(unsigned char *) 0x68) & 0x40)
{
while((*(unsigned char *) 0x68) & 0x01);
(*(unsigned char *) 0x68) = 0x11;
#asm("spm");
}
}

void write_one_page(void)
{
int i;
boot_page_ew(address,0x03);                    
wait_page_rw_ok();                            
for(i=0;i<256          ;i+=2)                
{
boot_page_fill(i, data[i]+(data[i+1]<<8));
}
boot_page_ew(address,0x05);                    
wait_page_rw_ok();                            
}        

void uart_putchar(char c)
{
while(!(UCSR0A & 0x20));
UDR0 = c;
}

unsigned char uart_getchar(void)
{
unsigned char status,res;

if(!(UCSR0A & (1<<7       ))) return -1;
status = UCSR0A;
res = UDR0;      
if (status & 0x1c) return -1;        
return res;
}

char uart_waitchar(void)
{
int c;
while((c=uart_getchar())==-1);
return (char)c;
}

int calcrc(char *ptr, int count)
{
int crc = 0;
char i;

while (--count >= 0)
{
crc = crc ^ (int) *ptr++ << 8;
i = 8;
do
{
if (crc & 0x8000)
crc = crc << 1 ^ 0x1021;
else
crc = crc << 1;
} while(--i);
}
return (crc);
}

void quit(void)
{
uart_putchar('O');uart_putchar('K');
uart_putchar(0x0d);uart_putchar(0x0a);
while(!(UCSR0A & 0x20));            
MCUCR = 0x01;
MCUCR = 0x00;                    
RAMPZ = 0x00;                    
#asm("jmp 0x0000");        
}

void main(void)
{
int i = 0;
unsigned int timercount = 0;
unsigned char packNO = 1;
int bufferPoint = 0;
unsigned int crc;

(*(unsigned char *) 0x90) = (unsigned char)((unsigned char)((unsigned long)16000000          /(16*(unsigned long)38400                )-1)>>8);    
UBRR0L = (unsigned char)(unsigned char)((unsigned long)16000000          /(16*(unsigned long)38400                )-1);            
UCSR0B = 0x18;            
(*(unsigned char *) 0x95) = 0x0E;            

OCR0 = 0x75;
TCCR0 = 0x0F;                                                               
TCNT0 = 0;  

DDRB.0 = 1;
PORTB.0 = 1;

DDRC.5 = 1;
PORTC.5 = 1;

delay_ms(500);
PORTC.5 = 0;
delay_ms(500);
PORTC.5 = 1; 

while(startupString[i] != '\0')
{
uart_putchar(startupString[i]);
i++;
}

while(1)
{            
if(uart_getchar() == 'd') 
{      
delay_ms(500);
PORTB.0 = 0;
delay_ms(500);
PORTB.0 = 1; 
delay_ms(500);
PORTB.0 = 0;     
delay_ms(500);
PORTB.0 = 0;
delay_ms(500);
PORTB.0 = 1; 
delay_ms(500);
PORTB.0 = 0; 
} 

if (TIFR & 0x02)                     
{      
TIFR = TIFR&0xFD;      
if (++timercount > 400) quit();      
}  
}

}
