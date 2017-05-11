#!/bin/bash
#shell 脚本调试技术

1、使用trap命令
#trap 'command' signal; trap命令用于捕获指定的信号并执行预定义的命令。
#kill -l 查看信号类型
#
#EXIT  从一个函数中退出或整个脚本执行完毕
#ERR   当一条命令返回非零状态时(代表命令执行不成功)
#DEBUG 脚本中每一条命令执行之前

#通过捕获ERR信号,我们可以方便的追踪执行不成功的命令或函数，并输出相关的调试信息
#$LINENO 是shell内置变量当前行号
$ cat -n exp1.sh
1  ERRTRAP()
2  {
3    echo "[LINE:$1] Error: Command or function exited with status $?"
4  }
5  foo()
6  {
7    return 1;
8  }
9  trap 'ERRTRAP $LINENO' ERR
10  abc
11  foo

#其输出结果如下：

$ sh exp1.sh
1 exp1.sh: line 10: abc: command not found
2 [LINE:10] Error: Command or function exited with status 127
3 [LINE:11] Error: Command or function exited with status 1

#通过捕获DEBUG信号来跟踪变量的示例程序
$ cat –n exp2.sh
1  #!/bin/bash
2  trap 'echo “before execute line:$LINENO, a=$a,b=$b,c=$c”' DEBUG
3  a=1
4  if [ "$a" -eq 1 ]
5  then
6     b=2
7  else
8     b=1
9  fi
10  c=3
11  echo "end"

#其输出结果如下：

$ sh exp2.sh
1 before execute line:3, a=,b=,c=
2 before execute line:4, a=1,b=,c=
3 before execute line:6, a=1,b=,c=
4 before execute line:10, a=1,b=2,c=
5 before execute line:11, a=1,b=2,c=3
6 end

2、使用tee命令


