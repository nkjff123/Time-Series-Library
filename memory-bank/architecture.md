# Time-Series-Library 架构总览

## 项目定位

Time-Series-Library 是一个面向时间序列任务的统一实验框架，主要覆盖以下五类任务：

- 长期预测 `long_term_forecast`
- 短期预测 `short_term_forecast`
- 缺失值插补 `imputation`
- 异常检测 `anomaly_detection`
- 分类 `classification`

项目的核心目标是用统一的数据接口、模型接口和实验流程来管理不同任务下的训练、验证与测试。

## 代码结构

### `run.py`

整个项目的统一启动入口。通常由命令行参数决定任务类型、数据集、模型和训练配置，再分发到对应的实验类。

### `exp/`

实验执行层，负责把模型、数据和训练逻辑连接起来。

- `exp_basic.py`：基础实验类，处理设备选择、模型注册等通用逻辑。
- `exp_long_term_forecasting.py`：长期预测训练与评估流程。
- `exp_short_term_forecasting.py`：短期预测流程。
- `exp_imputation.py`：插补任务流程。
- `exp_anomaly_detection.py`：异常检测流程。
- `exp_classification.py`：分类流程。
- `exp_zero_shot_forecasting.py`：零样本预测流程。

### `models/`

模型实现层。这里包含大量时间序列模型，例如 `Autoformer`、`Informer`、`PatchTST`、`TimesNet`、`iTransformer`、`Mamba`、`TiDE`、`TSMixer`、`WPMixer` 等。

模型通常继承 `nn.Module`，并通过配置中的 `task_name` 适配不同任务。每个模型文件一般对应一个 `Model` 类。

### `layers/`

通用网络组件层，存放可复用的模块，例如：

- embedding 相关组件
- attention 相关实现
- 卷积/分解/频域等辅助结构
- 归一化与特征变换模块

### `data_provider/`

数据访问层，负责把不同数据集抽象成统一的数据加载接口。

- `data_factory.py`：根据配置选择具体数据集加载器。
- `data_loader.py`：数据读取、切片、批处理等通用逻辑。
- `m4.py`：M4 数据集相关支持。
- `uea.py`：UEA 分类数据集相关支持。

### `utils/`

工具函数集合，包含：

- 指标计算
- 训练辅助
- 时间特征处理
- 增强与掩码
- 统计与打印工具

### `scripts/`

实验脚本目录。按任务和数据集组织，通常封装了 `python run.py` 所需的参数组合，方便复现实验。

### `dataset/`

本地数据存放目录。当前工作区中可见 `mydata.csv`，通常用于风电功率预测等自定义实验或调试。

**架构洞察与数据解耦设计：**
- **数据路由**：框架通过 `data_provider/data_factory.py` 维护了一个 `data_dict` 字典，用于将参数 `--data custom` 动态映射到对应的数据集处理类 `Dataset_Custom`（位于 `data_loader.py`）。
- **零侵入适配**：通过将自定义数据集（如 `mydata.csv`）的特征列对齐，尤其是时间列统一命名为 `date`，可以实现**对底层加载框架的“零代码修改”接入**。
- **任务复用**：系统中的单变量/多变量超短期时间序列任务，本质上都可以沿用 `long_term_forecast` 进行管道管理，仅需在脚本层通过 `--seq_len`, `--label_len`, `--pred_len` 实现滑动窗口裁切，保障了整体引擎的统一性。
- **动态模型注册**：`exp_basic.py` 内部设计了 `_scan_models_directory()` 扫描方法与 `LazyModelDict`。当启动 `run.py` 传入具体模型名称（如 `--model iTransformer`），框架将自动根据文件名找到并实例化对应的 `Model` 类，降低了每次添加新模型时的字典硬编码维护成本。
- **超参数与评估指标设计考量：**
  1. **参数覆盖优先级**：`run.py` 作为项目驱动核心提供了大量默认的“基准值”（如 `d_model=512`, `batch_size=32`）。对于不同的局部任务环境（例如显存较小的边缘PC），应当在对应的执行脚本 `.sh` 层面提供针对性的硬约束覆盖（如设 `--batch_size 16`），以保障程序的本地适应性。
  2. **损失函数差异设计 (`MSE` vs `SMAPE`)**：针对 `short_term_forecast` 或 M4 这类短时预测/宏观数据竞赛（目标值不常趋零），业内常用 `SMAPE`（对称平均绝对误差）做比率惩罚；但对于实际环境的风电功率往往有“0出力”断崖边界情况（零和极小值），不应用作含有分母比值的指标体系。在此类型包含极值的 `long_term_forecast`/风电序列类项目中，基于 `MSE` 的回归是保证框架能正常求导、不致发生梯度爆炸的核心依赖。

### `tutorial/`

教程与演示内容。当前包含 `TimesNet_tutorial.ipynb`，适合快速理解单模型的使用方式。

### `memory-bank/`

项目知识沉淀区，用于记录架构、实现计划、阶段进展和设计说明，方便后续快速回看。

## 典型执行路径

1. 通过 `run.py` 读取命令行参数。
2. 根据 `task_name` 选择对应的 `exp/` 实验类。
3. 实验类通过 `data_provider/` 构建数据集和数据加载器。
4. `exp_basic.py` 中的模型注册逻辑实例化 `models/` 里的具体模型。
5. 训练、验证和测试流程在对应的实验类中完成。

## 模型接入约定

新增模型时，通常需要同时满足以下约定：

- 在 `models/` 下新增模型文件。
- 模型类继承 `nn.Module`。
- 构造函数接收 `configs`。
- 在前向逻辑中根据 `configs.task_name` 分支处理不同任务。
- 在 `exp/exp_basic.py` 的 `model_dict` 中注册模型名。
- 如需复现实验，补充对应 `scripts/` 脚本。

## 训练与运行

项目没有统一的编译构建流程，主要通过脚本驱动：

- 安装依赖：`pip install -r requirements.txt`
- 运行实验：执行 `scripts/` 下对应任务脚本，脚本内部一般调用 `python run.py`

## 当前工作区可见重点

- 模型族较多，覆盖传统 Transformer 变体、分解类方法、频域方法、Mamba 系列和混合结构。
- `scripts/` 已按任务维度拆分，便于对照不同模型的实验参数。
- `memory-bank/` 适合作为后续的设计决策和实现进展记录位置。

## 新增架构洞察 (Phase 5 测试验证后)

- **iTransformer 对极短/超短期数据的管道兼容性**：实验证明，对于极短输入序列 (`seq_len=10`, `pred_len=1`) 的超短期连续工业传感器预测任务，直接复用 `long_term_forecast` 管道是完全可行且通畅的，未产生任何数据流和尺寸对齐冲突。
- **极浅层模型架构在时序底座上的有效性**：在短序列多变量预测(MS)场景中，使用极浅层减配的模型参数 (`--e_layers 2`, `--d_layers 1`) 并配合 `batch_size=16`，能够在保障显存安全(无OOM)的同时，令 iTransformer 能够被快速有效驱动并迅速收敛(Vali Loss ~0.038)，这验证了 TSLib 作为统一框架具有良好的边界鲁棒性。

## 备注

该文档记录的是当前工作区可见的目录职责和常用执行路径。随着新模型、新任务或新数据集加入，建议同步更新这里的说明，避免结构认知漂移。
