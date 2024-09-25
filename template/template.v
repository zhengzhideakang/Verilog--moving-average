/*
 * @Author       : Xu Xiaokang
 * @Email        : xuxiaokang_up@qq.com
 * @Date         : 2024-09-14 11:40:11
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-25 14:14:34
 * @Filename     :
 * @Description  :
*/

/*
! 模块功能: getMovingAvg实例化参考
*/


getMovingAvg #(
  .FIFO_ADDR_WIDTH (10      ), // FIFO地址位宽, 可取1, 2, 3, ... , 默认10, 对应N=1024
  .FIFO_RAM_STYLE  ("block" ), // 可选"block"(默认), "distributed"
  .DIN_WIDTH       (16      )  // 输入数据的位宽, 可取1, 2, 3, ... , 默认16
) getMovingAvg_u0 (
  .moving_avg       (moving_avg      ),
  .moving_avg_valid (moving_avg_valid),
  .ac_signal        (ac_signal       ),
  .ac_signal_valid  (ac_signal_valid ),
  .din              (din             ),
  .din_valid        (din_valid       ),
  .clk              (clk             ),
  .rstn             (rstn            )
);