.text
main:
    li $v0, 5#设置输入模式调用
    syscall
    move $a0, $v0#输入参数n，储存在a0
    jal Hanoi#跳转到Hanoi函数，并将下一条指令的地址存储在 $ra 中
    move $a0, $v0#v0传出结果Hanoi计算结果给a0以供打印
    li $v0, 1#系统调用打印
    syscall
    li $v0, 10# 加载系统调用号 10，表示程序退出
    syscall             

Hanoi:
    beq $a0, 1, Hanoi1
    subi $sp, $sp, 4  #申请1字大小栈空间存ra，即递归上一级返回地址
    sw $ra, 0($sp)
    subi $a0, $a0, 1
    jal Hanoi#跳入Hanoi（n-1）
    sll $v0,$v0,1
    addi $v0,$v0,1 #返回结果2*v0+1
    lw $ra, 0($sp)#载入上一级递归地址
    addi $sp, $sp, 4#清除该级栈
    jr $ra#跳转到上一级递归

Hanoi1:
    li $v0, 1
    jr $ra
    
   

