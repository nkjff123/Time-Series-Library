# Time-Series-Library (TSLib) Guidelines

## Architecture & Code Base Structure
This codebase provides a unified framework for 5 mainstream time series tasks: `long_term_forecast`, `short_term_forecast`, `imputation`, `anomaly_detection`, and `classification`.

- **`models/`**: Contains all deep learning models (e.g., `TimesNet.py`, `DLinear.py`, `Transformer.py`). Models must inherit from `nn.Module` and handle the 5 tasks via `configs.task_name` conditional logic.
- **`exp/`**: Experiment execution logic. `exp_basic.py` manages device selection and the `model_dict` registry. Specific task loops (train/vali/test) are in `exp_anomaly_detection.py`, `exp_long_term_forecasting.py`, etc.
- **`data_provider/`**: `data_factory.py` routes the dataset type to the correct loader class in `data_loader.py`.
- **`layers/`**: Reusable neural network components (embeddings, attention mechanisms, etc.).

## Adding a New Model
When implementing a new time series model:
1. Create `models/{YourModel}.py` with a `Model` class inheriting from `nn.Module`. Use `models/Transformer.py` or `models/DLinear.py` as references.
2. The model constructor must accept a `configs` object and handle the 5 main tasks.
3. Import and register the new model in the `Exp_Basic.model_dict` inside `exp/exp_basic.py`.
4. For contributing to the upstream repository, follow the guidelines in [`CONTRIBUTING.md`](../CONTRIBUTING.md).

## Build and Test
There is no unified build system; execution is driven by bash scripts.
- **Dependencies**: `pip install -r requirements.txt`
- **Execution**: Run the benchmark scripts located in the `scripts/` directory.
  - Example: `bash ./scripts/long_term_forecast/ETT_script/TimesNet_ETTh1.sh`
- **Script Conventions**: Scripts wrap `python run.py` with the necessary CLI arguments for the specific model, dataset, and task type. When adding a new model, create corresponding execution scripts following existing patterns.

## Conventions
- Always check `configs.task_name` in the model's forward pass to route to the correct task head (e.g., forecasting vs classification).
- Keep dataset look-back (`seq_len`) and prediction lengths (`pred_len`) strictly parameterized via the `configs` object passed to the models.
- Refer to the [README.md](../README.md) for the latest leaderboard and dataset preparation instructions.
