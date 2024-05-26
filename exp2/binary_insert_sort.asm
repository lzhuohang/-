.data
buffer: .space 4004   # 1001 �� 4 �ֽ������Ļ����������ڴ洢�������ݺ�������
infile: .asciiz "a.in"
outfile: .asciiz "a.out"

.text
main:
    la $a0, infile #�������ļ�
    li $a1, 0 #flag 0Ϊ��ȡ 1Ϊд��
    li $a2, 0 #mode is ignored ����Ϊ0�Ϳ�����
    li $v0, 13 #13 Ϊ���ļ��� syscall ���
    syscall 
    move $a0,$v0 
    la $a1, buffer #in_buff Ϊ�����ݴ���
    li $a2, 4004 #��ȡ4004��byte
    li $v0, 14 #14 Ϊ��ȡ�ļ��� syscall ���
    syscall
    li $v0 16 #16 Ϊ�ر��ļ��� syscall ���
    move $a0, $v0        # �ļ��������洢�� $a0 ��
    syscall
    lw $t0, buffer       # ��buffer[0]��N�����ص� $t0 ��
    move $s1, $t0        # �� N �洢�� $s1 ��
    la $a0, buffer# buffer�����׵�ַ���뵽 $a0��
    addi $a0,$a0,4 # ���������׵�ַ����buffer[1]��ʼ��
    move $s0, $a0        # �����ַ
    move $s2, $zero     # ��ʼ���Ƚϴ���Ϊ 0
    jal binary_insertion_sort   # ���ò���������
    move $t1, $s2        # ���Ƚϴ����洢�� $t1 ��
    sw $t1, buffer       # �洢�Ƚϴ����� buffer[0]
    la $a0, outfile#��out�ļ�
    li $a1, 1#flag����Ϊ1��д��
    li $a2, 0
    li $v0, 13#��out�ļ�
    syscall
    move $a0, $v0
    la $a1, buffer
    move $a2,$s1 
    addi $a2,$a2,1
    sll $a2,$a2,2          # д�� ��N+1���� 4 �ֽ�����
    li $v0, 15#д��out�ļ�
    syscall
    li $v0 16#�ر�out�ļ�
    syscall
    li $v0, 10           # syscall 10: �˳�����
    syscall

# ����������
binary_insertion_sort:
    subi $sp, $sp, 4 #����1�ִ�Сջ�ռ��ra�����ݹ���һ�����ص�ַ
    sw $ra, 0($sp)#����1�ִ�Сջ�ռ��ra�����ݹ���һ�����ص�ַ
    move $t0, $zero  
    addi $t0,$t0,1          #�趨ѭ������i=1
binary_insertion_sort_loop:
    bge $t0, $s1, binary_insertion_exit  # ����Ѿ�����������Ԫ�أ�����ѭ��
    move $s5,$zero #s5����left���˴�Ϊ0
    subi $s6,$t0,1 #s6����right���˴�Ϊi-1
    jal binary_search
    move $t2, $s3#���ҵ���λ�ô�����t2��
    jal insert
    addi $t0,$t0,1#i++
    j binary_insertion_sort_loop
binary_insertion_exit:
    lw $ra, 0($sp)#������ת���������ĵ�ַ
    addi $sp, $sp, 4#����ü�ջ
    jr $ra#����������
binary_search:
    bgt $s5,$s6,binary_search_end
    add $s7,$s5,$s6
    sra $s7,$s7,1#s7����mid
    addi $s2,$s2,1#�Ƚϴ�����һ
    move $t4,$t0  #���β�n������t4��
    sll $s4,$t4,2  #ȷ��v[n+1]����ƫ����
    add $s4,$s4,$s0#ȷ��v[n+1]�ĵ�ַ
    lw $s4,0($s4)#ȷ��v[n+1]��ֵ
    sll $t7,$s7,2
    add $t7,$t7,$s0#ȷ��v[mid+1]��ַ
    lw $t7,0($t7)#ȷ��v[mid+1]ֵ
    bgt $t7,$s4,binary_left
    ble $t7,$s4,binary_right
binary_left:
    move $s5,$s5#left=left
    subi $s7,$s7,1
    move $s6,$s7#right=mid-1
    j binary_search
binary_right:
    move $s6,$s6#right=right
    addi $s7,$s7,1
    move $s5,$s7#left=mid+1
    j binary_search  
binary_search_end:
    move $s3,$s5#����i+1���洢��s3
    jr $ra#����insertion_sort_loop
insert:
    sub $t4,$t0,1             #i=n-1
    sll $s4,$t4,2  #ȷ������ƫ����
    add $s4,$s4,4
    add $s4,$s4,$s0
    lw $s4,0($s4)#ȷ��temp��v[n+1]�ĵ�ַ��
insert_loop:
    blt $t4,$t2,insert_exit#i��kʱ����ѭ��
    move $t5,$t4
    sll $t5,$t5,2
    add $t5,$t5,$s0#ȷ��v[i+1]�ĵ�ַ
    lw $t5,0($t5)#ȷ��v[i+1]��ֵ
    addi $t6,$t4,1
    sll $t6,$t6,2
    add $t6,$t6,$s0#ȷ��v[i+2]�ĵ�ַ
    sw $t5,0($t6)#��v[i+1]ֵ����v[i+2]
    subi $t4,$t4,1#i--
    j insert_loop
insert_exit:
    move $t5,$t2
    sll $t5,$t5,2
    add $t5,$t5,$s0#ȷ��v[k+1]�ĵ�ַ
    sw $s4,0($t5)#��tempֵ����v[k+1]
    jr $ra#����insertion_sort_loop
    
    
    