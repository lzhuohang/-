.data
buffer: .space 4004   # 1001 个 4 字节整数的缓冲区，用于存储输入数据和输出结果
infile: .asciiz "a.in"
outfile: .asciiz "a.out"

.text
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
    la $a0, buffer# buffer数组首地址载入到 $a0中
    addi $a0,$a0,4 # 传递数组首地址（从buffer[1]开始）
    move $s0, $a0        # 数组地址
    move $s2, $zero     # 初始化比较次数为 0
    jal binary_insertion_sort   # 调用插入排序函数
    move $t1, $s2        # 将比较次数存储在 $t1 中
    sw $t1, buffer       # 存储比较次数到 buffer[0]
    la $a0, outfile#打开out文件
    li $a1, 1#flag设置为1，写入
    li $a2, 0
    li $v0, 13#打开out文件
    syscall
    move $a0, $v0
    la $a1, buffer
    move $a2,$s1 
    addi $a2,$a2,1
    sll $a2,$a2,2          # 写入 （N+1）个 4 字节整数
    li $v0, 15#写入out文件
    syscall
    li $v0 16#关闭out文件
    syscall
    li $v0, 10           # syscall 10: 退出程序
    syscall

# 插入排序函数
binary_insertion_sort:
    subi $sp, $sp, 4 #申请1字大小栈空间存ra，即递归上一级返回地址
    sw $ra, 0($sp)#申请1字大小栈空间存ra，即递归上一级返回地址
    move $t0, $zero  
    addi $t0,$t0,1          #设定循环变量i=1
binary_insertion_sort_loop:
    bge $t0, $s1, binary_insertion_exit  # 如果已经处理完所有元素，跳出循环
    move $s5,$zero #s5储存left，此处为0
    subi $s6,$t0,1 #s6储存right，此处为i-1
    jal binary_search
    move $t2, $s3#将找到的位置储存在t2中
    jal insert
    addi $t0,$t0,1#i++
    j binary_insertion_sort_loop
binary_insertion_exit:
    lw $ra, 0($sp)#加载跳转到主函数的地址
    addi $sp, $sp, 4#清除该级栈
    jr $ra#返回主函数
binary_search:
    bgt $s5,$s6,binary_search_end
    add $s7,$s5,$s6
    sra $s7,$s7,1#s7储存mid
    addi $s2,$s2,1#比较次数加一
    move $t4,$t0  #将形参n储存在t4中
    sll $s4,$t4,2  #确定v[n+1]数组偏移量
    add $s4,$s4,$s0#确定v[n+1]的地址
    lw $s4,0($s4)#确定v[n+1]的值
    sll $t7,$s7,2
    add $t7,$t7,$s0#确定v[mid+1]地址
    lw $t7,0($t7)#确定v[mid+1]值
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
    move $s3,$s5#返回i+1，存储在s3
    jr $ra#返回insertion_sort_loop
insert:
    sub $t4,$t0,1             #i=n-1
    sll $s4,$t4,2  #确定数组偏移量
    add $s4,$s4,4
    add $s4,$s4,$s0
    lw $s4,0($s4)#确定temp（v[n+1]的地址）
insert_loop:
    blt $t4,$t2,insert_exit#i＜k时结束循环
    move $t5,$t4
    sll $t5,$t5,2
    add $t5,$t5,$s0#确定v[i+1]的地址
    lw $t5,0($t5)#确定v[i+1]的值
    addi $t6,$t4,1
    sll $t6,$t6,2
    add $t6,$t6,$s0#确定v[i+2]的地址
    sw $t5,0($t6)#将v[i+1]值赋给v[i+2]
    subi $t4,$t4,1#i--
    j insert_loop
insert_exit:
    move $t5,$t2
    sll $t5,$t5,2
    add $t5,$t5,$s0#确定v[k+1]的地址
    sw $s4,0($t5)#将temp值赋给v[k+1]
    jr $ra#返回insertion_sort_loop
    
    
    