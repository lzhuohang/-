.data
    buffer: .space 8 #int数组长度为2，需要2*4=8个字节
    infile: .asciiz "a.in"
    outfile: .asciiz "a.out"

.text
main:
    la $a0, infile
    li $a1, 0#flag设置为0，读取文件
    li $a2, 0
    li $v0, 13  #打开in文件
    syscall
    move $a0, $v0
    la $a1, buffer
    li $a2, 8#读取8个byte
    li $v0, 14#读取in文件
    syscall
    li $v0 16#关闭in文件
    syscall
    la $a0, outfile
    li $a1, 1#flag设置为1，写入
    li $a2, 0
    li $v0, 13#打开out文件
    syscall
    move $a0, $v0
    la $a1, buffer
    li $a2, 8#读取8个byte
    li $v0, 15#写入out文件
    syscall
    li $v0 16#关闭out文件
    syscall
    li $v0, 5#读入一个整数
    syscall
    move $t0, $v0
    addi $t0, $t0, 10#i = i + 10
    move $a0, $t0
    li $v0, 1#打印一个整数
    syscall
