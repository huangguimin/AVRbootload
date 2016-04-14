#include "uart.h"


/*************���ڳ�ʼ��*****************/
void USART_initial(void)
{
    uint a;
    a=16000000/16/38400-1;//a=fosc/16/baud-1;
    UBRR0L=a%256;
    UBRR0H=a/256;
    UCSR0B = ((1<<RXEN0)|(1<<TXEN0));        //�������뷢����ʹ�ܣ�
    UCSR0C = (1<<USBS0)|(3<<UCSZ00);        //����֡��ʽ: 8 ������λ, 1 ��ֹͣλ��
    UCSR0B|= (1<<RXCIE0);        //USART�����ж�ʹ��
}


/************���ڷ���һ������********************/
void USART_Send_word(uchar data)
{
    while (!(UCSR0A & (1<<UDRE0)));        //�ȴ����ͻ�����Ϊ�գ�
    UDR0 = data;        //�����ݷ��뻺�������������ݣ�
}

void USART_Send_string(uchar *data,uchar length)
{
    uchar i;
    for(i = 0; i < length; i++)
    {
        USART_Send_word(*(data+i));
    }
}

/********���ڽ���***********/
/*
uint USART_Receive( void )
{
    uint i = 0x15FF;
// �ȴ���������
    do
    {
      if(!(i--)) return 300;
    }while (!(UCSR0A & (1<<RXC0)));
// �ӻ������л�ȡ����������
    return UDR0;
}

*/

uchar Receive_buf[100] = {0}, count = 0;
interrupt [USART0_RXC] void USART_Receive_Int(void)
{	
    if(count < 100)
    {
        Receive_buf[count++]=UDR0;	//���������ݷ���Ԥ������ 
        TCNT2=0;      
        TCCR2 |= (1<<CS22);
    }      
}
/*------------------------------------------------END USART0-------------------------------------------------------------*/


/*************����1��ʼ��*****************/
void USART_initial_1(uint baud)
{
    UBRR1L=baud%256;
    UBRR1H=baud/256;
    UCSR1B = ((1<<RXEN1)|(1<<TXEN1));        //�������뷢����ʹ�ܣ�
    UCSR1C = (1<<USBS1)|(3<<UCSZ10);        //����֡��ʽ: 8 ������λ, 1 ��ֹͣλ��
    //UCSR1B|= (1<<RXCIE1) | (1<<TXCIE1);        //USART�����ж�ʹ��
}                        

/************����1����һ������********************/

void USART_Send_word_1(uchar data)
{
    while (!(UCSR1A & (1<<UDRE1)));        //�ȴ����ͻ�����Ϊ�գ�
    UDR1 = data;        //�����ݷ��뻺�������������ݣ�
}


void USART_Send_string_1(uchar *data,uchar length)
{
    uchar i;
   for(i = 0; i < length; i++)
    USART_Send_word_1(data[i]);
}

/********����1�����ж�***********/
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
        UDR1 = *(Usart1_Send_Init_P + Usart1_Sned_Count);        //�����ݷ��뻺�������������ݣ�     
}
  */
/********����1����***********/

uchar USART_Receive_1(void)
{
// �ȴ���������
    uint i = 0;
    while(!(UCSR1A & (1<<RXC1))){if((++i)>65530)return 0;};
    return UDR1;
}
   
/********����1�жϽ���***********/
/*
extern uchar MPC006_Reseive_Processing();
uchar MPC006_Processed_finish = 0;
uchar Receive_Data[10] = {0}, count1 = 0;
interrupt [USART1_RXC] void USART_Receive_Int_1(void)     //����MPC006ģ�鷵������
{	
    if(count1 < 9)
    {    
        Receive_Data[count1++] = UDR1;	//���������ݷ���Ԥ������ 
        TCNT3L = 0;
        TCNT3H = 0;      
        TCCR3B |= (1<<CS30)|(1<<CS32);////����T3ʱ�Ӽ��� 
    }
    else 
    {     
        Receive_Data[count1++] = UDR1;	//���������ݷ���Ԥ������ 
        TCCR3B &= 0xF8; //��T3��ʱ��ʱ��Ƶ��
        TCNT3L = 0;
        TCNT3H = 0;       //���T3��ʱ�Ĵ��� 
        MPC006_Reseive_Processing();
    }   
}
*/
  

