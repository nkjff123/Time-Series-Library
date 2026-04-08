#!/bin/bash

# iTransformer for custom wind power prediction
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
  --batch_size 16 \
  --inverse \
  --des 'Exp' \
  --target "平均发电机功率实时值" \
  --freq t \
  --itr 1