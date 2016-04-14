
/*****************Atmega128A PLC I/O引脚设置*************************/

/*********input_X**********/
#define I_X0   PINA.3
#define I_X1   PINA.4
#define I_X2   PINA.5
#define I_X3   PINA.6
#define I_X4   PINA.7
#define I_X5   (PING&0x04)
#define I_X6   PINC.7
#define I_X7   PINC.6
#define I_X8   PINC.5
#define I_X9   PINC.4
#define I_X10  PINC.3
#define I_X11  PINC.2
#define I_X12  PINC.1
#define I_X13  PINC.0
#define I_X14  (PING&0x02)
#define I_X15  (PING&0x01)
#define I_X16  PIND.7
#define I_X17  PIND.6
#define I_X18  PIND.5
#define I_X19  PIND.4
#define I_X20  PIND.3
#define I_X21  PIND.2
#define I_X22  PIND.1
#define I_X23  PIND.0


/*********output_Y**********/
#define Y0(X)  PORTA.2=(X)
#define Y1(X)  PORTA.0=(X)
#define Y2(X)  PORTA.1=(X)
#define Y3(X)  PORTF=(PORTF&0xBF)|(X<<6)
#define Y4(X)  PORTF=(PORTF&0x7F)|(X<<7)
#define Y5(X)  PORTF=(PORTF&0xEF)|(X<<4)
#define Y6(X)  PORTF=(PORTF&0xDF)|(X<<5)
#define Y7(X)  PORTF=(PORTF&0xFB)|(X<<2)
#define Y8(X)  PORTF=(PORTF&0xF7)|(X<<3)
#define Y9(X)  PORTF=(PORTF&0xFE)|(X<<0)
#define Y10(X)  PORTF=(PORTF&0xFD)|(X<<1)
#define Y11(X)  PORTE.3=(X)
#define Y12(X)  PORTE.2=(X)
#define Y13(X)   PORTE.5=(X)
#define Y14(X)   PORTE.4=(X)
#define Y15(X)   PORTE.7=(X)
#define Y16(X)   PORTE.6=(X)
#define Y17(X)   PORTB.5=(X)
#define Y18(X)   PORTB.4=(X)
#define Y19(X)   PORTB.7=(X)
#define Y20(X)   PORTB.6=(X)
#define Y21(X)   PORTG=(PORTG&0xEF)|(X<<4)
#define Y22(X)   PORTG=(PORTG&0xF7)|(X<<3)

/*
#define R_Y0   PORTA.3
#define R_Y2   PORTA.2
#define R_Y4   PORTA.1
#define R_Y6   PORTA.0
#define R_Y8   ((PORTF&0x80)>>7)
#define R_Y10  ((PORTF&0x40)>>6)
#define R_Y12  PORTC.6
#define R_Y14  PORTC.7
#define R_Y16  PORTA.7
#define R_Y18  PORTA.6
#define R_Y20  PORTA.5
#define R_Y22  PORTA.4
*/
/********************/

/**********RUN_LED* *************/
#define LED_run(X)  PORTB.0=(X)

/************自定义************/
#define x_pulse(X) Y0(X) //2个坐标进给脉冲，一个脉冲走一步
#define y_pulse(X) Y2(X)
#define z_pulse(X) Y4(X)
#define r_pulse(X) Y6(X)
#define w_pulse(X) Y8(X)
#define x_dir(X)   Y10(X)   //2个坐标进给方向控制，=0正走
#define y_dir(X)   Y12(X)
#define z_dir(X)   Y14(X)
#define r_dir(X)   Y16(X)
#define w_dir(X)   Y18(X)

#define R_x_pulse R_Y0 //2个坐标进给脉冲，一个脉冲走一步
#define R_y_pulse R_Y2
#define R_z_pulse R_Y4
#define R_r_pulse R_Y6
#define R_w_pulse R_Y8
#define R_x_dir   R_Y10   //2个坐标进给方向控制，=0正走
#define R_y_dir   R_Y12
#define R_z_dir   R_Y14
#define R_r_dir   R_Y16
#define R_w_dir   R_Y18




/*****************************************/