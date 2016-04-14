;- 本例程将 RAM 中的一页数据写入 Flash
; Y 指针指向 RAM 的第一个数据单元
;Z 指针指向 Flash 的第一个数据单元
;- 本例程没有包括错误处理
;- 该程序必须放置于 Boot 区 ( 至少 Do_spm 子程序是如此 )
; 在自编程过程中 ( 页擦除和页写操作 ) 只能读访问 NRWW 区的代码
;- 使用的寄存器：r0、 r1、 temp1 (r16)、 temp2 (r17)、 looplo (r24)、
; loophi (r25)、 SPMCSRval (r20)
; 在程序中不包括寄存器内容的保护和恢复
; 在牺牲代码大小的情况下可以优化寄存器的使用
;- 假设中断向量表位于 Boot loader 区 , 或者中断被禁止。
.equ PAGESIZEB = PAGESIZE*2 ;PAGESIZEB 是以字节为单位的页大小，不是以字为单位
.org SMALLBOOTSTART
Write_page:
; 页擦除
ldi SPMCSRval, (1<<PGERS) | (1<<SPMEN)
call Do_spm
; 重新使能 RWW 区
ldi SPMCSRval, (1<<RWWSRE) | (1<<SPMEN)
call Do_spm
; 将数据从 RAM 转移到 Flash 页缓冲区
ldi looplo, low(PAGESIZEB) ; 初始化循环变量
ldi loophi, high(PAGESIZEB) ;PAGESIZEB<=256 时不需要此操作
Wrloop:
ld r0, Y+
ld r1, Y+
ldi SPMCSRval, (1<<SPMEN)
call Do_spm
adiw ZH:ZL, 2
sbiw loophi:looplo, 2 ;PAGESIZEB<=256 时请使用 subi
brne Wrloop
; 执行页写
subi ZL, low(PAGESIZEB) ; 复位指针
sbci ZH, high(PAGESIZEB) ;PAGESIZEB<=256 时不需要此操作
ldi SPMCSRval, (1<<PGWRT) | (1<<SPMEN)
call Do_spm
; 重新使能 RWW 区
ldi SPMCSRval, (1<<RWWSRE) | (1<<SPMEN)
call Do_spm
; 读回数据并检查，为可选操作
ldi looplo, low(PAGESIZEB) ; 初始化循环变量
ldi loophi, high(PAGESIZEB) ;PAGESIZEB<=256 时不需要此操作
subi YL, low(PAGESIZEB) ; 复位指针
sbci YH, high(PAGESIZEB)
Rdloop:
lpm r0, Z+
ld r1, Y+
cpse r0, r1
jmp Error
sbiw loophi:looplo, 1 ;PAGESIZEB<=256 时请使用 subi
brne Rdloop
; 返回到 RWW 区
; 确保 RWW 区已经可以安全读取
Return:
lds temp1, SPMCSR
sbrs temp1, RWWSB ; 若 RWWSB 为 "1"，说明 RWW 区还没有准备好
ret
; 重新使能 RWW 区
ldi SPMCSRval, (1<<RWWSRE) | (1<<SPMEN)
call Do_spm
rjmp Return
Do_spm:
; 检查先前的 SPM 操作是否已经完成
Wait_spm:
lds temp1, SPMCSR
sbrc temp1, SPMEN
rjmp Wait_spm
;; 输入：SPMCSRval 决定了 SPM 操作
; 禁止中断，保存状态标志
in temp2, SREG
cli
; 确保没有 EEPROM 写操作
Wait_ee:
sbic EECR, EEWE
rjmp Wait_ee
; SPM 时间序列
sts SPMCSR, SPMCSRval
spm
; 恢复 SREG ( 如果中断原本是使能的，则使能中断 )
out SREG, temp2
ret

