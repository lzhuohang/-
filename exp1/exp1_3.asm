.text
main:
    li $v0, 5#读入整数n
    syscall
    move $a0, $v0#申请内存大小为n
    move $s1, $v0#s1储存n的值
    sll $a0, $a0, 2#开辟a0*4个byte大小空间 
    li $v0, 9#new一个数组
    syscall
    move $s0, $v0#v0返回值赋给s0储存a首地址
    move $t0, $zero#设置循环变量i为t0，初值为0
loop_1:
    li $v0, 5#读入一个整数
    syscall
    sll $t1, $t0, 2#设置数组的偏移量
    addu $t1, $t1, $s0#设置t1为a[i]实际地址
    sw $v0, 0($t1)#储存a[i]值
    addi $t0, $t0, 1#i++
    blt $t0, $s1, loop_1#i＜n时继续循环
    move $t0, $zero#设置循环变量i初值为0
    sra $s2, $s1, 1#右移一位，设置s2为n/2
loop_2:
    sll $t1, $t0, 2#设置数组的偏移量
    addu $t1, $t1, $s0#设置t1为a[i]实际地址
    lw $t2, 0($t1)#设置t2为a[i]的值
    addi $t3, $t2, 1#t3为t，t=a[i]+1
    sub $t4, $s1, $t0
    subi $t4, $t4, 1#设定t4为n-i-1
    sll $t4, $t4, 2#设定好数组偏移量
    addu $t4, $t4, $s0#设置t4为a[n-i-1]实际地址
    lw $t5, 0($t4)#设置t5为a[n-i-1]的值
    addi $t5, $t5, 1#t5=a[n-i-1]+1
    sw $t5, 0($t1)#将t5值（a[n-i-1]+1）赋给a[i]
    sw $t3, 0($t4)#将t3（t）值赋给a[n-i-1]
    addi $t0, $t0, 1#i++
    blt $t0, $s2, loop_2#i＜n/2时继续循环
    move $t0, $zero#设置循环变量i初值为0
loop_3:
    li $v0, 1#打印整数
    sll $t1, $t0, 2#设置数组偏移量
    addu $t1, $t1, $s0#设置t1为a[i]实际地址
    lw $a0, 0($t1)#将要打印的值加载到a0
    syscall
    addi $t0, $t0, 1#i++
    blt $t0, $s1, loop_3#i＜n/2时继续循环
    j end_loop
end_loop:
    li $v0, 10          # 加载系统调用号 10，表示程序退出
    syscall             # 执行系统调用
