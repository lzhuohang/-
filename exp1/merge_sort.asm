.data
buffer: .space 4004   # 1001 个 4 字节整数的缓冲区，用于存储输入数据和输出结果
compare: .space 4       # 存放比较次数
infile: .asciiz "a.in"
outfile: .asciiz "a.out"

.text
# main 函数
main:
    la $a0, infile #打开输入文件
    li $a1, 0 #flag 0为读取 1为写入
    li $a2, 0 #mode is ignored 设置为0就可以了
    li $v0, 13 #13 为打开文件的 syscall 编号
    syscall 
    move $a0,$v0 
    la $a1, buffer #in_buff 为数据暂存区
    li $a2, 4004 #读取4004个byte
    li $v0, 14 #14 为读取文件的 syscall 编号
    syscall
    li $v0 16 #16 为关闭文件的 syscall 编号
    move $a0, $v0        # 文件描述符存储在 $a0 中
    syscall
    lw $t0, buffer       # 将buffer[0]（N）加载到 $t0 中
    move $s1, $t0        # 将 N 存储在 $s1 中
    move $s2,$zero       #比较次数设为0
    li $a0, 8        # 要申请的内存大小为8（2word）
    li $v0, 9          # 设置系统调用号为 9
    syscall            
    move $s0, $v0   #v0返回值赋给s0储存head首地址
    sw $zero, 4($s0)  # head[1] = (int)NULL;
    move $s4,$s0 #s4储存head
    move $s3,$s0  #s3储存pointer
    la $a0, buffer# buffer数组首地址载入到 $a0中
    addi $s0,$a0,4#s0储存buffer[1]首地址
    li $t0, 1   # 循环变量 idx 初始值为 1
#创建链表
loop:
    bgt $t0, $s1, loop_exit  # 如果计数器大于 N，则结束循环
    # 分配新节点内存
    li $a0, 8   # 每个节点大小为 8 字节（两个 int 大小）
    li $v0, 9   # syscall 9: 分配内存
    syscall
    move $t1, $v0   # 将分配的节点地址存储到 $t1 中
    # 将节点地址存储到当前节点的下一个指针位置
    sw $t1, 4($s3)  # pointer[1] = (int)new int[2];
    # 更新指针以指向新分配的节点
    move $s3, $t1   # 更新指针以指向新分配的节点
    sll $t3,$t0,2
    subi $t3,$t3,4
    add $t3,$t3,$s0#确定buffer[idx]地址
    # 将数据存储到新节点的数据成员中
    lw $t3, 0($t3)  # 确定buffer[idx]值
    sw $t3, 0($s3)       # 将数据存储到新节点的数据成员中
    # 将新节点的下一个指针设置为 NULL
    sw $zero, 4($s3)  # 将 NULL 存储到新节点的下一个指针位置
    addi $t0, $t0, 1   #idx++
    j loop
loop_exit:
    lw $s5,4($s4)#s5作为形参的head
    jal msort
    sw $t6,4($s4)#t6储存head[1] = (int)msort((int *)head[1]);
    move $s3,$s4#s3为pointer，s4为head;pointer=head
    sw $s2,compare#比较次数存入compare
    la $a0, outfile#打开out文件
    li $a1, 1#flag设置为1，写入
    li $a2, 0
    li $v0, 13#打开out文件
    syscall
    move $a0, $v0
    la $a1, compare
    li $a2,4
    li $v0, 15#将比较次数写入out文件
    syscall
main_end:
    lw $t9,4($s3)#确定pointer[1]的值
    move $s3,$t9#pointer = (int *)pointer[1]
    beq $s3,$zero,main_end_exit
    move $a0, $v0
    move $a1, $s3
    li $a2,4 
    li $v0, 15#将链表结果（比较后的值）写入out文件
    syscall
    j main_end
main_end_exit:
    li $v0 16#关闭out文件
    syscall
    li $v0, 10           # syscall 10: 退出程序
    syscall
    
msort:
    subi $sp, $sp, 20 #申请5字大小栈空间存ra，即递归上一级返回地址、头结点地址，快指针stride_2_pointer地址，l_head(s6),r_head(s7)地址，防止递归中被覆盖
    sw $ra, 0($sp)#申请1字大小栈空间存ra，即递归上一级返回地址
    sw $s5,4($sp)#存放头节点head
    lw $t0,4($s5)#t0存放head[1]
    beq $t0,$zero,msort_exit#head[1]==NULL退出返回head
    move $t2,$s5#stride_2_pointer储存在t2内
    move $t1,$s5#stride_1_pointer储存在t1内
    jal msort_loop
    lw $t4,4($t1)#加载stride_1_pointer[1]的值;
    move $t2,$t4#stride_2_pointer = (int *)stride_1_pointer[1];
    sw $t2,8($sp)#存放快指针stride_2_pointer
    sw $zero,4($t1)#stride_1_pointer[1] = (int)NULL;
    lw $s5,4($sp)#加载头节点head作为子过程head生成l_head
    jal msort
    move $s6,$t6#t6储存msort返回节点
    sw $s6,12($sp)#存放l_head
    
    lw $s5,8($sp)#加载快指针stride_2_pointer作为子过程head生成r_head
    jal msort
    move $s7,$t6
    sw $s7,16($sp)#存放r_head
    lw $s6,12($sp)
    lw $s7,16($sp)
    jal merge#merge(l_head,r_head)
    move $t6,$t7#t7存储merge返回结果,赋给t6作为msort返回值
    lw $ra, 0($sp)#加载上一级调用地址
    addi $sp, $sp, 20#释放栈
    jr $ra
    
msort_loop:
    lw $t3,4($t2)#加载stride_2_pointer[1]的值;
    beq $t3,$zero,msort_loop_exit
    move $t2,$t3#stride_2_pointer = (int *)stride_2_pointer[1];
    lw $t3,4($t2)
    beq $t3,$zero,msort_loop_exit
    move $t2,$t3#stride_2_pointer = (int *)stride_2_pointer[1];
    lw $t4,4($t1)#加载stride_1_pointer[1]的值;
    move $t1,$t4#stride_1_pointer = (int *)stride_1_pointer[1];
    j msort_loop
msort_loop_exit:
    jr $ra
msort_exit:
    move $t6,$s5#head  s5赋给t6作为msort返回值
    addi $sp, $sp, 20#释放栈
    jr $ra
merge:
    subi $sp, $sp, 4 #申请1字大小栈空间存ra，即递归上一级返回地址
    sw $ra, 0($sp)#申请1字大小栈空间存ra，即递归上一级返回地址
    # 创建虚拟头结点，用于合并两个链表
    li $a0, 8             # 分配 8 个字节（2个int的大小）
    li $v0, 9             # 调用系统调用 9 来分配内存
    syscall               # 执行系统调用
    move $t0, $v0         # 将分配的地址存储到$t0中（虚拟头结点地址）
    
    # 将左链表头指针存储到虚拟头结点的第一个位置
    sw $s6, 4($t0)#head[1] = (int)l_head;

    # 初始化p_left为虚拟头结点地址
    move $t1, $t0#int *p_left = head;

    move $t2, $s7#int *p_right = r_head;

merge_outer_loop:
    move $t3,$t1 #形参1，t1为p_left
    move $t4,$t2#形参2,t2为p_right
    jal merge_inner_loop
    move $t1,$t3
    move $t2,$t4
    lw $t8,4($t1)#t8=p_left[1]
    beq $t8,$zero,merge_outer_loop_exit1
    move $t7,$t2#t7为p_right_temp = p_right;
    move $t3,$t7 #形参1
    move $t4,$t1#形参2
    jal merge_inner_loop1
    move $t7,$t3
    move $t1,$t4
    lw $t8,4($t7)#t8储存*temp_right_pointer_next ，也就是(int *)p_right_temp[1];
    lw $t9,4($t1)#t9储存p_left[1]
    sw $t9,4($t7)#p_right_temp[1] = p_left[1];
    sw $t2,4($t1)#p_left[1] = (int)p_right;
    move $t1,$t7# p_left = p_right_temp;
    move $t2,$t8#p_right = temp_right_pointer_next;
    beq $t2,$zero,merge_outer_loop_exit
    j merge_outer_loop
    
merge_outer_loop_exit1:
    sw $t2,4($t1)
    lw $t7,4($t0)#t7储存 rv = head[1];
    lw $ra, 0($sp)
    addi $sp, $sp, 4#释放栈空间，跳转回msort
    jr $ra
 
merge_outer_loop_exit:
    lw $t7,4($t0)#t7储存 rv = head[1];
    lw $ra, 0($sp)
    addi $sp, $sp, 4#释放栈空间，跳转回msort
    jr $ra
    

merge_inner_loop:
    lw $t8,4($t3)#t8储存p_left[1]
    beq $t8,$zero,merge_inner_loop_exit
    lw $t8,0($t8)#t8储存((int *)p_left[1])[0]
    lw $t9,0($t4)#t9储存p_right[0]
    addi $s2,$s2,1
    bgt $t8,$t9,merge_inner_loop_exit
    lw $t8,4($t3)#t8储存p_left[1]
    move $t3,$t8
    j merge_inner_loop
merge_inner_loop_exit:
    jr $ra
#同上，结构基本相同
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








