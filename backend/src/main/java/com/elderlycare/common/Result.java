package com.elderlycare.common;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Result<T> {

    private int code;
    private String message;
    private T data;
    private long ts;

    public static <T> Result<T> success(T data) {
        return Result.<T>builder()
                .code(0)
                .message("success")
                .data(data)
                .ts(System.currentTimeMillis())
                .build();
    }

    public static <T> Result<T> error(String message) {
        return Result.<T>builder()
                .code(-1)
                .message(message)
                .ts(System.currentTimeMillis())
                .build();
    }

    // ========== 以下为新增：支持自定义错误码 ==========
    public static <T> Result<T> error(int code, String message) {
        return Result.<T>builder()
                .code(code)
                .message(message)
                .ts(System.currentTimeMillis())
                .build();
    }
}