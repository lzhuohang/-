.text
main:
    li $v0, 5#��������n
    syscall
    move $a0, $v0#�����ڴ��СΪn
    move $s1, $v0#s1����n��ֵ
    sll $a0, $a0, 2#����a0*4��byte��С�ռ� 
    li $v0, 9#newһ������
    syscall
    move $s0, $v0#v0����ֵ����s0����a�׵�ַ
    move $t0, $zero#����ѭ������iΪt0����ֵΪ0
loop_1:
    li $v0, 5#����һ������
    syscall
    sll $t1, $t0, 2#���������ƫ����
    addu $t1, $t1, $s0#����t1Ϊa[i]ʵ�ʵ�ַ
    sw $v0, 0($t1)#����a[i]ֵ
    addi $t0, $t0, 1#i++
    blt $t0, $s1, loop_1#i��nʱ����ѭ��
    move $t0, $zero#����ѭ������i��ֵΪ0
    sra $s2, $s1, 1#����һλ������s2Ϊn/2
loop_2:
    sll $t1, $t0, 2#���������ƫ����
    addu $t1, $t1, $s0#����t1Ϊa[i]ʵ�ʵ�ַ
    lw $t2, 0($t1)#����t2Ϊa[i]��ֵ
    addi $t3, $t2, 1#t3Ϊt��t=a[i]+1
    sub $t4, $s1, $t0
    subi $t4, $t4, 1#�趨t4Ϊn-i-1
    sll $t4, $t4, 2#�趨������ƫ����
    addu $t4, $t4, $s0#����t4Ϊa[n-i-1]ʵ�ʵ�ַ
    lw $t5, 0($t4)#����t5Ϊa[n-i-1]��ֵ
    addi $t5, $t5, 1#t5=a[n-i-1]+1
    sw $t5, 0($t1)#��t5ֵ��a[n-i-1]+1������a[i]
    sw $t3, 0($t4)#��t3��t��ֵ����a[n-i-1]
    addi $t0, $t0, 1#i++
    blt $t0, $s2, loop_2#i��n/2ʱ����ѭ��
    move $t0, $zero#����ѭ������i��ֵΪ0
loop_3:
    li $v0, 1#��ӡ����
    sll $t1, $t0, 2#��������ƫ����
    addu $t1, $t1, $s0#����t1Ϊa[i]ʵ�ʵ�ַ
    lw $a0, 0($t1)#��Ҫ��ӡ��ֵ���ص�a0
    syscall
    addi $t0, $t0, 1#i++
    blt $t0, $s1, loop_3#i��n/2ʱ����ѭ��
    j end_loop
end_loop:
    li $v0, 10          # ����ϵͳ���ú� 10����ʾ�����˳�
    syscall             # ִ��ϵͳ����
