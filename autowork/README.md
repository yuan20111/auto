### 关于合并请求处理、编译deb包、研发仓库管理的无人职守的实现构想



一， 合并请求的要素构成：

   * 软件工程名称：一般是源码包名称。
   * 分支名称：被合并子分支、合并主分支
   * 相关人员信息：提请人、审查人、处理人
   * 合并请求描述： title、合并描述正文
   * 源码变动：特别是changlog中的版本号提升。

二  工作背景描述

 * 四台机器：源码机、编译机、仓库机、iso构建机。
 * 两个守护程序：编译守护程序、仓库守护程序， 一套人工执行脚本：iso构建脚本。
 * 总体流程：
   1. 源码机执行合并请求检查、源码合并
   2. 源码机发送编译指令给编译机，（scp一个文件实现编译指令传送）
   3. 编译机生成deb包，note文件，向仓库机查询目录名称，然后scp deb包进去。
   4. 仓库机负责目录维护：
      (1). 记录“最后目录名称”， 编译机和iso构建机都能查询；
      (2). “最后目录”如果有了“iso已构建标记”，则创建新的目录，并更新“最后目录名称”。我们需要深入理解仓库结构规则和产品线需求，才能编写好程序背后的“规则”。
   5. 人工执行iso构建脚本， iso构建脚本自动设置仓库的“iso已构建标记”。
   

三，源码机模块： 合法的合并请求的生成

1. 合并请求审查：在合并请求的提交阶段完成，如果不满足，则无法提交合并请求。<br\>
   我认为，主要审查：描述信息、版本号。 

     可以强制规定title的格式为：bugxxxxx或者notbug。
     
     对版本号的检查，可以简化处理：只要changlog文件有变动即可。
     
     合并请求描述正文包含： 问题描述、解决方法描述、审核人姓名、审核描述。（请大家讨论）。

2. Gitlab增加“试编译” 功能： 研发人员在gitlab上操作，后台实现：在编译机上编译分支，并返回编译结果。这个可以作为合并请求的提交条件之一。

3. 对合并请求的手动处理和自动处理<br\>
设置总开关、子开关，用于设定自动/手动模式的切换。 同时还有一个目的，对代码的要求：增加代码，不修改原有的代码和流程。
4. 从源码机到编译机的指令文件： scp 一个文件

5. 日志记录

四,编译机守护程序

1. 读取源码机发来的指令文件
2. 从仓库机读取“最后目录名称”
3. 编包，放进“最后目录”。
4. 编制note文件，放进“最后目录”。
5. 日志记录。 
6. 如果工作失败，邮件通知合并请求提交人和审核人。（概率较小，可以不做）。

五，仓库机守护程序  

 1. “最后目录”剖析，
 字符串类型的变量。
 赋值逻辑： 根据合并主分支(下面的->之前的部分)确定赋值（下面的->之后的部分) 

    master -> new_deb_xx/Debs_to_repo_1.5-dev-xx
    
    HGJ -> HGJ 
    
    Lenovo-Notebook-> notebook/xx 
    
    GE -> GE 
   
 2. 源码机和构建机读取“最后目录”。  仓库机负责“最后目录”重新赋值以后的更新。
 
 3. 构建机构建一个iso以后，设置“iso已构建标记”，启动“最后目录”的重新赋值。

 4. 日志记录  

 5. 接收构建机的仓库扫描请求，执行dpkg-scanpackages
 
六，日志系统设计

创建一个git工程，四台机器的工作日志全部汇总到这里。



左洪盛， 2016-4-26.