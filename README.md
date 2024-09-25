# Verilog功能模块-滑动平均值

Gitee与Github同步：

[Verilog功能模块--滑动平均值: Verilog功能模块-滑动平均值（使用FIFO） (gitee.com)](https://gitee.com/xuxiaokang/verilog-function-module--moving-average)

[zhengzhideakang/Verilog--moving-average: Verilog功能模块——滑动平均值（使用FIFO） (github.com)](https://github.com/zhengzhideakang/Verilog--moving-average)

## 简介

因为使用了自编的FIFO IP，不在需要额外的FIFO IP了，原本使用寄存器实现的方式可以舍弃了，取滑动平均值的模块就只需要这一个就行了。

模块功能：对输入信号取滑动平均值。

`滑动平均值`：又名移动平均值，在简单平均值的基础上，通过顺序逐期增加新数据、减去旧数据求算移动平均值，借以消除偶然变动因素。

参考百度百科：[滑动平均法](https://baike.baidu.com/item/%E6%BB%91%E5%8A%A8%E5%B9%B3%E5%9D%87%E6%B3%95/22657430?fr=aladdin)

应用场景：

- 对平均值会变化，但变化速度较慢的信号求平均值
- 数字滤波中去除信号的直流偏置

## 模块框图

<img src="https://picgo-dakang.oss-cn-hangzhou.aliyuncs.com/img/getMovingAvg.svg" alt="getMovingAvg" />

## 更多参考

[Verilog功能模块——取滑动平均值 – 徐晓康的博客 (myhardware.top)](https://www.myhardware.top/verilog功能模块-取滑动平均值/)
