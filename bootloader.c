/*****************************************************
���ô��нӿ�ʵ��Boot_loadӦ�õ�ʵ��
����ʦ�����ϵ �� �� 2004.07
Compiler:    ICC-AVR 6.31
Target:    Mega128
Crystal:    16Mhz
Used:        T/C0,USART0
*****************************************************/
#include <mega128.h>
#include <delay.h>
#include <stdio.h>

//#define UPDATE_USB      1



#define SPM_PAGESIZE 256          //M128��һ��FlashҳΪ256�ֽ�(128��)
#define BAUD 38400                //�����ʲ���38400bps
#define CRYSTAL 16000000          //ϵͳʱ��16MHz

//����Ͷ���M128�Ĳ��������ò���
#define BAUD_SETTING (unsigned char)((unsigned long)CRYSTAL/(16*(unsigned long)BAUD)-1)
#define BAUD_H (unsigned char)(BAUD_SETTING>>8)
#define BAUD_L (unsigned char)BAUD_SETTING
#define DATA_BUFFER_SIZE SPM_PAGESIZE        //������ջ���������

//����Xmoden�����ַ�
#define XMODEM_NUL 0x00
#define XMODEM_SOH 0x01
#define XMODEM_STX 0x02
#define XMODEM_EOT 0x04
#define XMODEM_ACK 0x06
#define XMODEM_NAK 0x15
#define XMODEM_CAN 0x18
#define XMODEM_EOF 0x1A
#define XMODEM_RECIEVING_WAIT_CHAR 'C'

//����ȫ�ֱ���
const uchar startupString[]="Type 'd' download, Others run app.\n\r";
/*
const uchar a4String1[]="AT+UART=38400,0,0\r\n\0";
const uchar a4String2[]="AT+UART?\r\n\0";
*/
uchar data[DATA_BUFFER_SIZE];
unsigned long address = 0;

#pragma warn-
//����(code=0x03)��д��(code=0x05)һ��Flashҳ
void boot_page_ew(uint p_address, uchar code)
{
        RAMPZ = 0;    

    #asm
        ldd r30,y+1
        ldd r31,y+2         
        ld r20,y
        STS 0X68,r20  
    #endasm
    #asm("spm");                    //��ָ��Flashҳ���в��� 

}   
#pragma warn+ 

#pragma warn-
//���Flash����ҳ�е�һ����
void boot_page_fill(uint address,uint data)
{
    #asm
        ldd r30,y+2  //Z�Ĵ�����Ϊ����ҳ��ַ   
        ldd r31,y+3
        ld r0,y
        ldd r1,y+1   //R0R1��Ϊһ���ֵ����� 
        LDI r20,0x01
        STS 0X68,r20
    #endasm 
    #asm("spm");   //��R0R1�е�����д��Z�Ĵ����еĻ���ҳ��ַ
}
#pragma warn+

#pragma warn-
//�ȴ�һ��Flashҳ��д���
void wait_page_rw_ok(void)
{    
      while(SPMCSR & 0x40)
     {
         while(SPMCSR & 0x01);
         SPMCSR = 0x11;
         #asm
            spm
         #endasm  
     }
}
#pragma warn+
//����һ��Flashҳ����������
void write_one_page(void)
{  
    uint i;
    boot_page_ew(address,0x03);                    //����һ��Flashҳ
    wait_page_rw_ok();                            //�ȴ��������
    for(i=0;i<SPM_PAGESIZE;i+=2)                //����������Flash����ҳ��
    {
        boot_page_fill(i, (data[i]|((uint)(data[i+1])<<8)));
    }
    boot_page_ew(address,0x05);                    //������ҳ����д��һ��Flashҳ
    wait_page_rw_ok();                            //�ȴ�д�����            
}        
//��RS232����һ���ֽ�
void uart_putchar(uchar c)
{
    while(!(UCSR0A & 0x20));
    UDR0 = c;
}

void USART_Send_string(flash uchar *data)
{
    uint i = 0;
    while(data[i] != '\0')
    uart_putchar(data[i++]);
}
//��RS232����һ���ֽ�
int uart_getchar(void)
{
    unsigned char status,res;
    if(!(UCSR0A & 0x80)) return -1;
    status = UCSR0A;
    res = UDR0;      
    if (status & 0x1c) return -1;        // If error, return -1
    return res;
}
//�ȴ���RS232����һ����Ч���ֽ�
uchar uart_waitchar(void)
{
    int c;
    do
    {
        c=uart_getchar();
    }
    while(c==-1);
    return (uchar)c;
}
//����CRC
uint calcrc(uchar *ptr, uchar count)
{
    uint recalcrc = 0;
    uchar i,j = 0;
    
    while (count >= ++j)
    {
        recalcrc = recalcrc ^ (uint)*ptr++ << 8;
        i = 8;
        do
        {
            if (recalcrc & 0x8000)
                recalcrc = recalcrc << 1 ^ 0x1021;
            else
                recalcrc = recalcrc << 1;
        }while(--i);
    }
    return recalcrc;
}

#ifdef  UPDATE_USB
//----------------------------------------------U��ģʽ-----------------------------------------------------------------

/* ���ӵ�USB����״̬���� */
#define		ERR_USB_UNKNOWN		0xFA	/* δ֪����,��Ӧ�÷��������,����Ӳ�����߳������ */
#define		TRUE	1
#define		FALSE	0
#define	SER_SYNC_CODE1		0x57			/* ���������ĵ�1������ͬ���� */
#define	SER_SYNC_CODE2		0xAB			/* ���������ĵ�2������ͬ���� */
#define	CMD01_GET_STATUS	0x22			/* ��ȡ�ж�״̬��ȡ���ж����� */
#define	CMD0H_DISK_CONNECT	0x30			/* �����ļ�ģʽ/��֧��SD��: �������Ƿ����� */
#define	CMD0H_DISK_MOUNT	0x31			/* �����ļ�ģʽ: ��ʼ�����̲����Դ����Ƿ���� */

/************����1����һ������********************/

void USART_Send_word_1(uchar data)
{
    while (!(UCSR1A & (1<<UDRE1)));        //�ȴ����ͻ�����Ϊ�գ�
    UDR1 = data;        //�����ݷ��뻺�������������ݣ�
}

uchar USART_Receive_1(void)
{
// �ȴ���������
    uint i = 0;
    while(!(UCSR1A & (1<<RXC1))){if((++i)>65530)return 0;};
    return UDR1;
}
/*
void USART_Send_string_1(uchar *data,uchar length)
{
    uchar i;
   for(i = 0; i < length; i++)
    USART_Send_word_1(data[i]);
}*/

void xWriteCH376Cmd(uchar mCmd)  /* ��CH376д���� */
{
	USART_Send_word_1(SER_SYNC_CODE1);
    USART_Send_word_1(SER_SYNC_CODE2);  /* ���������ĵ�2������ͬ���� */
	USART_Send_word_1(mCmd);  /* ������� */
}

void xWriteCH376Data(uchar mData)  /* ��CH376д���� */
{
	USART_Send_word_1(mData);  /* ������� */
}

uchar xReadCH376Data( void )  /* ��CH376������ */
{
	return USART_Receive_1();  /* �������� */
}

uchar CH376GetIntStatus( void )  /* ��ȡ�ж�״̬��ȡ���ж����� */
{
	uchar	s;
	xWriteCH376Cmd(CMD01_GET_STATUS);
	s = xReadCH376Data();
	return(s);
}

uchar Wait376Interrupt(void)  /* �ȴ�CH376�ж�(INT#�͵�ƽ)�������ж�״̬��, ��ʱ�򷵻�ERR_USB_UNKNOWN */
{
	long	i;
	for( i = 0; i < 5000000; i ++ ) {  /* ������ֹ��ʱ,Ĭ�ϵĳ�ʱʱ��,�뵥Ƭ����Ƶ�й� */
		if(USART_Receive_1()) return(CH376GetIntStatus( ));  /* ��⵽�ж� */
/* �ڵȴ�CH376�жϵĹ�����,������Щ��Ҫ��ʱ�������������� */
	}
	return(ERR_USB_UNKNOWN);  /* ��Ӧ�÷�������� */
}

uchar CH376SendCmdWaitInt(uchar mCmd)  /* �����������,�ȴ��ж� */
{
	xWriteCH376Cmd(mCmd);
	return Wait376Interrupt();
}

/* ��ѯCH376�ж�(INT#�͵�ƽ) */
uchar Query376Interrupt(void)
{
    return USART_Receive_1();
}

uchar CH376DiskConnect(void)/*���U���Ƿ�����*/ 
{
    if (Query376Interrupt( )) CH376GetIntStatus( );  /* ��⵽�ж� */
    return(CH376SendCmdWaitInt(CMD0H_DISK_CONNECT));
}
#define	CMD50_WRITE_VAR32	0x0D			/* ����ָ����32λ�ļ�ϵͳ���� */
void CH376WriteVar32(uchar var, unsigned long dat )  /* дCH376оƬ�ڲ���32λ���� */
{
	xWriteCH376Cmd(CMD50_WRITE_VAR32);
	xWriteCH376Data(var);
	xWriteCH376Data((uchar)dat);
	xWriteCH376Data((uchar)((uint)dat >> 8));
	xWriteCH376Data((uchar)(dat >> 16));
	xWriteCH376Data((uchar)(dat >> 24));
}


uchar CH376DiskMount(void)  /* ��ʼ�����̲����Դ����Ƿ���� */
{
	return(CH376SendCmdWaitInt(CMD0H_DISK_MOUNT)); 
}
#define	CMD10_SET_FILE_NAME	0x2F			/* �����ļ�ģʽ: ���ý�Ҫ�������ļ����ļ��� */
#define	DEF_SEPAR_CHAR1		0x5C			/* ·�����ķָ��� '\' */
#define	DEF_SEPAR_CHAR2		0x2F			/* ·�����ķָ��� '/' */
#define	VAR_CURRENT_CLUST	0x64			/* ��ǰ�ļ��ĵ�ǰ�غ�(�ܳ���32λ,���ֽ���ǰ) */
#define	CMD0H_FILE_OPEN		0x32			/* �����ļ�ģʽ: ���ļ�����Ŀ¼(�ļ���),����ö���ļ���Ŀ¼(�ļ���) */

uchar CH376FileOpen(uchar * name)  /* �ڸ�Ŀ¼���ߵ�ǰĿ¼�´��ļ�����Ŀ¼(�ļ���) */
{
   /* ���ý�Ҫ�������ļ����ļ��� */  
   	uchar	c;
	xWriteCH376Cmd( CMD10_SET_FILE_NAME );
	c = *name;
	xWriteCH376Data(c);
	while (c)
    {
		name++;
		c = *name;
		if (c == DEF_SEPAR_CHAR1 || c == DEF_SEPAR_CHAR2) c = 0;  /* ǿ�н��ļ�����ֹ */
		xWriteCH376Data(c);
	}
	if (name[0] == DEF_SEPAR_CHAR1 || name[0] == DEF_SEPAR_CHAR2) CH376WriteVar32( VAR_CURRENT_CLUST, 0 );
	return(CH376SendCmdWaitInt(CMD0H_FILE_OPEN));
}

#define	CMD1H_FILE_CLOSE	0x36			/* �����ļ�ģʽ: �رյ�ǰ�Ѿ��򿪵��ļ�����Ŀ¼(�ļ���) */
uchar CH376FileClose(uchar UpdateSz)  /* �رյ�ǰ�Ѿ��򿪵��ļ�����Ŀ¼(�ļ���) */
{
    xWriteCH376Cmd(CMD1H_FILE_CLOSE);
	xWriteCH376Data(UpdateSz);
	return(Wait376Interrupt());
}

#define	CMD01_RD_USB_DATA0	0x27			/* �ӵ�ǰUSB�жϵĶ˵㻺�������������˵�Ľ��ջ�������ȡ���ݿ� */
uchar CH376ReadBlock(uchar * buf)  /* �ӵ�ǰ�����˵�Ľ��ջ�������ȡ���ݿ�,���س��� */
{
	uchar s, l;
	xWriteCH376Cmd(CMD01_RD_USB_DATA0);
	s = l = xReadCH376Data( );  /* ���� */
	if(l)
    {
		do {
			*buf = xReadCH376Data( );
			buf ++;
		} while ( -- l );
	}
	return( s );
}

#define	CMD2H_BYTE_READ		0x3A			/* �����ļ�ģʽ: ���ֽ�Ϊ��λ�ӵ�ǰλ�ö�ȡ���ݿ� */
#define	USB_INT_DISK_READ	0x1D			/* USB�洢���������ݶ��� */
#define	CMD0H_BYTE_RD_GO	0x3B			/* �����ļ�ģʽ: �����ֽڶ� */
uchar CH376ByteRead(uchar * buf, uint ReqCount, uint * RealCount )  /* ���ֽ�Ϊ��λ�ӵ�ǰλ�ö�ȡ���ݿ� */
{
	uchar	s;
	xWriteCH376Cmd(CMD2H_BYTE_READ);
	xWriteCH376Data((uchar)ReqCount);
	xWriteCH376Data((uchar)(ReqCount>>8));
	if (RealCount) *RealCount = 0;
	while ( 1 ) 
    {
		s = Wait376Interrupt( );
		if (s == USB_INT_DISK_READ) 
        {
			s = CH376ReadBlock(buf);  /* �ӵ�ǰ�����˵�Ľ��ջ�������ȡ���ݿ�,���س��� */
			xWriteCH376Cmd(CMD0H_BYTE_RD_GO);
			buf += s;
			if (RealCount) *RealCount += s;
		}
		else return(s);  /* ���� */
	}
}


unsigned long CH376Read32bitDat( void )  /* ��CH376оƬ��ȡ32λ�����ݲ��������� */
{
	uchar	c0, c1, c2, c3;
	c0 = xReadCH376Data( );
	c1 = xReadCH376Data( );
	c2 = xReadCH376Data( );
	c3 = xReadCH376Data( );
	return(((unsigned long)c3 << 24) | ((unsigned long)c2 << 16) | ((unsigned long)c1 << 8) | c0 );
}

#define	CMD14_READ_VAR32	0x0C			/* ��ȡָ����32λ�ļ�ϵͳ���� */
unsigned long CH376ReadVar32(uchar var)  /* ��CH376оƬ�ڲ���32λ���� */
{
	xWriteCH376Cmd(CMD14_READ_VAR32);
	xWriteCH376Data(var);
	return(CH376Read32bitDat( ) );  /* ��CH376оƬ��ȡ32λ�����ݲ��������� */
}

#define	VAR_FILE_SIZE		0x68			/* ��ǰ�ļ��ĳ���(�ܳ���32λ,���ֽ���ǰ) */
unsigned long CH376GetFileSize(void)  /* ��ȡ��ǰ�ļ����� */
{
	return(CH376ReadVar32(VAR_FILE_SIZE));
}
//--------------------------------------------------END--------------------------------------------------------------
#endif
//�˳�Bootloader���򣬴�0x0000��ִ��Ӧ�ó���
void quit(void)
{
      uart_putchar('O');uart_putchar('K');
      uart_putchar(0x0d);uart_putchar(0x0a);
     while(!(UCSR0A & 0x20));            //�ȴ�������ʾ��Ϣ�������
     MCUCR = 0x01;
     MCUCR = 0x00;                    //���ж�������Ǩ�Ƶ�Ӧ�ó�����ͷ��
     RAMPZ = 0x00;                    //RAMPZ�����ʼ��
     #asm("jmp 0x0000")        //��ת��Flash��0x0000����ִ���û���Ӧ�ó���
}


#define	CMD11_CHECK_EXIST	0x06			/* ����ͨѶ�ӿں͹���״̬ */
#define	CMD11_SET_USB_MODE	0x15			/* ����USB����ģʽ */
#define	CMD_RET_SUCCESS		0x51			/* ��������ɹ� */
#define	CMD_RET_ABORT		0x5F			/* �������ʧ�� */
#define	USB_INT_SUCCESS		0x14			/* USB������ߴ�������ɹ� */
#define	ERR_MISS_FILE		0x42			/* ָ��·�����ļ�û���ҵ�,�������ļ����ƴ��� */
//������
void main(void)
{
    uint i = 0;
    uint timercount = 0;
    uchar packNO = 1;
    uint bufferPoint = 0;
    uint crc;     
#ifdef  UPDATE_USB    
    uchar s;
    uint j;
    unsigned long UpdateSize = 0;
    uint LabCount = 0,lastdatanum = 0;     
    uchar string[50] = {0};
#endif   
 
//��ʼ��M128��USART0   
    UBRR0L = BAUD_L;            //Set baud rate 
    UBRR0H = BAUD_H; 
    UCSR0B = ((1<<RXEN0)|(1<<TXEN0));        //�������뷢����ʹ�ܣ�
    UCSR0C = (1<<USBS0)|(3<<UCSZ00);        //����֡��ʽ: 8 ������λ, 1 ��ֹͣλ��
#ifdef  UPDATE_USB    
//��ʼ��M128��USART1    
    UBRR1L = 8;
    UBRR1H = 0;
    UCSR1B = ((1<<RXEN1)|(1<<TXEN1));        //�������뷢����ʹ�ܣ�
    UCSR1C = (1<<USBS1)|(3<<UCSZ10);        //����֡��ʽ: 8 ������λ, 1 ��ֹͣλ��
#endif    
//��ʼ��M128��T/C0��15ms�Զ�����
    OCR0 = 0x75;
    TCCR0 = 0x0F;                                                               
    TCNT0 = 0;  
    
    DDRB.0 = 1;
    PORTB.0 = 1;  
    /*
    USART_Send_string(a4String1);
    while(uart_getchar()!='O');
    while(uart_getchar()!='K');
    USART_Send_string(a4String2);  
    while(uart_getchar()!='O');
    while(uart_getchar()!='K');  
    */
    USART_Send_string(startupString);//��PC�����Ϳ�ʼ��ʾ��Ϣ  
    while(1)
    {    
        if(uart_getchar()=='d')break;
        if(TIFR&0x02)
        {
            if(++timercount>500) //��û�н��봮������ģʽ�������U������ģʽ 200*15ms=3s
            {     
#ifdef  UPDATE_USB
    
                sprintf((char*)string,"Enter the USB_Disk Update!\n",UpdateSize);
                USART_Send_string(string);      
                //++++++++++++++++��ʼ��CH376S++++++++++++++++++++++++       
                //CH376_PORT_INIT( );  /* �ӿ�Ӳ����ʼ�� */
	            xWriteCH376Cmd(CMD11_CHECK_EXIST);  /* ���Ե�Ƭ����CH376֮���ͨѶ�ӿ� */
	            xWriteCH376Data(0x65);  
	            s = xReadCH376Data( );
	            if (s != 0x9A) 
                    uart_putchar(ERR_USB_UNKNOWN);  /* ͨѶ�ӿڲ�����,����ԭ����:�ӿ������쳣,�����豸Ӱ��(Ƭѡ��Ψһ),���ڲ�����,һֱ�ڸ�λ,���񲻹��� */
	            xWriteCH376Cmd(CMD11_SET_USB_MODE);  /* �豸USB����ģʽ */
	            xWriteCH376Data(0x06);
	            s = xReadCH376Data( );
	            if (s != CMD_RET_SUCCESS)  
                {
                    sprintf((char*)string,"USB_Disk is wrong init!\n",UpdateSize);
                    USART_Send_string(string); 
                    quit();
                }   
                //++++++++++++++++++++++END+++++++++++++++++++++++++++++++++
                //���U���Ƿ����Ӻ�
                i = 0;
                while(CH376DiskConnect() != USB_INT_SUCCESS)
                {
                    if(++i > 5)
                    {   
                        sprintf((char*)string,"USB_Disk is not Connection!\n",UpdateSize);
                        USART_Send_string(string); 
                        quit(); 
                    }
                    delay_ms(100);
                }                  
                i = 0;
                // ���ڼ�⵽USB�豸��,���ȴ�10*50mS 
                if(CH376DiskMount() != USB_INT_SUCCESS)
                {
                    if(++i > 5)
                    {
                        sprintf((char*)string,"USB_Disk Test Wrong!\n",UpdateSize);
                        USART_Send_string(string); 
                        quit();
                    }
                    delay_ms(100);   
                }        
                //�������ļ�
                s = CH376FileOpen("J8A-1.U");//ÿ̨���ӣ���Ӧ�����ļ���
                if (s == ERR_MISS_FILE) //û���ҵ������ļ����˳�
                {
                    CH376FileClose(TRUE);
                    sprintf((char*)string,"I can't fined the Update_File!\n",UpdateSize);
                    USART_Send_string(string);
                    quit();     
                }           
                UpdateSize = CH376GetFileSize(); 
                sprintf((char*)string,"The Update_File size is :%dl\n",UpdateSize); 
                USART_Send_string(string);   
                
                LabCount = UpdateSize/SPM_PAGESIZE;
                lastdatanum = UpdateSize%SPM_PAGESIZE;
                if(lastdatanum) 
                    LabCount++;  
                if(LabCount > (512-32))//mega128��flashҳ�� 
                {
                    sprintf((char*)string,"The Update_File size is too big!",UpdateSize); 
                    USART_Send_string(string);
                    CH376FileClose(FALSE); 
                    quit();
                }
                //��ȡ�����ļ�����          
                for(i = 0; i < LabCount; i++)
                {     
                       
                    if(lastdatanum && (i == (LabCount - 1)))     
                    {                                    
                        CH376ByteRead(data, lastdatanum, NULL); 
                        for(j = lastdatanum; j < SPM_PAGESIZE; j++)
                            data[j] = 0xFF;
                    }
                    else
                        CH376ByteRead(data, SPM_PAGESIZE, NULL);        
                    write_one_page();   
                    address = address + SPM_PAGESIZE;    //Flashҳ��1
                }
                //write_one_page();         //�յ�256�ֽ�д��һҳFlash��
                //address = address + SPM_PAGESIZE;    //Flashҳ��1
                //�ر��ļ�                     
                CH376FileClose(FALSE);
#endif
                quit();
            }
            TIFR=TIFR|0x02;
        }
    }
    //ÿ����PC������һ�������ַ�"C"���ȴ������֡�soh��
    while(uart_getchar()!= XMODEM_SOH)        //receive the start of Xmodem
    {
         if(TIFR & 0x02)              //timer0 over flow
        {
            if(++timercount > 100)                   //wait about 1 second
            {
                uart_putchar(XMODEM_RECIEVING_WAIT_CHAR);   //send a "C"
                timercount = 0;
            }
            TIFR = TIFR&0x02;
        }
    }
    //��ʼ�������ݿ�
    do
    {
        if ((packNO == uart_waitchar()) && (packNO ==(~uart_waitchar())))
        {    //�˶����ݿ�����ȷ
            for(i=0;i<128;i++)             //����128���ֽ�����
            {
                data[bufferPoint]= uart_waitchar();
                bufferPoint++;    
            }
            crc = (uint)(uart_waitchar())<<8;
            crc = crc | uart_waitchar();        //����2���ֽڵ�CRCЧ����
            if(calcrc(&data[bufferPoint-128],128) == crc)    //CRCУ����֤
            {    //��ȷ����128���ֽ�����
                while(bufferPoint >= SPM_PAGESIZE)
                {    //��ȷ����256���ֽڵ�����
                    write_one_page();         //�յ�256�ֽ�д��һҳFlash��
                    address = address + SPM_PAGESIZE;    //Flashҳ��1
                    bufferPoint = 0;
                }    
                uart_putchar(XMODEM_ACK);      //��ȷ�յ�һ�����ݿ�
                packNO++;                      //���ݿ��ż�1
            }
            else
            {
                uart_putchar(XMODEM_NAK);     //Ҫ���ط����ݿ�
            }
        }
        else
        {
            uart_putchar(XMODEM_NAK);           //Ҫ���ط����ݿ�
        }
    }while(uart_waitchar()!=XMODEM_EOT);          //ѭ�����գ�ֱ��ȫ������
    uart_putchar(XMODEM_ACK);                    //֪ͨPC��ȫ���յ�
    
    if(bufferPoint) write_one_page();        //��ʣ�������д��Flash��
    quit();                //�˳�Bootloader���򣬴�0x0000��ִ��Ӧ�ó���       
}