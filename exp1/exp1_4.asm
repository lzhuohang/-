.text
main:
    li $v0, 5#��������ģʽ����
    syscall
    move $a0, $v0#�������n��������a0
    jal Hanoi#��ת��Hanoi������������һ��ָ��ĵ�ַ�洢�� $ra ��
    move $a0, $v0#v0�������Hanoi��������a0�Թ���ӡ
    li $v0, 1#ϵͳ���ô�ӡ
    syscall
    li $v0, 10# ����ϵͳ���ú� 10����ʾ�����˳�
    syscall             

Hanoi:
    beq $a0, 1, Hanoi1
    subi $sp, $sp, 4  #����1�ִ�Сջ�ռ��ra�����ݹ���һ�����ص�ַ
    sw $ra, 0($sp)
    subi $a0, $a0, 1
    jal Hanoi#����Hanoi��n-1��
    sll $v0,$v0,1
    addi $v0,$v0,1 #���ؽ��2*v0+1
    lw $ra, 0($sp)#������һ���ݹ��ַ
    addi $sp, $sp, 4#����ü�ջ
    jr $ra#��ת����һ���ݹ�

Hanoi1:
    li $v0, 1
    jr $ra
    
   

