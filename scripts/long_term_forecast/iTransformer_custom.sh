#!/bin/bash


# echo "==================== 实验 1: 基线模型 (seq_len=10) ===================="
# # iTransformer for custom wind power prediction
# python -u run.py \
#   --task_name long_term_forecast \
#   --is_training 1 \
#   --root_path ./dataset/ \
#   --data_path mydata.csv \
#   --model_id custom_10_1_baseline \
#   --model iTransformer \
#   --data custom \
#   --features MS \
#   --seq_len 10 \
#   --label_len 5 \
#   --pred_len 1 \
#   --e_layers 2 \
#   --d_layers 1 \
#   --factor 3 \
#   --enc_in 5 \
#   --dec_in 5 \
#   --c_out 1 \
#   --batch_size 16 \
#   --inverse \
#   --des 'Exp_Baseline' \
#   --target "平均发电机功率实时值" \
#   --freq t \
#   --itr 1

# echo "==================== 实验 2: 拓展历史窗口 (seq_len=30, label_len=15) ===================="
# python -u run.py \
#   --task_name long_term_forecast \
#   --is_training 1 \
#   --root_path ./dataset/ \
#   --data_path mydata.csv \
#   --model_id custom_60_1_long_seq \
#   --model iTransformer \
#   --data custom \
#   --features MS \
#   --seq_len 30 \
#   --label_len 15 \
#   --pred_len 1 \
#   --e_layers 2 \
#   --d_layers 1 \
#   --factor 3 \
#   --enc_in 5 \
#   --dec_in 5 \
#   --c_out 1 \
#   --batch_size 16 \
#   --inverse \
#   --des 'Exp_LongSeq' \
#   --target "平均发电机功率实时值" \
#   --freq t \
#   --itr 1

# echo "==================== 实验 3: 架构调优缩小容量 (d_model=128) + MAE 损失 ===================="
# python -u run.py \
#   --task_name long_term_forecast \
#   --is_training 1 \
#   --root_path ./dataset/ \
#   --data_path mydata.csv \
#   --model_id custom_10_1_small_mae \
#   --model iTransformer \
#   --data custom \
#   --features MS \
#   --seq_len 10 \
#   --label_len 5 \
#   --pred_len 1 \
#   --e_layers 2 \
#   --d_layers 1 \
#   --factor 3 \
#   --d_model 128 \
#   --d_ff 256 \
#   --enc_in 5 \
#   --dec_in 5 \
#   --c_out 1 \
#   --batch_size 16 \
#   --loss 'MAE' \
#   --inverse \
#   --des 'Exp_Small_MAE' \
#   --target "平均发电机功率实时值" \
#   --freq t \
#   --itr 1

# echo "==================== 实验 4: 横向极简基线网络 (DLinear) ===================="
# python -u run.py \
#   --task_name long_term_forecast \
#   --is_training 1 \
#   --root_path ./dataset/ \
#   --data_path mydata.csv \
#   --model_id custom_10_1_DLinear \
#   --model DLinear \
#   --data custom \
#   --features MS \
#   --seq_len 10 \
#   --label_len 5 \
#   --pred_len 1 \
#   --enc_in 5 \
#   --dec_in 5 \
#   --c_out 1 \
#   --batch_size 16 \
#   --inverse \
#   --des 'Exp_DLinear' \
#   --target "平均发电机功率实时值" \
#   --freq t \
#   --itr 1

echo "==================== 实验 5: 超短期防过拟合对比 (d_model=64) ===================="
python -u run.py \
  --task_name long_term_forecast \
  --is_training 1 \
  --root_path ./dataset/ \
  --data_path mydata.csv \
  --model_id custom_10_1_micro_64 \
  --model iTransformer \
  --data custom \
  --features MS \
  --seq_len 10 \
  --label_len 5 \
  --pred_len 1 \
  --e_layers 2 \
  --d_layers 1 \
  --factor 3 \
  --d_model 64 \
  --d_ff 128 \
  --enc_in 5 \
  --dec_in 5 \
  --c_out 1 \
  --batch_size 32 \
  --inverse \
  --des 'Exp_Micro_64' \
  --target "平均发电机功率实时值" \
  --freq t \
  --itr 1

echo "==================== 实验 6: 极致微缩网络对比 (d_model=32)  ===================="
python -u run.py \
  --task_name long_term_forecast \
  --is_training 1 \
  --root_path ./dataset/ \
  --data_path mydata.csv \
  --model_id custom_10_1_nano_32 \
  --model iTransformer \
  --data custom \
  --features MS \
  --seq_len 10 \
  --label_len 5 \
  --pred_len 1 \
  --e_layers 2 \
  --d_layers 1 \
  --factor 3 \
  --d_model 32 \
  --d_ff 64 \
  --enc_in 5 \
  --dec_in 5 \
  --c_out 1 \
  --batch_size 32 \
  --inverse \
  --des 'Exp_Nano_32' \
  --target "平均发电机功率实时值" \
  --freq t \
  --itr 1

echo "==================== 实验 7: 超短期防过拟合对比 (d_model=64) + MAE 损失 ===================="
python -u run.py \
  --task_name long_term_forecast \
  --is_training 1 \
  --root_path ./dataset/ \
  --data_path mydata.csv \
  --model_id custom_10_1_micro_64_mae \
  --model iTransformer \
  --data custom \
  --features MS \
  --seq_len 10 \
  --label_len 5 \
  --pred_len 1 \
  --e_layers 2 \
  --d_layers 1 \
  --factor 3 \
  --d_model 64 \
  --d_ff 128 \
  --enc_in 5 \
  --dec_in 5 \
  --c_out 1 \
  --batch_size 32 \
  --loss 'MAE' \
  --inverse \
  --des 'Exp_Micro_64_MAE' \
  --target "平均发电机功率实时值" \
  --freq t \
  --itr 1

echo "==================== 实验 8: 极致微缩网络对比 (d_model=32) + MAE 损失 ===================="
python -u run.py \
  --task_name long_term_forecast \
  --is_training 1 \
  --root_path ./dataset/ \
  --data_path mydata.csv \
  --model_id custom_10_1_nano_32_mae \
  --model iTransformer \
  --data custom \
  --features MS \
  --seq_len 10 \
  --label_len 5 \
  --pred_len 1 \
  --e_layers 2 \
  --d_layers 1 \
  --factor 3 \
  --d_model 32 \
  --d_ff 64 \
  --enc_in 5 \
  --dec_in 5 \
  --c_out 1 \
  --batch_size 32 \
  --loss 'MAE' \
  --inverse \
  --des 'Exp_Nano_32_MAE' \
  --target "平均发电机功率实时值" \
  --freq t \
  --itr 1