.text
main:
    li $v0, 5#读入第一个整数i
    syscall
    move $t0, $v0#赋给第一个参数
    li $v0, 5#读入第二个整数j
    syscall
    move $t1, $v0#赋给第二个参数
    sub $t0, $zero, $t0#i=0-i=-i（取反）
    blt $t1, $zero, if#分支判断（j<0）
    move $t2, $zero#temp=0
loop:
    bgt $t2, $t1, loop_end
    beq $t2, $t1, loop_end#temp≥j时结束，退出
    addi $t0, $t0, 1#i=i+1
    addi $t2, $t2, 1#++temp
    j loop#继续循环，执行for
if:
    sub $t1, $zero, $t1#j=0-j=-j（取反）
    move $t2, $zero#temp=0
    j loop
loop_end:
    move $a0, $t0#将最后的i赋给a0进行打印
    li $v0, 1#设置为打印模式
    syscall
    move $v0, $t0#运行结果存储给v0


