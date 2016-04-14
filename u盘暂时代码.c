UINT8 mInitCH376Host( void )  /* 初始化CH376 */
{
	UINT8 res;     
	CH376_PORT_INIT( );  /* 接口硬件初始化 */
	xWriteCH376Cmd(CMD11_CHECK_EXIST);  /* 测试单片机与CH376之间的通讯接口 */
	xWriteCH376Data(0x65);  
	res = xReadCH376Data( );
	if ( res != 0x9A ) return( ERR_USB_UNKNOWN );  /* 通讯接口不正常,可能原因有:接口连接异常,其它设备影响(片选不唯一),串口波特率,一直在复位,晶振不工作 */
    //res = xReadCH376Data();  
    //SET_WORK_BAUDRATE( );  /* 将单片机切换到正式通讯波特率 */
	//if ( res != CMD_RET_SUCCESS ) return( ERR_USB_UNKNOWN );  /* 通讯波特率切换失败,建议通过硬件复位CH376后重试 */
	xWriteCH376Cmd( CMD11_SET_USB_MODE );  /* 设备USB工作模式 */
	xWriteCH376Data( 0x06 );
	res = xReadCH376Data( );
	if ( res == CMD_RET_SUCCESS ) return( USB_INT_SUCCESS );
	else return( ERR_USB_UNKNOWN );  /* 设置模式错误 */
}