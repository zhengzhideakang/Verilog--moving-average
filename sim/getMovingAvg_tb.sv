/*
 * @Author       : Xu Xiaokang
 * @Email        :
 * @Date         : 2021-04-21 14:29:04
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-25 16:14:12
 * @Filename     : getMovingAvg_tb.sv
 * @Description  : testbench of getMovingAvg
*/

module getMovingAvg_tb;

timeunit 1ns;
timeprecision 1ps;


//++ 实例化模块 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
parameter FIFO_ADDR_WIDTH = 11; // FIFO地址位宽, 可取1, 2, 3, ... , 默认10, 对应N=1024
parameter FIFO_RAM_STYLE = "block"; // 可选"block"(默认), "distributed"
parameter DIN_WIDTH = 24; // 输入数据的位宽, 可取1, 2, 3, ... , 默认16

logic signed [DIN_WIDTH-1 : 0] moving_avg;
logic                          moving_avg_valid;

logic signed [DIN_WIDTH-1 : 0] ac_signal;
logic                          ac_signal_valid;

logic signed [DIN_WIDTH-1 : 0] din;
logic                          din_valid;

logic clk;
logic rstn;

getMovingAvg #(
  .FIFO_ADDR_WIDTH (FIFO_ADDR_WIDTH),
  .FIFO_RAM_STYLE  (FIFO_RAM_STYLE),
  .DIN_WIDTH       (DIN_WIDTH)
) getMovingAvg_u0 (.*);
//-- 实例化模块 ------------------------------------------------------------


// 生成时钟
localparam CLKT = 2;
initial begin
  clk = 0;
  forever #(CLKT / 2) clk = ~clk;
end


// 导入输入波形文件 Vivado只能识别绝对路径 注意修改！！！
string din_path =
"C:\\Users\\xu\\OneDrive\\VivadoPrj\\getMovingAvg_useFIFO\\getMovingAvg_useFIFO.srcs\\sim_1\\new\\sin-0.5.txt";
// 可选 sin  sin+0.5  sin-0.5  sin+1.0  sin-1.0

localparam DATA_NUM = 10240; // 数据量, 也就是txt文件的行数, 如果此参数大于数据行数, 读取到的内容为不定态
logic [DIN_WIDTH-1 : 0] din_wave_data [DATA_NUM]; // 读取输入波形数据

initial begin
  $readmemb(din_path, din_wave_data, 0, DATA_NUM-1); // vivado读取txt文件
end


initial begin
  rstn = 0;
  din_valid = 0;
  #(CLKT * 10) rstn = 1;

  for (int i = 0; i < DATA_NUM; i++) begin
    din = din_wave_data[i];
    din_valid = 1;
    #(CLKT);
    din_valid = 0;
    #(CLKT * ({$random} % 12));
  end
  din_valid = 0;

  #(CLKT * 10) $stop;
end


endmodule