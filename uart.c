#include "uart.h"


/*************串口初始化*****************/
void USART_initial(void)
{
    uint a;
    a=16000000/16/38400-1;//a=fosc/16/baud-1;
    UBRR0L=a%256;
    UBRR0H=a/256;
    UCSR0B = ((1<<RXEN0)|(1<<TXEN0));        //接收器与发送器使能；
    UCSR0C = (1<<USBS0)|(3<<UCSZ00);        //设置帧格式: 8 个数据位, 1 个停止位；
    UCSR0B|= (1<<RXCIE0);        //USART接收中断使能
}


/************串口发送一个数据********************/
void USART_Send_word(uchar data)
{
    while (!(UCSR0A & (1<<UDRE0)));        //等待发送缓冲器为空；
    UDR0 = data;        //将数据放入缓冲器，发送数据；
}

void USART_Send_string(uchar *data,uchar length)
{
    uchar i;
    for(i = 0; i < length; i++)
    {
        USART_Send_word(*(data+i));
    }
}

/********串口接收***********/
/*
uint USART_Receive( void )
{
    uint i = 0x15FF;
// 等待接收数据
    do
    {
      if(!(i--)) return 300;
    }while (!(UCSR0A & (1<<RXC0)));
// 从缓冲器中获取并返回数据
    return UDR0;
}

*/

uchar Receive_buf[100] = {0}, count = 0;
interrupt [USART0_RXC] void USART_Receive_Int(void)
{	
    if(count < 100)
    {
        Receive_buf[count++]=UDR0;	//将接受数据放入预置数组 
        TCNT2=0;      
        TCCR2 |= (1<<CS22);
    }      
}
/*------------------------------------------------END USART0-------------------------------------------------------------*/


/*************串口1初始化*****************/
void USART_initial_1(uint baud)
{
    UBRR1L=baud%256;
    UBRR1H=baud/256;
    UCSR1B = ((1<<RXEN1)|(1<<TXEN1));        //接收器与发送器使能；
    UCSR1C = (1<<USBS1)|(3<<UCSZ10);        //设置帧格式: 8 个数据位, 1 个停止位；
    //UCSR1B|= (1<<RXCIE1) | (1<<TXCIE1);        //USART发送中断使能
}                        

/************串口1发送一个数据********************/

void USART_Send_word_1(uchar data)
{
    while (!(UCSR1A & (1<<UDRE1)));        //等待发送缓冲器为空；
    UDR1 = data;        //将数据放入缓冲器，发送数据；
}


void USART_Send_string_1(uchar *data,uchar length)
{
    uchar i;
   for(i = 0; i < length; i++)
    USART_Send_word_1(data[i]);
}

/********串口1发送中断***********/
/*
uchar *Usart1_Send_Init_P = NULL; 
uchar Usart1_Send_Length = 0; 
uchar Usart1_Sned_Count = 0;
  
void USART_Send_string_1(uchar *data,uchar length)
{
    Usart1_Send_Init_P = data;
    Usart1_Send_Length = length;
    Usart1_Sned_Count = 0;
    UDR1 = *Usart1_Send_Init_P;    
}

interrupt [USART1_TXC] void USART_Send_Int_1(void)
{	
    if((Usart1_Sned_Count++) < Usart1_Send_Length)
        UDR1 = *(Usart1_Send_Init_P + Usart1_Sned_Count);        //将数据放入缓冲器，发送数据；     
}
  */
/********串口1接收***********/

uchar USART_Receive_1(void)
{
// 等待接收数据
    uint i = 0;
    while(!(UCSR1A & (1<<RXC1))){if((++i)>65530)return 0;};
    return UDR1;
}
   
/********串口1中断接收***********/
/*
extern uchar MPC006_Reseive_Processing();
uchar MPC006_Processed_finish = 0;
uchar Receive_Data[10] = {0}, count1 = 0;
interrupt [USART1_RXC] void USART_Receive_Int_1(void)     //接收MPC006模块返回数据
{	
    if(count1 < 9)
    {    
        Receive_Data[count1++] = UDR1;	//将接受数据放入预置数组 
        TCNT3L = 0;
        TCNT3H = 0;      
        TCCR3B |= (1<<CS30)|(1<<CS32);////开启T3时钟计数 
    }
    else 
    {     
        Receive_Data[count1++] = UDR1;	//将接受数据放入预置数组 
        TCCR3B &= 0xF8; //关T3定时器时钟频率
        TCNT3L = 0;
        TCNT3H = 0;       //清除T3计时寄存器 
        MPC006_Reseive_Processing();
    }   
}
*/
  

