# 超短期风电功率预测任务设计文档

## 1. 任务背景与概述
- **任务目标**：基于风电机组实施运行的传感器状态数据，进行超短期风电功率预测。
- **基础框架**：基于 [Time-Series-Library (TSLib)] 框架进行二次开发与实验。
- **选用模型**：`iTransformer` （适合多变量和大规模时间序列表示）。
- **任务类型匹配**：虽然业务上称为“超短期预测”，但在 TSLib 的工程架构中，该多变量对单变量（传感器数据预测）的任务直接沿用 `long_term_forecast` 的管道运行。

## 2. 数据集配置设计
- **数据集文件路径**：`dataset/mydata.csv` （在执行时根据框架要求，可能需指向 `data/custom/mydata.csv`）。
- **时间列规范化**：已手动将原本的“时间”中文表头修改为 `date`，以自动适配 `Dataset_Custom` 的默认解析逻辑，避免修改底层加载代码。
- **特征构成**：共包含1个时间列和5个数值特征列（平均发电机转速实时值、平均发电机定子绕组u温度、最大风速实时值、平均变桨角度、平均发电机功率实时值）。

## 3. 核心模型参数设计
基于用户最新确认，确定以下关键的时间窗口和维度参数：

### 3.1 时间序列窗口配置 (Sequence Design)
- **输入序列长度 (`--seq_len`)**: `10` （即利用过去10分钟的数据作为历史输入）。
- **预测序列长度 (`--pred_len`)**: `1` （即预测未来1分钟的风电功率）。
- **标签序列长度 (`--label_len`)**: `5` （输入给予 Decoder 侧的参考长度，通常取 `seq_len` 的一半或适当短于 `seq_len` 的值，这里设计为5）。

### 3.2 预测模式与维度配置 (Mode Design)
- **预测模式**：**MS** (Multivariate to Univariate)。输入多种特征，但最终只输出（预测）单一的功率变量。
- **目标特征 (`--target`)**：`平均发电机功率实时值`。
- **编码器输入通道 (`--enc_in`)**: `5` （输入包括风速、转速、温度、变桨角度、功率等全部5个特征）。
- **解码器输入通道 (`--dec_in`)**: `5` （同上，根据架构通常保持和 enc_in 一致）。
- **模型输出通道 (`--c_out`)**: `1` （由于是 MS 模式，最终只预测功率这1个特征）。

## 4. 执行脚本对应参数设计参考
依据上述设计，在 `scripts/long_term_forecast/` 建立的 shell 脚本（例如 `iTransformer_custom.sh`）中，关键执行参数应配置为如下结构：

```bash
python -u run.py \
  --task_name long_term_forecast \
  --is_training 1 \
  --root_path ./dataset/ \
  --data_path mydata.csv \
  --model_id custom_10_1 \
  --model iTransformer \
  --data custom \
  --features MS \
  --seq_len 10 \
  --label_len 5 \
  --pred_len 1 \
  --e_layers 2 \
  --d_layers 1 \
  --factor 3 \
  --enc_in 5 \
  --dec_in 5 \
  --c_out 1 \
  --des 'Exp' \
  --target "平均发电机功率实时值" \
  --itr 1
```

## 5. 后续优化及重点关注
随着实验进行，可以重点记录/调优以下设计：
1. **降重采样与平滑**：目前为1分钟1个点跳动可能带来较强的噪声。若预测效果不佳，可以考虑采用移动平均或5分钟/10分钟重采样以获取更平滑的趋势。
2. **`--e_layers` 与模型容量**：由于当前 `seq_len` 很短（仅10），iTransformer 不需要太深的网络结构。建议将 Transformer 的堆叠层数设得较小（例如 `e_layers=2` 即可），避免短序列过拟合。
3. **Loss 函数选择**：对于风电功率这类经常伴随突变的序列，除了基础的 MSE Loss，后续也可测试引入 MAE（L1 Loss），以加强对异常极端值的鲁棒性表现。