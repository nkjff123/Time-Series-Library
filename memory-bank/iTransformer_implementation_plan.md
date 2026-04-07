## Phase 1: 环境与基线确认

### Step 1: 检查环境依赖要求

**目标：**
确认当前环境包含项目所需的基础依赖库。

**操作指令：**
打开工作区根目录下的 `requirements.txt` 文件，阅读并记录所需的关键库名称（如 torch, numpy, pandas）。

**预期结果：**
记录下项目中列出的所有依赖包及其版本要求。

**验证方法：**
在终端运行 `pip list`，检查终端输出列表中是否包含 `requirements.txt` 里的所有关键包。

### Step 2: 确认自定义数据集文件结构

**目标：**
将自己的数据集放置到项目标准的数据目录下。

**操作指令：**
在工作区根目录的 `./data/` 文件夹下（若无则新建名为 `custom` 的文件夹），将自定义数据集的 CSV 文件放入该目录，并记录绝对路径。

**预期结果：**
你的自定义 CSV 数据集文件存在于 `./data/custom/` 目录下。

**验证方法：**
在文件资源管理器或通过终端命令 `ls ./data/custom/`，能看到目标 CSV 文件名输出。

### Step 3: 运行已有基准测试脚本（用于连通性测试）

**目标：**
确保已有代码库及 iTransformer 模型能在当前系统上正常跑通，排除环境或硬件问题。

**操作指令：**
在终端执行自带的 iTransformer 测试脚本，例如：`bash ./scripts/long_term_forecast/ETT_script/iTransformer_ETTh1.sh`（假设存在此类标准脚本）。

**预期结果：**
脚本启动，控制台开始输出模型参数加载信息、网络结构信息，并进入 Epoch 1 的训练。

**验证方法：**
观察终端输出，确认出现 `>>>>>>>start training :` 以及 `Epoch: 1 cost time:` 等训练进度字样，无 Python 报错崩溃。

---

## Phase 2: 模块理解与选择

### Step 4: 定位 iTransformer 模型入口

**目标：**
确认 iTransformer 模型的具体实现位置及参数接收方式。

**操作指令：**
打开文件 `models/iTransformer.py`，查找 `class Model(nn.Module):` 的定义部分以及其 `__init__` 函数。

**预期结果：**
找到 `Model` 类，并观察到其初始化函数接收 `configs` 对象作为参数。

**验证方法：**
确保 `models/__init__.py` 或 `exp/exp_basic.py` 的模型字典 `model_dict` 中包含 `'iTransformer': iTransformer` 的映射。

### Step 5: 审查数据工厂路由逻辑

**目标：**
理解项目如何通过参数识别并加载自定义数据集。

**操作指令：**
打开 `data_provider/data_factory.py`，查找 `data_dict` 字典的定义。

**预期结果：**
在 `data_dict` 中找到类似 `'custom': Dataset_Custom` 的键值对映射。

**验证方法：**
文件中确实存在 `data_dict` 并且包含用于自定义数据集对应的数据集类映射（`Dataset_Custom`）。

### Step 6: 审查自定义数据加载器

**目标：**
确认自定义数据集需要满足的格式规范（如时间列名、特征处理方式）。

**操作指令：**
打开 `data_provider/data_loader.py` 文件，搜索 `class Dataset_Custom`，查看其 `__init__` 和 `read_data` 方法。

**预期结果：**
发现 `Dataset_Custom` 默认以 `date` 作为时间列（或其他指定列名），且进行具体的数据标准化或时间特征编码。

**验证方法：**
打开自定义数据集的 CSV 文件，检查第一行表头，确认时间列的名称是否与 `Dataset_Custom` 中期望的列名一致（通常为 `date`），如果不一致需要记录下来准备在脚本中通过参数覆盖。

---

## Phase 3: 模型结构设计

### Step 7: 确定任务类型与运行模式

**目标：**
为自定义数据集选择合适的时间序列任务类型（如长程预测）。

**操作指令：**
打开 `run.py`，查看 `--task_name` 参数的可选项，并记录下你需要的任务名称（如 `long_term_forecast`）。

**预期结果：**
选定任务为 `long_term_forecast`，对应将在后续脚本中使用该参数。

**验证方法：**
在 `run.py` 中确认 `long_term_forecast` 属于 `parser.add_argument('--task_name', ... options:[...])` 的合法选项列表中。

### Step 8: 映射数据集特征维度

**目标：**
获取自定义数据集的准确特征数量，为模型输入/输出通道数做准备。

**操作指令：**
统计自定义 CSV 文件中除了时间列以外的所有数值特征列的数量，记为 `N`。

**预期结果：**
得到明确的整数 `N`，该值将用于设置模型的 `--enc_in`, `--dec_in`, `--c_out` 参数。

**验证方法：**
利用 pandas 或 Excel 打开 CSV，列总数减去时间列应刚好等于 `N`。

### Step 9: 确定时间序列窗口超参数

**目标：**
设定输入上下文长度和预测长度。

**操作指令：**
在记事本中记录针对此数据集的序列参数设置：`--seq_len 96`，`--label_len 48`，`--pred_len 96`（或者针对你需求的具体长度）。

**预期结果：**
获得一组明确的滑动窗口超参数配置组合。

**验证方法：**
确保这些参数均为正整数，并且 `label_len` 小于或等于 `seq_len`，符合时序预测的一般要求。

---

## Phase 4: 代码连接与修改

### Step 10: 复制并创建专属执行脚本

**目标：**
基于已有的 iTransformer 脚本创建一个独立的运行脚本用于测试自己的数据。

**操作指令：**
在 `scripts/long_term_forecast/` 目录下新建一个名为 `iTransformer_custom.sh` 的文件（可以在终端使用 `touch`或直接在IDE中新建），并将项目中已有的某一 iTransformer 的 shell 脚本内容复制进去。

**预期结果：**
在项目目录结构中生成了一个新的 `.sh` 脚本文件，且其中包含 `python -u run.py ...` 的执行命令。

**验证方法：**
在文件资源管理器 `scripts/long_term_forecast/` 下双击能打开 `iTransformer_custom.sh` 并且内容不为空。

### Step 11: 修改脚本中的数据加载参数

**目标：**
将新建脚本的数据读取路径指向自己的数据集。

**操作指令：**
在 `iTransformer_custom.sh` 中，找到对应的参数并修改为：`--data custom`，`--root_path ./data/custom/`，`--data_path 你的文件名.csv`，`--target 你要预测的列名`，`--features M`（如果是多变量预测多变量）。

**预期结果：**
脚本命令中的数据定位参数完全匹配 Step 2 存放的真实文件路径。

**验证方法：**
仔细对比 `.sh` 文件中的 `--data_path` 字符串是否与 `./data/custom/` 目录下的实际文件名一字节不差。

### Step 12: 修改脚本中的模型维度参数

**目标：**
让模型的通道输入与自定义数据的特征维度对齐。

**操作指令：**
在 `iTransformer_custom.sh` 中，将 `--enc_in`, `--dec_in`, `--c_out` 的值全部修改为 Step 8 中统计到的特征数量 `N`。并设置 `--model iTransformer`。

**预期结果：**
脚本中的维度参数均与数据集特征数保持一致。

**验证方法：**
检查脚本中是否存在 `--enc_in N --dec_in N --c_out N`，如果有其他旧的硬编码特征数（如7, 21, 321），说明修改不全。

---

## Phase 5: 实验运行

### Step 13: 赋予脚本执行权限并启动运行

**目标：**
开始针对自定义数据集训练 iTransformer 模型。

**操作指令：**
在 VS Code 终端中输入 `chmod +x ./scripts/long_term_forecast/iTransformer_custom.sh` 赋予权限，然后执行 `bash ./scripts/long_term_forecast/iTransformer_custom.sh`。

**预期结果：**
终端不再抛出“Permission denied”错误，且 Python 进程按照给定的自定义参数启动运行。

**验证方法：**
控制台输出 `Args in experiment:` 后，打印出的配置列表中 `data` 为 `custom`，`model` 为 `iTransformer`。

### Step 14: 监控训练过程中的显存/内存

**目标：**
确保模型配置在这个数据集下不会导致 OOM（内存超限）。

**操作指令：**
打开一个新的终端窗口，输入 `nvidia-smi`（如果是GPU环境）或直接在系统资源管理器中观察当前任务的内存使用率。

**预期结果：**
能够观察到 python 进程占用了一定量的显存/内存，并且占用大小保持稳定。

**验证方法：**
终端未因 `RuntimeError: CUDA out of memory` 或 `Killed` （Linux OOM Killer）而中断。

### Step 15: 观察第一轮 Epoch 的 Loss 输出

**目标：**
确认模型在反向传播，参数得以更新，没有数据形状对齐导致的中断。

**操作指令：**
紧盯训练脚本运行终端，等待 `Epoch: 1` 结束后打印的 `train loss` 和 `vali loss` 结果。

**预期结果：**
控制台清晰地打印出类似于 `Epoch: 1, Steps: xxx | Train Loss: 0.xxxx Vali Loss: 0.xxxx Test Loss: 0.xxxx` 的日志。

**验证方法：**
验证日志中的 Loss 值为有效的浮点数，而不是 `NaN` 或 `Inf`。

---

## Phase 6: 结果验证

### Step 16: 定位模型权重存档

**目标：**
确认训练后的最佳模型已经被成功保存。

**操作指令：**
翻阅项目的 `./checkpoints/` 文件夹，寻找名称与你刚才执行的 `setting` 字符串匹配的文件夹。

**预期结果：**
在该特定的 setting 文件夹内找到了 `checkpoint.pth` 文件。

**验证方法：**
在终端运行 `ls ./checkpoints/自定义任务设定名称/`，能看到包含 `.pth` 后缀的文件输出。

### Step 17: 查看测试集输出指标记录

**目标：**
确认模型在对应数据集的测试阶段已完成，并输出了评价指标。

**操作指令：**
打开并查看项目根目录下的 `./results/自定义任务设定名称/` 文件夹中的 `metrics.npy` 或在 `./test_results/自定义任务设定名称/` 中查看输出的 NumPy 数组文件。

**预期结果：**
找到了包含预测结果数组或评价指标值的文件。

**验证方法：**
文件大小大于 0 字节，生成时间应与刚刚终端显示 `>>>>>>>testing :` 结束的时间一致。

### Step 18: 记录最终实验日志

**目标：**
保留本次自定义数据集跑通后的精确评估指标。

**操作指令：**
打开根目录下的 `result.txt`（默认日志输出文件），跳到最后一行，查看本次运行追加的 MSE 和 MAE 数值。

**预期结果：**
文件最后增加了一行文本，记录了你的自定义任务 setting 标识以及对应的 `mse` 和 `mae` 指标。

**验证方法：**
`result.txt` 末尾的文本包含 `iTransformer` 以及你设置的数据集名称 `custom`，并伴随数值指标，例如 `mse:0.4321, mae:0.3210`。