.text
main:
    li $v0, 5#�����һ������i
    syscall
    move $t0, $v0#������һ������
    li $v0, 5#����ڶ�������j
    syscall
    move $t1, $v0#�����ڶ�������
    sub $t0, $zero, $t0#i=0-i=-i��ȡ����
    blt $t1, $zero, if#��֧�жϣ�j<0��
    move $t2, $zero#temp=0
loop:
    bgt $t2, $t1, loop_end
    beq $t2, $t1, loop_end#temp��jʱ�������˳�
    addi $t0, $t0, 1#i=i+1
    addi $t2, $t2, 1#++temp
    j loop#����ѭ����ִ��for
if:
    sub $t1, $zero, $t1#j=0-j=-j��ȡ����
    move $t2, $zero#temp=0
    j loop
loop_end:
    move $a0, $t0#������i����a0���д�ӡ
    li $v0, 1#����Ϊ��ӡģʽ
    syscall
    move $v0, $t0#���н���洢��v0


