.data
buffer: .space 4004   # 1001 �� 4 �ֽ������Ļ����������ڴ洢�������ݺ�������
compare: .space 4       # ��űȽϴ���
infile: .asciiz "a.in"
outfile: .asciiz "a.out"

.text
# main ����
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
    move $s2,$zero       #�Ƚϴ�����Ϊ0
    li $a0, 8        # Ҫ������ڴ��СΪ8��2word��
    li $v0, 9          # ����ϵͳ���ú�Ϊ 9
    syscall            
    move $s0, $v0   #v0����ֵ����s0����head�׵�ַ
    sw $zero, 4($s0)  # head[1] = (int)NULL;
    move $s4,$s0 #s4����head
    move $s3,$s0  #s3����pointer
    la $a0, buffer# buffer�����׵�ַ���뵽 $a0��
    addi $s0,$a0,4#s0����buffer[1]�׵�ַ
    li $t0, 1   # ѭ������ idx ��ʼֵΪ 1
#��������
loop:
    bgt $t0, $s1, loop_exit  # ������������� N�������ѭ��
    # �����½ڵ��ڴ�
    li $a0, 8   # ÿ���ڵ��СΪ 8 �ֽڣ����� int ��С��
    li $v0, 9   # syscall 9: �����ڴ�
    syscall
    move $t1, $v0   # ������Ľڵ��ַ�洢�� $t1 ��
    # ���ڵ��ַ�洢����ǰ�ڵ����һ��ָ��λ��
    sw $t1, 4($s3)  # pointer[1] = (int)new int[2];
    # ����ָ����ָ���·���Ľڵ�
    move $s3, $t1   # ����ָ����ָ���·���Ľڵ�
    sll $t3,$t0,2
    subi $t3,$t3,4
    add $t3,$t3,$s0#ȷ��buffer[idx]��ַ
    # �����ݴ洢���½ڵ�����ݳ�Ա��
    lw $t3, 0($t3)  # ȷ��buffer[idx]ֵ
    sw $t3, 0($s3)       # �����ݴ洢���½ڵ�����ݳ�Ա��
    # ���½ڵ����һ��ָ������Ϊ NULL
    sw $zero, 4($s3)  # �� NULL �洢���½ڵ����һ��ָ��λ��
    addi $t0, $t0, 1   #idx++
    j loop
loop_exit:
    lw $s5,4($s4)#s5��Ϊ�βε�head
    jal msort
    sw $t6,4($s4)#t6����head[1] = (int)msort((int *)head[1]);
    move $s3,$s4#s3Ϊpointer��s4Ϊhead;pointer=head
    sw $s2,compare#�Ƚϴ�������compare
    la $a0, outfile#��out�ļ�
    li $a1, 1#flag����Ϊ1��д��
    li $a2, 0
    li $v0, 13#��out�ļ�
    syscall
    move $a0, $v0
    la $a1, compare
    li $a2,4
    li $v0, 15#���Ƚϴ���д��out�ļ�
    syscall
main_end:
    lw $t9,4($s3)#ȷ��pointer[1]��ֵ
    move $s3,$t9#pointer = (int *)pointer[1]
    beq $s3,$zero,main_end_exit
    move $a0, $v0
    move $a1, $s3
    li $a2,4 
    li $v0, 15#�����������ȽϺ��ֵ��д��out�ļ�
    syscall
    j main_end
main_end_exit:
    li $v0 16#�ر�out�ļ�
    syscall
    li $v0, 10           # syscall 10: �˳�����
    syscall
    
msort:
    subi $sp, $sp, 20 #����5�ִ�Сջ�ռ��ra�����ݹ���һ�����ص�ַ��ͷ����ַ����ָ��stride_2_pointer��ַ��l_head(s6),r_head(s7)��ַ����ֹ�ݹ��б�����
    sw $ra, 0($sp)#����1�ִ�Сջ�ռ��ra�����ݹ���һ�����ص�ַ
    sw $s5,4($sp)#���ͷ�ڵ�head
    lw $t0,4($s5)#t0���head[1]
    beq $t0,$zero,msort_exit#head[1]==NULL�˳�����head
    move $t2,$s5#stride_2_pointer������t2��
    move $t1,$s5#stride_1_pointer������t1��
    jal msort_loop
    lw $t4,4($t1)#����stride_1_pointer[1]��ֵ;
    move $t2,$t4#stride_2_pointer = (int *)stride_1_pointer[1];
    sw $t2,8($sp)#��ſ�ָ��stride_2_pointer
    sw $zero,4($t1)#stride_1_pointer[1] = (int)NULL;
    lw $s5,4($sp)#����ͷ�ڵ�head��Ϊ�ӹ���head����l_head
    jal msort
    move $s6,$t6#t6����msort���ؽڵ�
    sw $s6,12($sp)#���l_head
    
    lw $s5,8($sp)#���ؿ�ָ��stride_2_pointer��Ϊ�ӹ���head����r_head
    jal msort
    move $s7,$t6
    sw $s7,16($sp)#���r_head
    lw $s6,12($sp)
    lw $s7,16($sp)
    jal merge#merge(l_head,r_head)
    move $t6,$t7#t7�洢merge���ؽ��,����t6��Ϊmsort����ֵ
    lw $ra, 0($sp)#������һ�����õ�ַ
    addi $sp, $sp, 20#�ͷ�ջ
    jr $ra
    
msort_loop:
    lw $t3,4($t2)#����stride_2_pointer[1]��ֵ;
    beq $t3,$zero,msort_loop_exit
    move $t2,$t3#stride_2_pointer = (int *)stride_2_pointer[1];
    lw $t3,4($t2)
    beq $t3,$zero,msort_loop_exit
    move $t2,$t3#stride_2_pointer = (int *)stride_2_pointer[1];
    lw $t4,4($t1)#����stride_1_pointer[1]��ֵ;
    move $t1,$t4#stride_1_pointer = (int *)stride_1_pointer[1];
    j msort_loop
msort_loop_exit:
    jr $ra
msort_exit:
    move $t6,$s5#head  s5����t6��Ϊmsort����ֵ
    addi $sp, $sp, 20#�ͷ�ջ
    jr $ra
merge:
    subi $sp, $sp, 4 #����1�ִ�Сջ�ռ��ra�����ݹ���һ�����ص�ַ
    sw $ra, 0($sp)#����1�ִ�Сջ�ռ��ra�����ݹ���һ�����ص�ַ
    # ��������ͷ��㣬���ںϲ���������
    li $a0, 8             # ���� 8 ���ֽڣ�2��int�Ĵ�С��
    li $v0, 9             # ����ϵͳ���� 9 �������ڴ�
    syscall               # ִ��ϵͳ����
    move $t0, $v0         # ������ĵ�ַ�洢��$t0�У�����ͷ����ַ��
    
    # ��������ͷָ��洢������ͷ���ĵ�һ��λ��
    sw $s6, 4($t0)#head[1] = (int)l_head;

    # ��ʼ��p_leftΪ����ͷ����ַ
    move $t1, $t0#int *p_left = head;

    move $t2, $s7#int *p_right = r_head;

merge_outer_loop:
    move $t3,$t1 #�β�1��t1Ϊp_left
    move $t4,$t2#�β�2,t2Ϊp_right
    jal merge_inner_loop
    move $t1,$t3
    move $t2,$t4
    lw $t8,4($t1)#t8=p_left[1]
    beq $t8,$zero,merge_outer_loop_exit1
    move $t7,$t2#t7Ϊp_right_temp = p_right;
    move $t3,$t7 #�β�1
    move $t4,$t1#�β�2
    jal merge_inner_loop1
    move $t7,$t3
    move $t1,$t4
    lw $t8,4($t7)#t8����*temp_right_pointer_next ��Ҳ����(int *)p_right_temp[1];
    lw $t9,4($t1)#t9����p_left[1]
    sw $t9,4($t7)#p_right_temp[1] = p_left[1];
    sw $t2,4($t1)#p_left[1] = (int)p_right;
    move $t1,$t7# p_left = p_right_temp;
    move $t2,$t8#p_right = temp_right_pointer_next;
    beq $t2,$zero,merge_outer_loop_exit
    j merge_outer_loop
    
merge_outer_loop_exit1:
    sw $t2,4($t1)
    lw $t7,4($t0)#t7���� rv = head[1];
    lw $ra, 0($sp)
    addi $sp, $sp, 4#�ͷ�ջ�ռ䣬��ת��msort
    jr $ra
 
merge_outer_loop_exit:
    lw $t7,4($t0)#t7���� rv = head[1];
    lw $ra, 0($sp)
    addi $sp, $sp, 4#�ͷ�ջ�ռ䣬��ת��msort
    jr $ra
    

merge_inner_loop:
    lw $t8,4($t3)#t8����p_left[1]
    beq $t8,$zero,merge_inner_loop_exit
    lw $t8,0($t8)#t8����((int *)p_left[1])[0]
    lw $t9,0($t4)#t9����p_right[0]
    addi $s2,$s2,1
    bgt $t8,$t9,merge_inner_loop_exit
    lw $t8,4($t3)#t8����p_left[1]
    move $t3,$t8
    j merge_inner_loop
merge_inner_loop_exit:
    jr $ra
#ͬ�ϣ��ṹ������ͬ
merge_inner_loop1:
    lw $t8,4($t3)
    beq $t8,$zero,merge_inner_loop_exit1
    lw $t8,0($t8)
    lw $t9,4($t4)
    lw $t9,0($t9)
    addi $s2,$s2,1
    bgt $t8,$t9,merge_inner_loop_exit1
    lw $t8,4($t3)
    move $t3,$t8
    j merge_inner_loop1
merge_inner_loop_exit1:
    jr $ra








