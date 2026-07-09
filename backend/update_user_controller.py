with open(r'E:\LiuLanQi2\Git\aiguard-reference-kit\backend\src\main\java\com\elderlycare\controller\UserController.java', 'r', encoding='utf-8') as f:
    content = f.read()

new_method = """

    @PutMapping("/{id}/bind-by-contact")
    public ResponseEntity<Result<UserResponse>> bindByContact(@PathVariable Long id, @Valid @RequestBody UserBindByContactRequest request) {
        return ResponseEntity.ok(Result.success(userService.bindElderlyByContact(id, request.getName(), request.getPhone())));
    }
"""

content = content.replace('return ResponseEntity.ok(Result.success(userService.bindElderly(id, request.getElderlyId())));\n    }\n}','return ResponseEntity.ok(Result.success(userService.bindElderly(id, request.getElderlyId())));\n    }' + new_method + '}')

with open(r'E:\LiuLanQi2\Git\aiguard-reference-kit\backend\src\main\java\com\elderlycare\controller\UserController.java', 'w', encoding='utf-8') as f:
    f.write(content)

print("done")
