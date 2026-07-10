$content = @'
package com.elderlycare.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.common.Result;
import com.elderlycare.dto.ElderlyRequest;
import com.elderlycare.dto.ElderlyResponse;
import com.elderlycare.service.ElderlyService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/elderly")
@RequiredArgsConstructor
public class ElderlyController {

    private final ElderlyService elderlyService;

    @GetMapping
    public ResponseEntity<Result<IPage<ElderlyResponse>>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(Result.success(elderlyService.findPage(page, size)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Result<ElderlyResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(Result.success(elderlyService.findById(id)));
    }

    @PostMapping
    public ResponseEntity<Result<ElderlyResponse>> create(@Valid @RequestBody ElderlyRequest request) {
        ElderlyResponse elderly = elderlyService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Result.success(elderly));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Result<ElderlyResponse>> update(@PathVariable Long id, @Valid @RequestBody ElderlyRequest request) {
        return ResponseEntity.ok(Result.success(elderlyService.update(id, request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Result<Void>> delete(@PathVariable Long id) {
        elderlyService.delete(id);
        return ResponseEntity.ok(Result.success(null));
    }

    @GetMapping("/search")
    public ResponseEntity<Result<List<ElderlyResponse>>> search(@RequestParam String keyword) {
        return ResponseEntity.ok(Result.success(elderlyService.search(keyword)));
    }

    @PostMapping("/register")
    public ResponseEntity<Result<ElderlyResponse>> register(@Valid @RequestBody ElderlyRequest request) {
        ElderlyResponse elderly = elderlyService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Result.success(elderly));
    }

    @PutMapping("/update-by-contact")
    public ResponseEntity<Result<ElderlyResponse>> updateByContact(@Valid @RequestBody ElderlyRequest request) {
        return ResponseEntity.ok(Result.success(elderlyService.updateByContact(request.getName(), request.getPhone(), request)));
    }
}
'@
[System.IO.File]::WriteAllText("E:\LiuLanQi2\Git\aiguard-reference-kit\backend\src\main\java\com\elderlycare\controller\ElderlyController.java", $content, [System.Text.Encoding]::UTF8)
