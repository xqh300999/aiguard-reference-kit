package com.elderlycare.common;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.Instant;

/**
 * 统一 API 返回格式
 * <p>遵循团队开发规范 §1.1：{ code, message, data, ts }
 */
@Data
public class Result<T> {

    private int code;
    private String message;
    private T data;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant ts;

    public static <T> Result<T> success(T data) {
        Result<T> r = new Result<>();
        r.code = 0;
        r.message = "success";
        r.data = data;
        r.ts = Instant.now();
        return r;
    }

    public static <T> Result<T> error(int code, String message) {
        Result<T> r = new Result<>();
        r.code = code;
        r.message = message;
        r.data = null;
        r.ts = Instant.now();
        return r;
    }
}
