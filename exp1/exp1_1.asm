.data
    buffer: .space 8 #int���鳤��Ϊ2����Ҫ2*4=8���ֽ�
    infile: .asciiz "a.in"
    outfile: .asciiz "a.out"

.text
main:
    la $a0, infile
    li $a1, 0#flag����Ϊ0����ȡ�ļ�
    li $a2, 0
    li $v0, 13  #��in�ļ�
    syscall
    move $a0, $v0
    la $a1, buffer
    li $a2, 8#��ȡ8��byte
    li $v0, 14#��ȡin�ļ�
    syscall
    li $v0 16#�ر�in�ļ�
    syscall
    la $a0, outfile
    li $a1, 1#flag����Ϊ1��д��
    li $a2, 0
    li $v0, 13#��out�ļ�
    syscall
    move $a0, $v0
    la $a1, buffer
    li $a2, 8#��ȡ8��byte
    li $v0, 15#д��out�ļ�
    syscall
    li $v0 16#�ر�out�ļ�
    syscall
    li $v0, 5#����һ������
    syscall
    move $t0, $v0
    addi $t0, $t0, 10#i = i + 10
    move $a0, $t0
    li $v0, 1#��ӡһ������
    syscall
