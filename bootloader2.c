/***************************************************** 
采用串行接口实现Boot_load应用的实例 
改编自华东师大电子系马老师mega128 bootloader
Compiler:    CodeVisionAVR 
Target:      Mega16 
Crystal:     4Mhz    
波特率：     9600
Used:        USART
*****************************************************/ 

#include <mega128.h>   
#include <delay.h>
#define SPM_PAGESIZE 256                //M16的一个Flash页为128字节(64字) 
#define DATA_BUFFER_SIZE SPM_PAGESIZE   //定义接收缓冲区长度

//定义全局变量 
unsigned char data[DATA_BUFFER_SIZE]; 
unsigned int address =0;           //R5高位，R4低位
unsigned int flshdata=0;           //R7高位，R6低位
unsigned char aaa,bbb;             

void uart_init()
{
 /* UBRRH = 0x00;         //初始化M16的USART
  UBRRL = 0x33;        
  UCSRB = 0x18;         
  UCSRC = 0x86;          
  UCSRA = 0x22; */
  //初始化M128的USART0
    UBRR0H = 0x00;    
    UBRR0L = 0x33;            //Set baud rate
    UCSR0B = 0x18;            //Enable Receiver and Transmitter
    UCSR0C = 0x0E;            //Set frame. format: 8data, 2stop bit
}
                
void print_face()
{
  UDR0   = 0x5E;
  delay_ms(100);
  UCSR0A = 0x22; 
  UDR0   = 0x5F;
  delay_ms(100);
  UCSR0A = 0x22;
  UDR0   = 0x5E;
  delay_ms(100);
  UCSR0A = 0x22;  
}
//擦除(code=0x03)和写入(code=0x05)一个Flash页 
void boot_page_ew(unsigned char code) 
{    
    SPMCR = code;                    //寄存器SPMCSR中为操作码    
    #asm
     MOV r30,r4 
     mov r31,r5
     spm
    #endasm                          //对指定Flash页进行操作 
}       
  
//填充Flash缓冲页中的一个字 
void boot_page_fill(void) 
{ 
    #asm
     MOV r0, r6
     MOV r1, r7
    #endasm                  //R0R1中为一个指令字 
    SPMCR = 0x01; 
    #asm
     MOV r30,r4
     MOV r31,r5
     spm
    #endasm  
} 

//等待一个Flash页的写完成 
void wait_page_rw_ok(void) 
{ 
      while(SPMCR & 0x40) 
     { 
         while(SPMCR & 0x01); 
         SPMCR = 0x11; 
             #asm
              spm
             #endasm  
     } 
} 


//更新一个Flash页的完整处理 
void write_one_page(void) 
{ 
    int i; 
    boot_page_ew(0x03);                         
    wait_page_rw_ok();                          
    for(i=0;i<SPM_PAGESIZE;i+=2)
    {
     aaa=data[i];
     bbb=data[i+1]; 
     #asm
      MOV r7,r8
      MOV r6,r9
     #endasm   
     address=address+i;
     boot_page_fill();
     address=address-i; 
    } 
    boot_page_ew(0x05);                         
    wait_page_rw_ok();                 
 }                        
 
 void quit(void) 
{ 
     #asm
      jmp 0x0000
     #endasm  
} 

 
 
//主函数
void main(void) 
{ 
  unsigned int  i=0,bufferPoint=0; 
  unsigned char sunny=0;                
  
  uart_init();
  print_face(); 
     
  while(!(sunny==0x20)) 
  {
   while(!(UCSR0A & 0x80))                            
   {  
    UDR0   = 0x3E;
    delay_ms(300);
    UCSR0A = 0x22; 
   }
  sunny=UDR0;
  UCSR0A = 0x22;
  }
  print_face(); 
  
  
  for(i=0;i<128;i++)                        
  {
   while(!(UCSR0A & 0x80));
   data[bufferPoint]= UDR0;
   bufferPoint++;
   UCSR0A=0x22;
  }       
  write_one_page(); 
  bufferPoint=0;   
  address += SPM_PAGESIZE;
  
   for(i=0;i<128;i++)                        
  {
   while(!(UCSR0A & 0x80));
   data[bufferPoint]= UDR0;
   bufferPoint++;
   UCSR0A=0x22;
  }       
  write_one_page(); 
  bufferPoint=0;   
                     
  UDR0   = 0x21;
  delay_ms(300);
  UCSR0A = 0x22; 
  delay_ms(3000);  
  quit();
                    
} 