#!/bin/bash
#shell 脚本调试技术

一、脚本中输出调试信息
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

#我们也许并不需要tee命令的帮助，比如我们可以分段执行由管道连接起来的各条命令并查看各命令的输出结果来诊断错误，但在一些复杂的shell脚本中，这些由管道连接起来的命令可能又依赖于脚本中定义的一些其它变量，这时我们想要在提示符下来分段运行各条命令就会非常麻烦了，简单地在管道之间插入一条tee命令来查看中间结果会更方便一些。
#!/bin/bash

ipaddr=`ifconfig | grep "inet " | grep -v '127.0.0.1' | tee temp.txt| cut -d : -f3 | awk '{print$1}'`
echo $ipaddr

3、使用调试钩子

二、使用shell的执行选项

-n 只读取shell脚本，但不实际执行 --------------->检查语法
-x 进入跟踪方式，显示所执行的每一条命令 -------->调试首选,set -x 打开;set +x关闭;
-c "string" 从strings中读取命令 ---------------->临时测试小段脚本

三、对“-x”选项的增强
$LINENO
代表shell脚本的当前行号，类似于C语言中的内置宏__LINE__ 

$FUNCNAME
函数的名字，类似于C语言中的内置宏__func__,但宏__func__只能代表当前所在的函数名，而$FUNCNAME的功能更强大，它是一个数组变量，其中包含了整个调用链上所有的函数的名字，故变量${FUNCNAME[0]}代表shell脚本当前正在执行的函数的名字，而变量${FUNCNAME[1]}则代表调用函数${FUNCNAME[0]}的函数的名字，余者可以依此类推。 

$PS4
主提示符变量$PS1和第二级提示符变量$PS2比较常见，但很少有人注意到第四级提示符变量$PS4的作用。我们知道使用“-x”执行选项将会显示shell脚本中每一条实际执行过的命令，而$PS4的值将被显示在“-x”选项输出的每一条命令的前面。在Bash Shell中，缺省的$PS4的值是"+"号。(现在知道为什么使用"-x"选项时，输出的命令前面有一个"+"号了吧？)。

shell中还有其它一些对调试有帮助的内置变量，比如在Bash Shell中还有BASH_SOURCE, BASH_SUBSHELL等一批对调试有帮助的内置变量，您可以通过man sh或man bash来查看，然后根据您的调试目的,使用这些内置变量来定制$PS4，从而达到增强“-x”选项的输出信息的目的。

实例：
#以下是一个存在bug的shell脚本的示例，本文将用此脚本来示范如何用“-n”以及增强的“-x”执行选项来调试shell脚本。这个脚本中定义了一个函数isRoot(),用于判断当前用户是不是root用户，如果不是，则中止脚本的执行 
$ cat –n exp4.sh
1  #!/bin/bash
2  isRoot()
3  {
4          if [ "$UID" -ne 0 ]
5                  return 1
6          else
7                  return 0
8          fi
9  }
10  isRoot
11  if ["$?" -ne 0 ]
12  then
13          echo "Must be root to run this script"
14          exit 1
15  else
16          echo "welcome root user"
17          #do something
18  fi

 首先执行sh –n exp4.sh来进行语法检查，输出如下：

 $ sh –n exp4.sh
 exp4.sh: line 6: syntax error near unexpected token `else'
 exp4.sh: line 6: `      else'
#把第4行修改为if [ "$UID" -ne 0 ]; then来修正这个错误。再次运行sh –n exp4.sh来进行语法检查，没有再报告错误
$ sh exp4.sh
exp2.sh: line 11: [1: command not found
welcome root user
#错误信息还非常奇怪“[1: command not found”。现在我们可以试试定制$PS4的值，并使用“-x”选项来跟踪：
$ export PS4='+{$LINENO:${FUNCNAME[0]}} '
$ sh –x exp4.sh
+{10:} isRoot
+{4:isRoot} '[' 503 -ne 0 ']'
+{5:isRoot} return 1
+{11:} '[1' -ne 0 ']'
exp4.sh: line 11: [1: command not found
+{16:} echo 'welcome root user'
welcome root user
#从输出结果中，我们可以看到脚本实际被执行的语句，该语句的行号以及所属的函数名也被打印出来，从中可以清楚的分析出脚本的执行轨迹以及所调用的函数的内部执行情况。由于执行时是第11行报错，这是一个if语句，我们对比分析一下同为if语句的第4行的跟踪结果：

 +{4:isRoot} '[' 503 -ne 0 ']'
 +{11:} '[1' -ne 0 ']

四、总结
现在让我们来总结一下调试shell脚本的过程：
首先使用“-n”选项检查语法错误，然后使用“-x”选项跟踪脚本的执行，使用“-x”选项之前，别忘了先定制PS4变量的值来增强“-x”选项的输出信息，至少应该令其输出行号信息(先执行export PS4='+[$LINENO]'，更一劳永逸的办法是将这条语句加到您用户主目录的.bash_profile文件中去)，这将使你的调试之旅更轻松。也可以利用trap,调试钩子等手段输出关键调试信息，快速缩小排查错误的范围，并在脚本中使用“set -x”及“set +x”对某些代码块进行重点跟踪。这样多种手段齐下，相信您已经可以比较轻松地抓出您的shell脚本中的臭虫了。如果您的脚本足够复杂，还需要更强的调试能力，可以使用shell调试器bashdb，这是一个类似于GDB的调试工具，可以完成对shell脚本的断点设置，单步执行，变量观察等许多功能，使用bashdb对阅读和理解复杂的shell脚本也会大有裨益。关于bashdb的安装和使用，不属于本文范围，您可参阅http://bashdb.sourceforge.net/上的文档并下载试用。 



