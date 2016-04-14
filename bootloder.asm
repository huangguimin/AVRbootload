;- �����̽� RAM �е�һҳ����д�� Flash
; Y ָ��ָ�� RAM �ĵ�һ�����ݵ�Ԫ
;Z ָ��ָ�� Flash �ĵ�һ�����ݵ�Ԫ
;- ������û�а���������
;- �ó����������� Boot �� ( ���� Do_spm �ӳ�������� )
; ���Ա�̹����� ( ҳ������ҳд���� ) ֻ�ܶ����� NRWW ���Ĵ���
;- ʹ�õļĴ�����r0�� r1�� temp1 (r16)�� temp2 (r17)�� looplo (r24)��
; loophi (r25)�� SPMCSRval (r20)
; �ڳ����в������Ĵ������ݵı����ͻָ�
; �����������С������¿����Ż��Ĵ�����ʹ��
;- �����ж�������λ�� Boot loader �� , �����жϱ���ֹ��
.equ PAGESIZEB = PAGESIZE*2 ;PAGESIZEB �����ֽ�Ϊ��λ��ҳ��С����������Ϊ��λ
.org SMALLBOOTSTART
Write_page:
; ҳ����
ldi SPMCSRval, (1<<PGERS) | (1<<SPMEN)
call Do_spm
; ����ʹ�� RWW ��
ldi SPMCSRval, (1<<RWWSRE) | (1<<SPMEN)
call Do_spm
; �����ݴ� RAM ת�Ƶ� Flash ҳ������
ldi looplo, low(PAGESIZEB) ; ��ʼ��ѭ������
ldi loophi, high(PAGESIZEB) ;PAGESIZEB<=256 ʱ����Ҫ�˲���
Wrloop:
ld r0, Y+
ld r1, Y+
ldi SPMCSRval, (1<<SPMEN)
call Do_spm
adiw ZH:ZL, 2
sbiw loophi:looplo, 2 ;PAGESIZEB<=256 ʱ��ʹ�� subi
brne Wrloop
; ִ��ҳд
subi ZL, low(PAGESIZEB) ; ��λָ��
sbci ZH, high(PAGESIZEB) ;PAGESIZEB<=256 ʱ����Ҫ�˲���
ldi SPMCSRval, (1<<PGWRT) | (1<<SPMEN)
call Do_spm
; ����ʹ�� RWW ��
ldi SPMCSRval, (1<<RWWSRE) | (1<<SPMEN)
call Do_spm
; �������ݲ���飬Ϊ��ѡ����
ldi looplo, low(PAGESIZEB) ; ��ʼ��ѭ������
ldi loophi, high(PAGESIZEB) ;PAGESIZEB<=256 ʱ����Ҫ�˲���
subi YL, low(PAGESIZEB) ; ��λָ��
sbci YH, high(PAGESIZEB)
Rdloop:
lpm r0, Z+
ld r1, Y+
cpse r0, r1
jmp Error
sbiw loophi:looplo, 1 ;PAGESIZEB<=256 ʱ��ʹ�� subi
brne Rdloop
; ���ص� RWW ��
; ȷ�� RWW ���Ѿ����԰�ȫ��ȡ
Return:
lds temp1, SPMCSR
sbrs temp1, RWWSB ; �� RWWSB Ϊ "1"��˵�� RWW ����û��׼����
ret
; ����ʹ�� RWW ��
ldi SPMCSRval, (1<<RWWSRE) | (1<<SPMEN)
call Do_spm
rjmp Return
Do_spm:
; �����ǰ�� SPM �����Ƿ��Ѿ����
Wait_spm:
lds temp1, SPMCSR
sbrc temp1, SPMEN
rjmp Wait_spm
;; ���룺SPMCSRval ������ SPM ����
; ��ֹ�жϣ�����״̬��־
in temp2, SREG
cli
; ȷ��û�� EEPROM д����
Wait_ee:
sbic EECR, EEWE
rjmp Wait_ee
; SPM ʱ������
sts SPMCSR, SPMCSRval
spm
; �ָ� SREG ( ����ж�ԭ����ʹ�ܵģ���ʹ���ж� )
out SREG, temp2
ret

