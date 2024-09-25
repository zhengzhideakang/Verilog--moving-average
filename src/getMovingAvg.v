/*
 * @Author       : Xu xiaokang
 * @Email        :
 * @Date         : 2021-04-14 16:14:46
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-25 16:45:58
 * @Filename     : getMovingAvg.v
 * @Description  : 求N个有符号数的滑动平均值
*/

/*
! 模块功能: 求N个有符号数的滑动平均值
* 思路:
  1.求N(N等于2**FIFO_ADDR_WIDTH)个数的和，再除以N即为N个数的平均值, 除以N等价于左移FIFO_ADDR_WIDTH位
  2.实例化一个深度为N的同步FIFO, 用于暂存这N个数
  3.当第N+1个数到来后, 总和减去第1个数再加上第N+1个数, 再求平均值即为1~N+1个数的平均值, 以此类推
  4.对应的FIFO操作是: FIFO满后, 又来一个数, 先读取FIFO一次, 腾出一个位置, 再往FIFO中写入新的数
  5.如果din_valid是连续有效的, 那么这里存在一个问题: FIFO满后, din_valid有效, 需要先读后写, 但对于连续的
    din_valid, 读写是同时的, 读出没有问题, 但写入可能因为FIFO满而失效, 所以更好的办法是不让FIFO满
  6.不让FIFO满的办法是使用一个暂存寄存器, 以almost_full作为指示, almost_full为1时, din_valid有效,
    则进行一次读取和写入, 这时写入和读取都必然成功, FIFO也始终不会满, 而是留有一个位空余
  7.未采用直接设置N的方式, 而保证了N是2的整数幂, 否则取平均值要用到除法, 而非简单的左移
~ 使用:
  1.一般来说N越大, 取的滑动平均值越准确, 特别的, 对于单频率信号, 当N是一个周期点数的整数倍时, 平均值没有误差
  2.对于一个混频信号, N一般要大于最大周期点数的4倍以上, 平均值才能取得比较准确, 可根据实际效果调整
  3.模块数据输入之前需要至少一个时钟周期的复位
*/

`default_nettype none

module getMovingAvg
#(
  parameter FIFO_ADDR_WIDTH = 10, // FIFO地址位宽, 可取1, 2, 3, ... , 默认10, 对应N=1024
  parameter FIFO_RAM_STYLE = "block", // 可选"block"(默认), "distributed"
  parameter DIN_WIDTH = 16 // 输入数据位宽, 可取1, 2, 3, ... , 默认16
)(
  output wire signed [DIN_WIDTH-1 : 0] moving_avg,
  output wire                          moving_avg_valid,

  output wire signed [DIN_WIDTH-1 : 0] ac_signal,
  output wire                          ac_signal_valid,

  input  wire signed [DIN_WIDTH-1 : 0] din,
  input  wire                          din_valid,

  input  wire clk,
  input  wire rstn
);


//< 输入数据暂存 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg signed [DIN_WIDTH-1 : 0] din_r1; // 暂存一个数据
always @(posedge clk) begin
  if (din_valid)
    din_r1 <= din;
end


reg din_r1_flag; // 指示已暂存一个数据
always @(posedge clk) begin
  if (~rstn)
    din_r1_flag <= 1'b0;
  else if (din_valid)
    din_r1_flag <= 1'b1;
  else
    din_r1_flag <= din_r1_flag;
end
//< 输入数据暂存 ------------------------------------------------------------


//> FWFT FIFO存储N个数 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire wr_en = din_r1_flag && din_valid;
wire almost_full;
wire [DIN_WIDTH-1 : 0] dout;
wire rd_en = almost_full && din_valid;

syncFIFO #(
  .DATA_WIDTH (DIN_WIDTH),
  .ADDR_WIDTH (FIFO_ADDR_WIDTH),
  .RAM_STYLE  (FIFO_RAM_STYLE),
  .FWFT_EN    (1)
) syncFIFO_u0 (
  .din          (din_r1     ),
  .wr_en        (wr_en      ),
  .full         (           ),
  .almost_full  (almost_full),
  .dout         (dout       ),
  .rd_en        (rd_en      ),
  .empty        (           ),
  .almost_empty (           ),
  .clk          (clk        ),
  .rst          (~rstn      )
);
//> FWFT FIFO存储N个数 ------------------------------------------------------------


//< 求和、平均值、交流信号 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg signed [FIFO_ADDR_WIDTH + DIN_WIDTH - 1 : 0] sum;
always @(posedge clk) begin
  if (~rstn)
    sum <= 'd0;
  else if (din_valid)
    if (almost_full)
      sum <= sum - dout + din;
    else
      sum <= sum + din;
  else
    sum <= sum;
end


assign moving_avg = sum[FIFO_ADDR_WIDTH + DIN_WIDTH - 1 : FIFO_ADDR_WIDTH]; // 取高数据位
assign moving_avg_valid = rd_en;


assign ac_signal = din - moving_avg;
assign ac_signal_valid = moving_avg_valid;
//< 求和、平均值、交流信号 ------------------------------------------------------------


endmodule
`resetall