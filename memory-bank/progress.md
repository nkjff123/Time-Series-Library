# 实施进展记录

## Phase 1: 环境与基线确认 (已完成)
- **Step 1 & Step 3**：新建了名为 `tslib` 的 Python 环境环境，全量对齐了 `requirements.txt` 中的版本（特别是 `numpy 2.1.2`, `pandas 2.3.3`, 各大模型框架等）。在本地成功跑通 `iTransformer_ETTh1.sh` 脚本的 Epoch 1，通过了基准调测，证明基础软硬件环境准备就绪。
- **Step 2**：确认了自定义风电数据集 `dataset/mydata.csv` 已经就位，并且时间列已经正确更名为 `date`，符合预期的数据格式。我们决定将该数据放入标准长程预测任务管道使用。

## Phase 2: 模块理解与选择 (已完成)
- **Step 4**：审查 `models/iTransformer.py`，确认 `Model` 类的初始化结构能够按规范接收 `configs` 对象。明确了项目在 `exp/exp_basic.py` 中基于 `_scan_models_directory()` 动态扫描加载模型（`LazyModelDict`）的免注册机制。
- **Step 5**：确认 `data_provider/data_factory.py` 的 `data_dict` 中存在针对自定义数据集的工厂路由键值 `'custom': Dataset_Custom`。
- **Step 6**：明确 `data_provider/data_loader.py` 中 `Dataset_Custom` 的时间列固定为 `date` 字段，且使用 `StandardScaler` 作为默认缩放器。此逻辑与 `dataset/mydata.csv` 文件列名完全对应，无需额外修改底层加载源码。

## Phase 3: 模型结构设计 (已完成)
- **Step 7**：确认了 TSLib 原生的长程预测模式合适，将沿用 `run.py` 的 `long_term_forecast` 管道进行当前任务设定。
- **Step 8**：解析了 `mydata.csv`，记录了 1个时间列和 5个数值特征列（平均发电机转速实时值、平均发电机定子绕组u温度、最大风速实时值、平均变桨角度、平均发电机功率实时值）。设定在多变量预测单变量（MS）模式下，`enc_in=5`, `dec_in=5`, `c_out=1`。
- **Step 9**：参考架构设计文档，最终确定并记录下自定义模型滑动窗口：`seq_len=10`（输入过去10分钟），`label_len=5`（解码端参考长度），`pred_len=1`（预测未来1分钟功率）。

## Phase 4: 代码连接与修改 (已完成)
- **Step 10**：在 `scripts/long_term_forecast/` 目录下成功创建了专用执行脚本 `iTransformer_custom.sh`。这是基于通用长程预测管道进行的任务派生。
- **Step 11 & Step 12**：配置了超参数对齐策略：设置 `--data_path mydata.csv`、`--target "平均发电机功率实时值"` 和 `--features MS` 进行多变量对单变量的预测；固定了通道配置 `--enc_in 5`, `--dec_in 5`, `--c_out 1`；考虑到目前短序列任务，使用了极浅的模型深度配置 `--e_layers 2`, `--d_layers 1` 防止在极短序列上过拟合。
- **脚本配置洞察**：在执行中发现显存限制，在脚本中通过加入 `--batch_size 16` 覆盖了 `run.py` 默认的 32。与 M4 比赛等在 `short_term_forecast` 常见使用 `SMAPE`（容易在分母为0时崩溃）的特点不同，明确了风电任务中极端下限的特性，依然采用了 `MSE` 损失以保证极端值域拟合稳定性。

## Phase 5: 实验运行 (已完成)
- **Step 13-15**：脚本 `iTransformer_custom.sh` 成功执行并顺利完成初步训练。模型未出现显存溢出(OOM)或数据形状不对齐的报错。
- **训练表现指标**：在实际验证中，Train Loss 由 Epoch 1 的 ~0.035 平稳下降至 Epoch 5 的 ~0.025。在 Epoch 4 时达到最佳 Vali Loss 测试点 (Vali Loss: 0.038896, Test Loss: 0.038033)，成功触发模型最优权重保存 (Checkpoint)，同时 lr(学习率) 衰减机制正常工作。这说明了 `seq_len=10, pred_len=1` 的极小时间窗口配置完全生效。

## Phase 6: 结果验证 (已完成)
- **Step 16-18**：模型在测试集上验证完成，证明了端到端的管道测试跑通。
- **验证细节**：
  - 最佳测试权重被顺利写入：`./checkpoints/long_term_forecast_custom_10_1_iTransformer.../checkpoint.pth`。
  - 测试集的数值预测输出及指标（`metrics.npy`, `pred.npy`, `true.npy`）成功落盘到了 `./results/` 文件夹之下；可视化的预测图像也对应存入了 `./test_results/`。
  - 最终测试集的量化性能指标被记录进入根目录 `result_long_term_forecast.txt`，结果十分理想：**Test MSE: 0.03803, Test MAE: 0.10195**，完成了我们的风场自定义任务闭环。

---